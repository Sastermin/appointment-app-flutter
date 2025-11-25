import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? rol; // 👉 Guardará "Paciente" o "Médico"
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();

      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()!['nombre'];
          rol = doc.data()!['rol'] ?? "Paciente"; // 👈 Nuevo
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        title: const Text(
          "Menú Principal",
          style: TextStyle(
            color: blanco,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: verdeOscuro,
        elevation: 6,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: blanco),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: rol == null 
      ? const Center(child: CircularProgressIndicator()) 
      : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                '¡Hola, ${userName ?? 'Usuario'}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: verdeOscuro,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rol: $rol 👤',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: verdeClaro.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.health_and_safety, size: 60, color: verdeOscuro),
                    const SizedBox(height: 10),
                    const Text(
                      'DoctorAppointmentApp',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 🚀 BOTÓN DINÁMICO SEGÚN ROL
                    ElevatedButton.icon(
                      onPressed: () {
                        if (rol == "Médico") {
                          Navigator.pushNamed(context, Routes.dashboard);
                        } else {
                          Navigator.pushNamed(context, Routes.citas);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, color: blanco),
                      label: Text(
                        rol == "Médico" 
                          ? 'Ver citas (Médico)' 
                          : 'Agregar cita',
                        style: const TextStyle(fontSize: 18, color: blanco),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeOscuro,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              _buildSectionTitle('Especialistas', verdeOscuro),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSpecialistCard('Cardiología', Icons.favorite, verdeClaro, verdeOscuro),
                    _buildSpecialistCard('Neurología', Icons.psychology, verdeClaro, verdeOscuro),
                    _buildSpecialistCard('Dermatología', Icons.spa, verdeClaro, verdeOscuro),
                    _buildSpecialistCard('Pediatría', Icons.child_care, verdeClaro, verdeOscuro),
                    _buildSpecialistCard('Oftalmología', Icons.remove_red_eye, verdeClaro, verdeOscuro),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              _buildSectionTitle('Doctores Populares', verdeOscuro),
              _buildDoctorCard('Dr. Juan Pérez', 'Cardiólogo', Icons.male, verdeClaro, verdeOscuro),
              _buildDoctorCard('Dra. Ana García', 'Dermatóloga', Icons.female, verdeClaro, verdeOscuro),
              _buildDoctorCard('Dr. Carlos Ruiz', 'Pediatra', Icons.male, verdeClaro, verdeOscuro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(String specialty, IconData icon, Color verdeClaro, Color verdeOscuro) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: verdeClaro.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: verdeClaro.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: verdeOscuro),
          const SizedBox(height: 8),
          Text(
            specialty,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(String name, String specialty, IconData icon, Color verdeClaro, Color verdeOscuro) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: verdeClaro,
          child: Icon(icon, color: verdeOscuro),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: verdeOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(specialty),
        trailing: Icon(Icons.arrow_forward_ios, color: verdeOscuro),
      ),
    );
  }
}
