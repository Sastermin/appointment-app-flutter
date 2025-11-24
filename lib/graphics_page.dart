import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphicsPage extends StatefulWidget {
  @override
  _GraphicsPageState createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, int>> getAppointmentsPerMonth() async {
    final snapshot = await _db.collection('appointments').get();

    Map<String, int> monthCount = {};

    for (var doc in snapshot.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      String month = "${date.month}-${date.year}";

      monthCount.update(month, (value) => value + 1, ifAbsent: () => 1);
    }

    return monthCount;
  }

  Future<Map<String, int>> getStatusCount() async {
    final snapshot = await _db.collection('appointments').get();

    int completed = 0;
    int cancelled = 0;

    for (var doc in snapshot.docs) {
      if (doc['status'] == "completed") completed++;
      if (doc['status'] == "cancelled") cancelled++;
    }

    return {
      "Completadas": completed,
      "Canceladas": cancelled,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Estadísticas Médicas")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            // -------- BAR CHART --------
            Text("Citas por Mes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            FutureBuilder<Map<String, int>>(
              future: getAppointmentsPerMonth(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final data = snapshot.data!;
                final keys = data.keys.toList();
                final values = data.values.toList();

                return Container(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: List.generate(data.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [BarChartRodData(toY: values[index].toDouble(), color: Colors.blue)],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(keys[value.toInt()]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 50),

            // -------- PIE CHART --------
            Text("Citas Completadas vs Canceladas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            FutureBuilder<Map<String, int>>(
              future: getStatusCount(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final data = snapshot.data!;
                final keys = data.keys.toList();
                final values = data.values.toList();

                return Container(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: List.generate(data.length, (index) {
                        return PieChartSectionData(
                          value: values[index].toDouble(),
                          title: "${keys[index]} (${values[index]})",
                          radius: 60,
                          color: index == 0 ? Colors.green : Colors.red,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
