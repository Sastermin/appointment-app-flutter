import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores de los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();

  bool _loading = false;
  // _loading es un interruptor visual:
  // /true -> muestra un "Cargando..." y bloquea la UI.
  // /false -> muestra la pantalla normal.

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  // Aquí creamos la clase que cargará los datos del usuario al iniciar.

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      telefonoController.text = data['telefono'] ?? '';
      enfermedadesController.text = data['enfermedades'] ?? ''; // NUEVO (antes historial medico)
    }
  }

  // Guardar datos del usuario en Firestore
  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nombre': nombreController.text.trim(),
      'telefono': telefonoController.text.trim(),
      'enfermedades': enfermedadesController.text.trim(), // NUEVO (antes historial medico)
      'email': user.email,
      'uid': user.uid,
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Información guardada exitosamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Correo: ${user?.email ?? 'No disponible'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    // Text
                    const SizedBox(height: 20),

                    // FORMULARIO
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: "Nombre completo"),
                    ), // TextField
                    const SizedBox(height: 10),

                    TextField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: "Teléfono"),
                      keyboardType: TextInputType.phone,
                    ), // TextField
                    const SizedBox(height: 10),

                    TextField(
                      controller: enfermedadesController, // NUEVO (antes historialController)
                      decoration: const InputDecoration(labelText: "Enfermedades"), // NUEVO
                      maxLines: 3,
                    ), // TextField
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text("Guardar información"),
                    ), // ElevatedButton
                    const SizedBox(height: 30),

                    // Botón para volver al menú principal
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Volver al Menú Principal"),
                    ), // ElevatedButton

                    const SizedBox(height: 20),

                    // Botón para cerrar sesión
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        // Comprobamos que el widget sigue "montado" antes de usar el BuildContext
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, Routes.login);
                      },
                      child: const Text("Cerrar sesión"),
                    ), // ElevatedButton
                  ],
                ), // Column
              ), // SingleChildScrollView
            ), // Padding
    ); // Scaffold
  }
}