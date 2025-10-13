import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: Center(
        child: const Text(
          "Nombre: Darío González",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
