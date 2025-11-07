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

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nombreController.text = data['nombre'] ?? '';
      telefonoController.text = data['telefono'] ?? '';
      enfermedadesController.text = data['enfermedades'] ?? '';
    }
  }

  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nombre': nombreController.text.trim(),
      'telefono': telefonoController.text.trim(),
      'enfermedades': enfermedadesController.text.trim(),
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
      //AppBar verde con texto blanco y título centrado
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      //Fondo blanco
      backgroundColor: Colors.white,

      body: _loading //Cargar indicador si está en proceso
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Encabezado con correo del usuario en contenedor verde muy claro
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Correo: ${user?.email ?? 'No disponible'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de texto Nombre
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: "Nombre completo",
                        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF81C784)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF388E3C)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Campo de texto Teléfono
                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Teléfono",
                        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF81C784)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF388E3C)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Campo de texto Enfermedades
                    TextField(
                      controller: enfermedadesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Enfermedades",
                        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF81C784)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF388E3C)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //Botón guardar datos verde con texto blanco y bordes redondeados
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Guardar información",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón volver al menú principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Volver al Menú Principal",
                          style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //Botón cerrar sesión rojo con texto blanco
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, Routes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cerrar sesión",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
