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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchHistory(zoneId, controller.selectedPeriod.value);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("${'history'.tr} - $zoneName"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _buildPeriodSelector(controller, zoneId),
              const SizedBox(height: 20),

              if (controller.historyRecords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        const Icon(Icons.analytics_outlined, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("no_data_period".tr, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Graphique 1 : Environnement
                    _buildChartCard(
                      "chart_env_title".tr,
                      [
                        _lineData(controller.historyRecords, (d) => d.humidity.toDouble(), Colors.blue),
                        _lineData(controller.historyRecords, (d) => d.temperature.toDouble(), Colors.orange),
                        _lineData(controller.historyRecords, (d) => d.ph.toDouble(), Colors.green),
                      ],
                      [
                        {'color': Colors.blue, 'label': 'hum_short'.tr},
                        {'color': Colors.orange, 'label': 'temp_short'.tr},
                        {'color': Colors.green, 'label': 'ph_short'.tr},
                      ],
                      controller,
                    ),

                    // Graphique 2 : Nutriments (NPK, EC)
                    _buildChartCard(
                      "chart_nutrients_title".tr,
                      [
                        _lineData(controller.historyRecords, (d) => d.azote.toDouble(), Colors.red),
                        _lineData(controller.historyRecords, (d) => d.phosphore.toDouble(), Colors.yellow),
                        _lineData(controller.historyRecords, (d) => d.potassium.toDouble(), Colors.purple),
                        _lineData(controller.historyRecords, (d) => d.ec.toDouble(), Colors.brown),
                      ],
                      [
                        {'color': Colors.red, 'label': 'N'},
                        {'color': Colors.yellow, 'label': 'P'},
                        {'color': Colors.purple, 'label': 'K'},
                        {'color': Colors.brown, 'label': 'ec_short'.tr},
                      ],
                      controller,
                    ),

                    // Graphique 3 : Consommation d'eau
                    _buildChartCard(
                      "chart_water_title".tr,
                      [
                        _lineData(
                          controller.historyRecords, 
                          (d) => d.waterConsumption.toDouble(), 
                          Colors.cyan, 
                          isArea: true
                        ),
                      ],
                      [
                        {'color': Colors.cyan, 'label': 'water_volume_label'.tr},
                      ],
                      controller,
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector(HistoryController controller, String zoneId) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("analysis_period".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => DropdownButton<int>(
              value: controller.selectedPeriod.value,
              underline: Container(),
              items: [
                DropdownMenuItem(value: 24, child: Text("24_hours".tr)),
                DropdownMenuItem(value: 168, child: Text("7_days".tr)),
                DropdownMenuItem(value: 720, child: Text("30_days".tr)),
              ],
              onChanged: (val) {
                if (val != null) {
                  controller.selectedPeriod.value = val;
                  controller.fetchHistory(zoneId, val);
                }
              },
            )),
          ],
        ),
      ),
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
              child: LineChart(
                LineChartData(
                  lineBarsData: lines,
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (controller.historyRecords.length / 5).clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < controller.historyRecords.length) {
                            DateTime date = controller.historyRecords[index].time;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("${date.day}/${date.month}", style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingVerticalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.3))),
                ),
              ),
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
      spacing: 15, runSpacing: 5,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(item['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      )).toList(),
    );
  }

  LineChartBarData _lineData(RxList<dynamic> data, double Function(dynamic) getY, Color color, {bool isArea = false}) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), getY(e.value))).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: isArea, color: color.withOpacity(0.2)),
    );
  }
}