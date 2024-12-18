const functions = require("firebase-functions");
const axios = require("axios");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const moment = require("moment-timezone");
const admin = require("firebase-admin");

const { v4: uuidv4 } = require("uuid");

var serviceAccount = require("./serviceAccountKey.json");
const sgMail = require("@sendgrid/mail");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const cors = require("cors")({ origin: true });
const db = admin.firestore();
moment.tz.setDefault("America/Sao_Paulo");

const AWS = require("aws-sdk");
const accessKeyId = "DO00FX8WTAGMY796BHND";
const secretAccessKey = "SOTKVPOhG8QOgjaGgCyO/p3/MWqLndSt/jWaHM7mtcc";

AWS.config.update({
  region: "nyc3",
  accessKeyId,
  secretAccessKey,
});

const s3 = new AWS.S3({
  endpoint: "https://nyc3.digitaloceanspaces.com",
  signatureVersion: "v4",
});

exports.createUser = functions.https.onCall(async (req, res) => {
    try {
      console.log(req);
      const data = req.body;
      console.log(data);
      if (data.user.profile == 1) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "permission-denied!"
        );
      } else {
        console.log(data);
        const novoUsuario = {
          name: data.user.name.trim(),
          nameL: data.user.nameL.trim(),
          email: data.user.email.trim(),
        };
  
        let userId;
        if (data.id) userId = data.id;
        if (userId) {
          // update
          await admin
            .auth()
            .updateUser(userId, { email: data.email, password: data.password });
  
          novoUsuario.id = userId;
          novoUsuario.updatedAt = Number(moment().format("YYYYMMDDHHmmssSSS"));
          novoUsuario.enterpriseId = data.enterpriseId;
          await db.doc(`users/${userId}`).update(novoUsuario);
          console.log("Salvo com sucesso!");
          return { status: 200, body: novoUsuario.id };
        } else {
          if (data.cpf && data.cpf != "") {
            var cpfExits = await db
              .collection("users")
              .where("cpf", "==", data.cpf)
              .get();
            console.log(cpfExits.size);
            if (!cpfExits.size == 0) {
              throw new functions.https.HttpsError(
                "already-exists",
                "cpf-already-exists"
              );
            }
          }
        
          const userRecord = await admin.auth().createUser({
            email: data.user.email.trim(),
            password: data.password.trim(),
          });
          novoUsuario.id = userRecord.uid;
          novoUsuario.createdAt = Number(moment().format("YYYYMMDDHHmmssSSS"));
          novoUsuario.updatedAt = Number(moment().format("YYYYMMDDHHmmssSSS"));
          novoUsuario.cpf = data.user.cpf;
          novoUsuario.profile = data.user.profile ?? 2;
  
          var batch = db.batch();
          batch.set(db.doc(`users/${novoUsuario.id}`), novoUsuario);
  
          console.log("commiting");
          await batch.commit();
  
          console.log("Salvo com sucesso!");
          return { status: 200, body: novoUsuario.id };
        }
      }
    } catch (e) {
      console.log(e);
      return { status: 500, body: { error: e, message: e.message } };
    }
  });

 
exports.sendEmail = functions.https.onCall(async (data, context) => {
  // Verifica se o usuário está autenticado
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Você precisa estar autenticado para usar esta função."
    );
  }

  const notifications = data.notifications;

  // Valida se a lista foi enviada corretamente
  if (!Array.isArray(notifications) || notifications.length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "A lista de notificações é obrigatória e deve conter ao menos um item."
    );
  }

  try {
    // Enviar emails para todas as notificações
    const emailPromises = notifications.map(async (notification) => {
      const { emailTo, subject, html, msg } = notification;

      if (!emailTo || !subject || !html) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Cada notificação deve conter os campos 'emailTo', 'subject' e 'html'."
        );
      }

      // Configurar o email
      const emailData = {
        to: emailTo,
        from: "seuemail@dominio.com", // Substitua pelo seu email
        subject: subject,
        text: msg,
        html: html,
      };

      await db.doc(`users/${context.auth.uid}`).collection("notifications").add(notification);

      // Enviar o email usando SendGrid
      await sgMail.send(emailData);
      
    });

    // Aguarda o envio de todos os emails
    await Promise.all(emailPromises);

    return { success: true, message: "Emails enviados com sucesso!" };
  } catch (error) {
    console.error("Erro ao enviar emails:", error);
    throw new functions.https.HttpsError(
      "unknown",
      "Erro ao enviar emails. Verifique o log para mais detalhes."
    );
  }
});