import 'package:flutchatapp/pages/home_page.dart';

import './pages/login_page.dart';
import 'package:flutter/material.dart';
import './pages/registration_page.dart';
import './services/navigation_service.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.instance.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FlutChat',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'login',
      routes: {
        'login': (BuildContext _context)=>LoginPage(),
        'register': (BuildContext _context)=>RegistrationPage(),
        'home': (BuildContext _context)=>HomePage(),

      },
    );
  }
}

