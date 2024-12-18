import 'package:flutter/material.dart';
import 'package:flutter_template/components/clickableText.dart';
import 'package:flutter_template/components/customButtom.dart';
import '../services/authService.dart';
import 'home.dart'; // Importando a tela Home, onde o usuário será redirecionado

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      _checkIfUserLoggedIn();
    });
    if (AuthService.currentUser != null) {
      Navigator.pushNamed(context, "/home");
    }
  }

  // Verifica se o usuário já está logado
  Future<void> _checkIfUserLoggedIn() async {
    print("_checkIfUserLoggedIn");

    if (AuthService().auth.currentUser != null) {
      var resp = await AuthService().getLoggedUser();
      if (AuthService.currentUser != null) {
        Navigator.pushNamed(context, "/home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            Text(
              "Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16.0,
              width: double.maxFinite,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16.0),
            Container(
              width: double.maxFinite,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                spacing: 24,
                runSpacing: 24,
                children: [
                  CustomButtom(onPressed: () => _login(), text: "Entrar"),
                  ClickableText(
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    text: "não possui uma conta?",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Redireciona para a tela principal após login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } catch (e, s) {
      print(e);
      print(s);
      setState(() {
        _errorMessage = "Falha ao fazer login. Verifique suas credenciais.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
