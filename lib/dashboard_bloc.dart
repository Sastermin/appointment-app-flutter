import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalCitas;
  final int totalPacientes;

  DashboardLoaded({required this.totalCitas, required this.totalPacientes});
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardBloc extends Cubit<DashboardState> {
  DashboardBloc() : super(DashboardLoading()) {
    _loadDashboardData();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _loadDashboardData() async {
    try {
      final citasSnapshot = await _db.collection("citas").get();
      final pacientes = <String>{};

      for (final doc in citasSnapshot.docs) {
        final data = doc.data();
        final pacienteId = data['usuarioId'] ?? data['pacienteId'];
        if (pacienteId != null) {
          pacientes.add(pacienteId.toString());
        }
      }

      emit(DashboardLoaded(
        totalCitas: citasSnapshot.size,
        totalPacientes: pacientes.length,
      ));
    } catch (e) {
      emit(DashboardError('No se pudieron cargar las estadísticas'));
    }
  }
}
