import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history_controller.dart';

class HistoryPage extends StatelessWidget {
  final String zoneName;
  final String zoneId;

  const HistoryPage({super.key, required this.zoneName, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    controller.fetchHistory(zoneId);

    return Scaffold(
      appBar: AppBar(
        title: Text("Historique - $zoneName"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.historyRecords.isEmpty) {
            return const Center(child: Text("Aucune donnée enregistrée dans l'historique"));
          }

          return Column(
            children: [
              Text("Analyse de l'humidité (%)", 
                style: TextStyle(fontSize: 18, color: Colors.green[900], fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: true, 
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1)),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.historyRecords.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Données provenant du capteur BGT-SMPS", 
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ],
          );
        }),
      ),
    );
  }
}