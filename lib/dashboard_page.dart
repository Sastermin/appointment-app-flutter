import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_bloc.dart';
import 'routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, int>> getAppointmentsPerMonth() async {
    final snapshot = await FirebaseFirestore.instance.collection('citas').get();
    Map<String, int> monthCount = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['fechaHora'] != null) {
        DateTime date = (data['fechaHora'] as Timestamp).toDate();
        String month = "${date.month}-${date.year}";
        monthCount.update(month, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return monthCount;
  }

  Future<Map<String, int>> getPatientsPerMonth() async {
    final snapshot = await FirebaseFirestore.instance.collection('citas').get();
    Map<String, Set<String>> monthPatients = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['fechaHora'] != null && data['usuarioId'] != null) {
        DateTime date = (data['fechaHora'] as Timestamp).toDate();
        String month = "${date.month}-${date.year}";

        if (!monthPatients.containsKey(month)) {
          monthPatients[month] = {};
        }
        monthPatients[month]!.add(data['usuarioId'].toString());
      }
    }

    // Convertir a conteo de pacientes únicos
    Map<String, int> result = {};
    monthPatients.forEach((month, patients) {
      result[month] = patients.length;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeClaro = Color(0xFF9FE2BF);
    const Color verdeOscuro = Color(0xFF3E8E41);
    const Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Dashboard Médico",
          style: TextStyle(
            color: blanco,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: verdeOscuro,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: blanco),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3E8E41),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con gradiente
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [verdeOscuro, verdeClaro],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Bienvenido Doctor!',
                          style: TextStyle(
                            color: blanco,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Panel de control y estadísticas',
                          style: TextStyle(
                            color: blanco.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Estadísticas en grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          title: 'Total de Citas',
                          value: state.totalCitas.toString(),
                          icon: Icons.calendar_today,
                          color: verdeOscuro,
                          lightColor: verdeClaro,
                        ),
                        _buildStatCard(
                          title: 'Pacientes',
                          value: state.totalPacientes.toString(),
                          icon: Icons.people,
                          color: Colors.blue[700]!,
                          lightColor: Colors.blue[100]!,
                        ),
                        _buildStatCard(
                          title: 'Esta Semana',
                          value: '0',
                          icon: Icons.event_available,
                          color: Colors.orange[700]!,
                          lightColor: Colors.orange[100]!,
                        ),
                        _buildStatCard(
                          title: 'Pendientes',
                          value: '0',
                          icon: Icons.pending_actions,
                          color: Colors.purple[700]!,
                          lightColor: Colors.purple[100]!,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Gráfica de citas por mes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: blanco,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart, color: verdeOscuro, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'Citas por Mes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<Map<String, int>>(
                            future: getAppointmentsPerMonth(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final data = snapshot.data!;
                              if (data.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text('No hay datos disponibles'),
                                  ),
                                );
                              }

                              final keys = data.keys.toList();
                              final values = data.values.toList();

                              return SizedBox(
                                height: 250,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: List.generate(
                                      data.length,
                                      (index) => BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: values[index].toDouble(),
                                            color: verdeOscuro,
                                            width: 20,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, _) {
                                            if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  keys[value.toInt()],
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey[300],
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) => Colors.grey[800]!,
                                        tooltipRoundedRadius: 8,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${keys[groupIndex]}\n${rod.toY.toInt()} citas',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gráfica de líneas - Pacientes atendidos por mes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: blanco,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people_outline, color: Colors.blue[700], size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'Pacientes Atendidos por Mes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<Map<String, int>>(
                            future: getPatientsPerMonth(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final data = snapshot.data!;
                              if (data.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text('No hay datos disponibles'),
                                  ),
                                );
                              }

                              final keys = data.keys.toList();
                              final values = data.values.toList();

                              return SizedBox(
                                height: 250,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey[300],
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, _) {
                                            if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  keys[value.toInt()],
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: (keys.length - 1).toDouble(),
                                    minY: 0,
                                    maxY: values.isEmpty ? 1 : (values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List.generate(
                                          keys.length,
                                          (index) => FlSpot(
                                            index.toDouble(),
                                            values[index].toDouble(),
                                          ),
                                        ),
                                        isCurved: true,
                                        color: Colors.blue[700],
                                        barWidth: 4,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 6,
                                              color: Colors.blue[700]!,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue[700]!.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) => Colors.grey[800]!,
                                        tooltipRoundedRadius: 8,
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            return LineTooltipItem(
                                              '${keys[spot.x.toInt()]}\n${spot.y.toInt()} pacientes',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Sin datos para mostrar"));
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
