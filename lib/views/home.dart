import 'package:flutter/material.dart';
import 'package:flutter_template/services/authService.dart';
import 'package:flutter_template/utils/geoLocalizationUtil.dart';
import 'package:flutter_template/views/user/userHome.dart';
import 'admin/admin_home.dart';
import 'login_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    Geolocalizationutil().getCurrentLocation();
    super.initState();

    // Usando addPostFrameCallback para garantir que a navegação ocorra após a construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async {
    print("_checkUserStatus");
    final user = AuthService.currentUser;

    // Verifica se o usuário está logado
    if (user != null) {
      if (user.profile == 1) {
        _navigateTo(AdminHome());
      } else {
        // Caso contrário, redireciona para a tela inicial ou de usuário comum
        _navigateTo(UserHome());
      }
    } else {
      // Se o usuário não estiver logado, redireciona para a tela de login
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  // Função auxiliar para realizar a navegação com verificação do contexto
  void _navigateTo(Widget destination) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
