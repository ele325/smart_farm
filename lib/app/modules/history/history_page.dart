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
    controller.fetchHistory(zoneId, 24);

    return Scaffold(
      appBar: AppBar(
        title: Text("Historique - $zoneName"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.historyRecords.isEmpty) return const Center(child: Text("Aucune donnée disponible"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _buildPeriodSelector(controller, zoneId),
              const SizedBox(height: 20),

              _buildChartCard("Environnement (Hum, Temp, pH)", [
                _lineData(controller.historyRecords, (d) => d.humidity, Colors.blue),
                _lineData(controller.historyRecords, (d) => d.temperature, Colors.orange),
                _lineData(controller.historyRecords, (d) => d.ph, Colors.green),
              ], [
                {'color': Colors.blue, 'label': 'Hum %'},
                {'color': Colors.orange, 'label': 'Temp °C'},
                {'color': Colors.green, 'label': 'pH'},
              ], controller),

              _buildChartCard("Nutriments & Sol (NPK, EC)", [
                _lineData(controller.historyRecords, (d) => d.azote, Colors.red),
                _lineData(controller.historyRecords, (d) => d.phosphore, Colors.yellow),
                _lineData(controller.historyRecords, (d) => d.potassium, Colors.purple),
                _lineData(controller.historyRecords, (d) => d.ec, Colors.brown),
              ], [
                {'color': Colors.red, 'label': 'N'},
                {'color': Colors.yellow, 'label': 'P'},
                {'color': Colors.purple, 'label': 'K'},
                {'color': Colors.brown, 'label': 'EC'},
              ], controller),

              _buildChartCard("Consommation d'eau (m³)", [
                _lineData(controller.historyRecords, (d) => d.waterConsumption, Colors.cyan, isArea: true),
              ], [
                {'color': Colors.cyan, 'label': 'Volume m³'},
              ], controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChartCard(String title, List<LineChartBarData> lines, List<Map<String, dynamic>> legendItems, HistoryController controller) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(LineChartData(
                lineBarsData: lines,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < controller.historyRecords.length) {
                          DateTime date = controller.historyRecords[index].time;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingVerticalLine: (v) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2), // ✅ FIX
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3), // ✅ FIX
                  ),
                ),
              )),
            ),
            const SizedBox(height: 15),
            _buildLegend(legendItems),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 15,
      runSpacing: 5,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(item['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      )).toList(),
    );
  }

  LineChartBarData _lineData(RxList<HistoryData> data, double Function(HistoryData) getY, Color color, {bool isArea = false}) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), getY(e.value))).toList(),
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: isArea,
        color: color.withValues(alpha: 0.2), // ✅ FIX
      ),
    );
  }

  Widget _buildPeriodSelector(HistoryController controller, String zoneId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Période d'analyse :", style: TextStyle(fontWeight: FontWeight.bold)),
        Obx(() => DropdownButton<int>(
          value: controller.selectedPeriod.value,
          items: const [
            DropdownMenuItem(value: 24, child: Text("24 Heures")),
            DropdownMenuItem(value: 168, child: Text("7 Jours")),
          ],
          onChanged: (val) {
            if (val != null) controller.fetchHistory(zoneId, val);
          },
        )),
      ],
    );
  }
}