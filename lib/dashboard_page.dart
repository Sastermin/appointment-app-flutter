import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Médico")),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text("Total de citas"),
                      trailing: Text(
                        state.totalCitas.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: Text("Pacientes atendidos"),
                      trailing: Text(
                        state.totalPacientes.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: Text("Sin datos para mostrar"));
        },
      ),
    );
  }
}
