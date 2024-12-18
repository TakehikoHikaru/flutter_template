import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/views/home.dart';
import 'package:flutter_template/views/login_screen.dart';
import 'package:flutter_template/views/register_account.dart';

import 'utils/firebase/firebase_options.dart';

// import 'generated/l10n.dart';
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  // await Localization.instance.load('en'); // Load English by default

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      debugShowCheckedModeBanner: false,
      // supportedLocales: [
      //   Locale('en', ''), // English
      //   Locale('pt', ''), // Portuguese
      // ],
  //     localizationsDelegates: const [
  //       AppLocalizations.delegate,
  //  GlobalMaterialLocalizations.delegate, // Material components localization
  //       GlobalWidgetsLocalizations.delegate, // General widgets localization
  //       GlobalCupertinoLocalizations.delegate, // Cupertino components localization
  //     ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (BuildContext context) => LoginScreen(),
        '/register': (BuildContext context) => RegisterAccount(),
        '/home': (BuildContext context) => Home(),
        // '/resetPassword/:code': (BuildContext context) => PasswordReset(code: ""),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
          settings: RouteSettings(name: "/login", arguments: {}),
        );
      },
      builder: (context, child) => Scaffold(
        body: child,
      ),
      initialRoute: '/login',
    );
  }
}
