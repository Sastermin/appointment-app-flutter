import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()!['nombre'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Mensaje de Bienvenida ---
              Text(
                '¡Hola, ${userName ?? 'Usuario'}!',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                '¿En qué podemos ayudarte?',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              //Widgets de Acción
              Row(
                children: [
                  Expanded(child: _buildActionCard(context, Icons.calendar_today, 'Agendar una Cita')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(context, Icons.lightbulb_outline, 'Consejos médicos')),
                ],
              ),
              const SizedBox(height: 32),

              // --- Sección de Especialistas ---
              _buildSectionTitle('Especialistas'),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSpecialistCard('Cardiología', 'assets/cardiologist.png'),
                    _buildSpecialistCard('Neurología', 'assets/neurologist.png'),
                    _buildSpecialistCard('Dermatología', 'assets/dermatologist.png'),
                    _buildSpecialistCard('Pediatría', 'assets/pediatrician.png'),
                    _buildSpecialistCard('Oftalmología', 'assets/ophthalmologist.png'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // --- Sección de Doctores Populares ---
              _buildSectionTitle('Popular Doctors'),
              _buildDoctorCard('Dr. Juan Pérez', 'Cardiólogo', 'assets/doctor1.jpg'),
              _buildDoctorCard('Dra. Ana García', 'Dermatóloga', 'assets/doctor2.jpg'),
              _buildDoctorCard('Dr. Carlos Ruiz', 'Pediatra', 'assets/doctor3.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets Reutilizables
  Widget _buildActionCard(BuildContext context, IconData icon, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildSpecialistCard(String specialty, String imagePath) {
    // NOTA: Debes agregar las imágenes a una carpeta `assets` en tu proyecto.
    return SizedBox(
      width: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(imagePath, height: 50), // Descomenta cuando agregues las imágenes
            const Icon(Icons.local_hospital, size: 40, color: Colors.blue), // Placeholder
            const SizedBox(height: 8),
            Text(specialty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(String name, String specialty, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        // leading: CircleAvatar(backgroundImage: AssetImage(imagePath)), // Descomenta con imágenes
        leading: const CircleAvatar(child: Icon(Icons.person)), // Placeholder
        title: Text(name),
        subtitle: Text(specialty),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}