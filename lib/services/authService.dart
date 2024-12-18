import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_template/models/user.dart';
import 'package:flutter_template/utils/Requests.dart';
import 'package:flutter_template/utils/consts.dart';
import 'package:flutter_template/utils/dataToSave.dart';

class AuthService {
  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();
  factory AuthService() => instance;

  // Store current user in memory
  static User? _currentUser;

  /// Returns the currently logged-in user
  static User? get currentUser => _currentUser;

  /// Logs in the user with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Firebase Auth login
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String userId = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection(Consts.userColection).doc(userId).get();

      // If document exists, set the current user
      if (userDoc.exists) {
        _currentUser = User.fromJson(userDoc.data()!);
      } else {
        throw Exception("User data not found in Firestore.");
      }

      return _currentUser;
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  Future<bool> getLoggedUser() async {
    try {
      var resp = await _firestore.collection(Consts.userColection).doc(auth.currentUser!.uid).get();

      _currentUser = User.fromJson(resp.data()!);

      return true;
    } catch (e, t) {
      print("Error getLoggedUser: " + e.toString() + " " + t.toString());
      return false;
    }
  }

  /// Logs out the user and clears the current user data in memory
  Future<void> logout() async {
    await auth.signOut();
    _currentUser = null;
  }

  Future<UserCredential> registerUserWithoutSignOut({
    required String email,
    required String password,
    required User user,
  }) async {
    // Cria uma nova instância do Firebase App para uso temporário
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    // Cria uma instância de autenticação do Firebase com o app secundário
    FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    try {
      // Registra o novo usuário com o app secundário
      UserCredential userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Requests.create(
        dataToSave(
          ref: _firestore.collection(Consts.userColection).doc(userCredential.user!.uid),
          model: user,
          dataToUpdate: user.toJson(),
        ),
      );
      // Retorna o usuário criado
      return userCredential;
    } finally {
      // Destrói o app secundário para liberar os recursos
      await secondaryApp.delete();
    }
  }
}
