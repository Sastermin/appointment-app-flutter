import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'main_navigator.dart'; // ¡NUEVA IMPORTACIÓN!

class Routes {
  static const String login = '/login';
  // 'home' ahora será el navegador principal con la barra inferior
  static const String home = '/home'; 
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        // La ruta '/home' ahora apunta al MainNavigator
        return MaterialPageRoute(builder: (_) => const MainNavigator()); 
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}