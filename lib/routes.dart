import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'citas_page.dart';
import 'dashboard_bloc.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'main_navigator.dart';
import 'profile_page.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String citas = '/citas';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigator());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case citas:
        return MaterialPageRoute(builder: (_) => const CitasPage());
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DashboardBloc(),
            child: const DashboardPage(),
          ),
        );
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
