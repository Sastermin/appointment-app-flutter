import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Appointment',
      home: const AuthStateHandler(),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

// Widget que maneja el estado de autenticación
class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se verifica el estado de autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        // Si el usuario está autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                );
              }

              // Leer el rol del usuario
              final String userRole =
                  userSnapshot.data?.data() != null
                      ? (userSnapshot.data!.data() as Map<String, dynamic>)['rol'] ?? 'Paciente'
                      : 'Paciente';

              // Redirigir según el rol
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (userRole == 'Médico') {
                  Navigator.pushReplacementNamed(context, Routes.dashboard);
                } else {
                  Navigator.pushReplacementNamed(context, Routes.home);
                }
              });

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                ),
              );
            },
          );
        }

        // Si no está autenticado, mostrar login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, Routes.login);
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4CAF50),
            ),
          ),
        );
      },
    );
  }
}