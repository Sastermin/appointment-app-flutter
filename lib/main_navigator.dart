import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'settings_page.dart';
import 'graphics_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _userRole = doc.data()?['rol'] ?? 'Paciente';
          _isLoading = false;
        });
      }
    }
  }

  List<Widget> _getWidgetOptions() {
    if (_userRole == 'Médico') {
      return [
        HomePage(),
        MessagesPage(),
        GraphicsPage(),
        SettingsPage(),
      ];
    } else {
      // Para pacientes: sin Gráficas
      return [
        HomePage(),
        MessagesPage(),
        SettingsPage(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavBarItems() {
    if (_userRole == 'Médico') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Gráficas'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
      ];
    } else {
      // Para pacientes: sin Gráficas
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }

    final widgetOptions = _getWidgetOptions();
    final navBarItems = _getNavBarItems();

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
