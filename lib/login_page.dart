import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Colores principales de la app
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      //Fondo en blanco con appbar estilizada
      backgroundColor: blanco,
      appBar: AppBar(
        title: const Text(
          'Inicio de Sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // texto blanco sobre fondo verde
          ),
        ),
        centerTitle: true, // Centra el título
        backgroundColor: verdeOscuro, // fondo verde oscuro del appbar
        elevation: 5, // ligera sombra elegante
      ),

      //Centrar el contenido con un diseño más limpio
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo o ícono representativo
              const Icon(
                Icons.local_hospital_rounded,
                size: 90,
                color: Color(0xFF3E8E41),
              ),
              const SizedBox(height: 20),

              // Texto de bienvenida
              const Text(
                "Bienvenido de nuevo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E8E41),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Por favor, inicia sesión para continuar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Campo de correo electrónico
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  prefixIcon: const Icon(Icons.email_outlined, color: verdeOscuro),
                  filled: true, //color de fondo en el campo
                  fillColor: verdeClaro.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // bordes redondeados
                    borderSide: BorderSide.none, // sin borde visible
                  ),
                  labelStyle: const TextStyle(color: verdeOscuro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su correo electrónico";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline, color: verdeOscuro),
                  filled: true,
                  fillColor: verdeClaro.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: verdeOscuro),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingrese su contraseña";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      UserCredential userCredential =
                          await _auth.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Bienvenido ${userCredential.user?.email ?? ''}",
                          ),
                        ),
                      );

                      Navigator.pushReplacementNamed(context, Routes.home);
                    } on FirebaseAuthException catch (e) {
                      String message = "";
                      if (e.code == 'user-not-found') {
                        message = "Usuario no encontrado";
                      } else if (e.code == 'wrong-password') {
                        message = "Contraseña incorrecta";
                      } else {
                        message = e.message!;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  }
                },
                //Diseño de botón principal
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeOscuro,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 4,
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(fontSize: 18, color: blanco),
                ),
              ),

              const SizedBox(height: 20),

              //Botones secundarios estilizados
              TextButton(
                onPressed: () {},
                child: const Text(
                  "¿Olvidó su contraseña?",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Crear una cuenta nueva",
                  style: TextStyle(
                    color: verdeOscuro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
