import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // 👇 Nuevo: Campo para selección de rol
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        title: const Text(
          'Inicio de Sesión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: verdeOscuro,
        elevation: 5,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                size: 90,
                color: Color(0xFF3E8E41),
              ),
              const SizedBox(height: 20),

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

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico",
                  prefixIcon: const Icon(Icons.email_outlined, color: verdeOscuro),
                  filled: true,
                  fillColor: verdeClaro.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
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

              const SizedBox(height: 20),

              // 🔥 Selector de Rol
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF9FE2BF).withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: selectedRole,
                hint: const Text("Selecciona tu rol"),
                items: const [
                  DropdownMenuItem(value: "Paciente", child: Text("Paciente")),
                  DropdownMenuItem(value: "Médico", child: Text("Médico")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                validator: (value) {
                  if (value == null) return "Selecciona un rol";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // 🔥 BOTÓN LOGIN
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      UserCredential userCredential =
                          await _auth.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      final user = userCredential.user;

                      if (user != null) {
                        // 👇 Guardar el rol seleccionado en Firestore
                        await FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(user.uid)
                            .set({"rol": selectedRole}, SetOptions(merge: true));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Bienvenido ${user.email} | Rol: $selectedRole"),
                          ),
                        );

                        // 🔥 Navegación automática según el rol
                        if (selectedRole == "Médico") {
                          Navigator.pushReplacementNamed(context, Routes.dashboard);
                        } else {
                          Navigator.pushReplacementNamed(context, Routes.home);
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? "Error al iniciar sesión")),
                      );
                    }
                  }
                },
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
