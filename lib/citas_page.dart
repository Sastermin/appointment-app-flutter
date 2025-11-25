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
  String? rolUsuario;
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
          rolUsuario = doc.data()!['rol'] ?? 'Paciente';
        });
      }
    }
  }

  // Obtener stream de citas filtrado según el rol del usuario
  Stream<QuerySnapshot> _getCitasStream() {
    final user = FirebaseAuth.instance.currentUser;

    // Si el usuario es Médico, mostrar todas las citas
    if (rolUsuario == 'Médico') {
      return firestore
          .collection('citas')
          .orderBy('fechaHora', descending: false)
          .snapshots();
    }

    // Si es Paciente, mostrar solo sus propias citas
    return firestore
        .collection('citas')
        .where('usuarioId', isEqualTo: user?.uid)
        .orderBy('fechaHora', descending: false)
        .snapshots();
  }

  Future<void> seleccionarFechaYHora() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4CAF50),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(fechaSeleccionada ?? DateTime.now()),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final data = {
      'nombreUsuario': nombreUsuario ?? 'Sin nombre',
      'motivo': motivoController.text.trim(),
      'fechaHora': Timestamp.fromDate(fechaSeleccionada!),
      'usuarioId': user?.uid,
      'creadoEn': FieldValue.serverTimestamp(),
    };

    if (citaEnEdicion == null) {
      await firestore.collection('citas').add(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cita creada')));
    } else {
      await firestore.collection('citas').doc(citaEnEdicion).update(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cita actualizada')));
    }

    motivoController.clear();
    setState(() {
      fechaSeleccionada = null;
      citaEnEdicion = null;
    });
  }

  Future<void> eliminarCita(String id) async {
    await firestore.collection('citas').doc(id).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cita eliminada')));
  }

  void editarCita(String id, Map<String, dynamic> data) {
    setState(() {
      citaEnEdicion = id;
      motivoController.text = data['motivo'] ?? '';
      fechaSeleccionada =
          (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now();
    });
  }

  // MÉTODO DE REFRESH: se activa al hacer pull-to-refresh
  Future<void> _refrescarCitas() async {
    setState(() {}); // fuerza recarga del StreamBuilder
    await Future.delayed(const Duration(milliseconds: 800));

    // SNACKBAR DE CONFIRMACIÓN VISUAL
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Lista de citas actualizada correctamente'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
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

            // REFRESH INDICATOR: arrastra hacia abajo para actualizar
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refrescarCitas,
                color: const Color(0xFF4CAF50),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getCitasStream(),
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

                        //DISMISSIBLE: permite eliminar deslizando
                        return Dismissible(
                          key: Key(cita.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => eliminarCita(cita.id),

                          // GESTURE DETECTOR: permite editar tocando
                          child: GestureDetector(
                            onTap: () => editarCita(cita.id, data),
                            child: Card(
                              color: const Color(0xFFF1F8E9),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  "${data['motivo'] ?? 'Sin motivo'}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '👤 ${data['nombreUsuario'] ?? 'Desconocido'}\n📅 ${fecha ?? 'Sin fecha'}',
                                ),
                                trailing: const Icon(Icons.edit,
                                    color: Color(0xFF388E3C)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
