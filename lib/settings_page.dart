import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Colores del tema consistentes con las demás pantallas
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: blanco, //Fondo blanco limpio
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: blanco, // Texto blanco sobre fondo verde oscuro
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 6,
        backgroundColor: verdeOscuro, //CAMBIO: Fondo verde oscuro del AppBar
      ),

      //Fondo suave y lista con tarjetas limpias
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [blanco, verdeClaro.withOpacity(0.15)], // degradado sutil
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            //Encabezado visual superior
            const Icon(Icons.settings, size: 80, color: verdeOscuro),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Ajustes de tu cuenta",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: verdeOscuro,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- Perfil ---
            _buildSettingTile(
              context,
              icon: Icons.person_outline,
              title: "Perfil",
              color: verdeOscuro,
              onTap: () {
                Navigator.pushNamed(context, Routes.profile);
              },
            ),

            // --- Privacidad ---
            _buildSettingTile(
              context,
              icon: Icons.lock_outline,
              title: "Privacidad",
              color: verdeOscuro,
              onTap: () {},
            ),

            // --- Sobre nosotros ---
            _buildSettingTile(
              context,
              icon: Icons.info_outline,
              title: "Sobre nosotros",
              color: verdeOscuro,
              onTap: () {},
            ),

            const SizedBox(height: 15),

            // --- Botón de Cerrar sesión ---
            Card(
              color: blanco,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.login, (Route<dynamic> route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Widget reutilizable para cada opción de configuración
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3, // sombra ligera
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }
}
