import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history_controller.dart';

class HistoryPage extends StatelessWidget {
  // 1. AJOUT DES PARAMÈTRES DANS LA CLASSE
  final String zoneName;
  final String zoneId;

  // 2. MISE À JOUR DU CONSTRUCTEUR (C'est ce qui manquait !)
  HistoryPage({
    super.key, 
    required this.zoneName, 
    required this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    // On n'a plus besoin de récupérer les arguments ici car ils sont dans le constructeur
    final controller = Get.put(HistoryController());
    
    // Charger les données dès que la page s'affiche
    if (zoneId.isNotEmpty) controller.fetchHistory(zoneId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${'history'.tr} - $zoneName"),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Humidité sur les dernières 24h", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.historyRecords.isEmpty) return const Center(child: Text("Aucune donnée enregistrée"));

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: true),
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.historyRecords.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.humidity.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: Colors.blue..withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}