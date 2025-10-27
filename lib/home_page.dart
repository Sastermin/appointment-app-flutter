import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart'; // Importa el archivo donde defines tus rutas de navegación

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Color? get blanco => null;

  @override
  void initState() { // Inicializa el estado y carga los datos del usuario
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async { // Carga el nombre del usuario desde Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get(); // Asegúrate de que la colección y el campo coincidan con la base de datos
      if (doc.exists && mounted) { 
        setState(() {
          userName = doc.data()!['nombre'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores de tema consistentes con la app
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: blanco, //Fondo limpio y brillante
      appBar: AppBar(
        title: const Text(
          "Menú Principal",
          style: TextStyle(
            color: blanco,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Elimina el botón de retroceso
        backgroundColor: verdeOscuro, //Fondo verde oscuro
        elevation: 6, //Sombra suave para dar profundidad
        centerTitle: true,
      ),
      body: SafeArea( // Evita áreas no seguras de la pantalla
        child: SingleChildScrollView( // Permite desplazamiento si el contenido es largo
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Saludo Personalizado ---
              Text(
                '¡Hola, ${userName ?? 'Usuario'}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: verdeOscuro, //Verde principal para destacar
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿En qué podemos ayudarte?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),

              //Tarjeta principal de bienvenida
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
                      'DoctorAppointmentApp de prueba',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // --- Botón para ir a la pantalla de citas ---
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.citas);
                      },
                      icon: const Icon(Icons.calendar_today, color: blanco),
                      label: const Text(
                        'Gestionar Citas',
                        style: TextStyle(fontSize: 18, color: blanco),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdeOscuro, // verde oscuro principal
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

              // --- Sección de Especialistas ---
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

              // --- Sección de Doctores Populares ---
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

  // --- Widgets Reutilizables Mejorados con diseño ---

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

  //Tarjetas horizontales con colores suaves y sombras
  Widget _buildSpecialistCard(
    String specialty,
    IconData icon,
    Color verdeClaro,
    Color verdeOscuro,
  ) {
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

  // Tarjeta de doctor con estilo visual más atractivo
  Widget _buildDoctorCard(
    String name,
    String specialty,
    IconData icon,
    Color verdeClaro,
    Color verdeOscuro,
  ) {
    return Card(
      color: blanco,
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
        onTap: () {},
      ),
    );
  }
}
