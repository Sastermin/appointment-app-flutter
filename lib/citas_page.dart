import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController motivoController = TextEditingController();

  String? nombreUsuario;
  DateTime? fechaSeleccionada;
  String? citaEnEdicion;

  @override
  void initState() {
    super.initState();
    cargarNombreUsuario();
  }

  Future<void> cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          nombreUsuario = doc.data()!['nombre'] ?? 'Usuario sin nombre';
        });
      }
    }
  }

  Future<void> seleccionarFechaYHora() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),

      //Personalización del selector de fecha con verde claro
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4CAF50), // Verde principal
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(fechaSeleccionada ?? DateTime.now()),

        //Tema verde para el selector de hora
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          fechaSeleccionada = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> guardarCita() async {
    if (motivoController.text.isEmpty || fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final data = {
      'nombreUsuario': nombreUsuario ?? 'Sin nombre',
      'motivo': motivoController.text.trim(),
      'fechaHora': Timestamp.fromDate(fechaSeleccionada!),
      'creadoEn': FieldValue.serverTimestamp(),
    };

    if (citaEnEdicion == null) {
      await firestore.collection('citas').add(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada')));
    } else {
      await firestore.collection('citas').doc(citaEnEdicion).update(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita actualizada')));
    }

    motivoController.clear();
    setState(() {
      fechaSeleccionada = null;
      citaEnEdicion = null;
    });
  }

  Future<void> eliminarCita(String id) async {
    await firestore.collection('citas').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita eliminada')));
  }

  void editarCita(String id, Map<String, dynamic> data) {
    setState(() {
      citaEnEdicion = id;
      motivoController.text = data['motivo'] ?? '';
      fechaSeleccionada = (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar verde con texto blanco
      appBar: AppBar(
        title: const Text('Citas'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // 🌿 NUEVO: Fondo blanco con borde redondeado
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Encabezado estilizado con nombre del usuario
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Verde muy claro
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                nombreUsuario == null
                    ? 'Cargando...'
                    : '👤 Usuario: $nombreUsuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Campo de texto con borde verde y fondo blanco
            TextField(
              controller: motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo de la cita',
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

            const SizedBox(height: 12),

            // Selector de fecha estilizado
            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaSeleccionada == null
                        ? 'No se ha seleccionado fecha y hora'
                        : '📅 ${fechaSeleccionada.toString()}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                  onPressed: seleccionarFechaYHora,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botón verde con texto blanco
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardarCita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  citaEnEdicion == null ? 'Programar Cita' : 'Guardar Cambios',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Lista con diseño limpio
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('citas')
                    .orderBy('fechaHora', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final citas = snapshot.data!.docs;

                  if (citas.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay citas programadas 🗓️',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      final data = cita.data() as Map<String, dynamic>;
                      final fecha = (data['fechaHora'] as Timestamp?)?.toDate();

                      return Card(
                        color: const Color(0xFFF1F8E9), // Fondo verde pálido
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            "${data['motivo'] ?? 'Sin motivo'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '👤 ${data['nombreUsuario'] ?? 'Desconocido'}\n📅 ${fecha ?? 'Sin fecha'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF388E3C)),
                                onPressed: () => editarCita(cita.id, data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => eliminarCita(cita.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
