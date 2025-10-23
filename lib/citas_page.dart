import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => CitasPageState();
}

class CitasPageState extends State<CitasPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController motivoController = TextEditingController();

  String? nombreUsuario;
  DateTime? fechaSeleccionada;
  String? citaEnEdicion; // ID de la cita que estamos editando

  @override
  void initState() {
    super.initState();
    cargarNombreUsuario();
  }

  // Cargar el nombre del usuario desde Firestore
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

  // Seleccionar fecha y hora
  Future<void> seleccionarFechaYHora() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(fechaSeleccionada ?? DateTime.now()),
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

  // Agregar o actualizar cita
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
    
    // Este bloque viene de una imagen separada y parece ser parte de otra función
    // o el final de la función guardarCita. Lo coloco aquí como una pieza suelta.
    motivoController.clear();
    setState(() {
      fechaSeleccionada = null;
      citaEnEdicion = null;
    });
  }

  // Eliminar cita
  Future<void> eliminarCita(String id) async {
    await firestore.collection('citas').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita eliminada')));
  }

  // Preparar cita para edición
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
      appBar: AppBar(
        title: const Text('Citas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              nombreUsuario == null
                  ? 'Cargando...'
                  : 'Usuario: $nombreUsuario',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(labelText: 'Motivo de la cita'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaSeleccionada == null
                        ? 'No se ha seleccionado fecha y hora'
                        : 'Fecha: ${fechaSeleccionada.toString()}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: seleccionarFechaYHora,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: guardarCita,
              child: Text(citaEnEdicion == null ? 'Programar cita' : 'Guardar cambios'),
            ),
            const SizedBox(height: 20),
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
                    return const Center(child: Text('No hay citas programadas'));
                  }

                  return ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      final data = cita.data() as Map<String, dynamic>;
                      final fecha = (data['fechaHora'] as Timestamp?)?.toDate();

                      return Card(
                        child: ListTile(
                          title: Text("${data['motivo'] ?? 'Sin motivo'} (${data['nombreUsuario'] ?? 'Desconocido'})"),
                          subtitle: Text('Fecha: ${fecha ?? 'Sin fecha'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
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