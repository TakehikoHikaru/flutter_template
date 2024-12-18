import 'package:flutter/material.dart';
import 'package:flutter_template/components/clickableText.dart';
import 'package:flutter_template/components/customButtom.dart';
import 'package:flutter_template/components/custom_textfield.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CustomButtom(
                          onPressed: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          icon: Icons.arrow_back,
                        ),
                        Text("Cadastro"),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0, width: double.maxFinite),
                  CustomTextfield(
                    label: "Email",
                    hint: "Email",
                    controller: emailController,
                  ),
                  SizedBox(height: 16.0, width: double.maxFinite),
                  CustomTextfield(
                    label: "Senha",
                    hint: "Senha",
                    controller: passwordController,
                  ),
                  SizedBox(height: 16.0, width: double.maxFinite),
                  CustomTextfield(
                    label: "Confirmar Senha",
                    hint: "Confirmar Senha",
                    controller: confirmPasswordController,
                  ),
                  SizedBox(height: 16.0, width: double.maxFinite),
                  Container(
                    width: double.maxFinite,
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        ClickableText(
                          onPressed: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          text: "Ja possui uma conta?",
                        ),
                        CustomButtom(text: "Cadastrar", onPressed: () {}),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
