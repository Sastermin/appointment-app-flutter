import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'main_navigator.dart';
import 'citas_page.dart'; // ¡NUEVA IMPORTACIÓN!

class Routes {
  static const String login = '/login';
  // 'home' ahora será el navegador principal con la barra inferior
  static const String home = '/home'; 
  static const String profile = '/profile';
  static const String citas = '/citas'; // ¡NUEVA RUTA!

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        // La ruta '/home' ahora apunta al MainNavigator
        return MaterialPageRoute(builder: (_) => const MainNavigator()); 
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case citas: // ¡NUEVO CASO!
        return MaterialPageRoute(builder: (_) => const CitasPage());
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