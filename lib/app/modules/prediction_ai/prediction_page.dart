import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'prediction_controller.dart';

class PredictionPage extends StatelessWidget {
  const PredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PredictionController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }
        if (c.zones.isEmpty) {
          return _buildEmptyState();
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(c),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildZoneSelector(c),
                    const SizedBox(height: 16),
                    _buildRiskScoreCard(c),
                    const SizedBox(height: 16),
                    _buildHealthScoreCard(c),
                    const SizedBox(height: 16),
                    _buildAlertsSection(c),
                    const SizedBox(height: 16),
                    _buildHumidityChart(c),
                    const SizedBox(height: 16),
                    _buildPredictionsGrid(c),
                    const SizedBox(height: 16),
                    _buildNPKCard(c),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(PredictionController c) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1B5E20),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'ai_predictions'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.psychology,
                color: Colors.white.withOpacity(0.2),
                size: 80,
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => c.loadZoneData(c.selectedZoneIndex.value),
        ),
      ],
    );
  }

  // ── Sélecteur de zone ─────────────────────────────────────────────────────

  Widget _buildZoneSelector(PredictionController c) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: c.zones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = c.selectedZoneIndex.value == i;
          return GestureDetector(
            onTap: () => c.loadZoneData(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                c.zones[i]['name'] ?? 'Zone ${i + 1}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Score de risque ML ────────────────────────────────────────────────────

  Widget _buildRiskScoreCard(PredictionController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics, color: c.riskColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'risk_score'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              const Spacer(),
              // Badge qualité modèle R²
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'R² ${c.r2Humidity.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barre de progression du score
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: c.currentScore.value / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF38A169), c.riskColor],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${c.currentScore.value}/100',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: c.riskColor,
                ),
              ),
              // Intervalle de confiance humidité
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ic_humidity'.tr,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  Text(
                    '[${c.ciLow.value.toStringAsFixed(1)}% – ${c.ciHigh.value.toStringAsFixed(1)}%]',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B6CB0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Score de santé agronomique ────────────────────────────────────────────

  Widget _buildHealthScoreCard(PredictionController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: c.healthScore.value / 10,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  strokeWidth: 6,
                ),
                Text(
                  '${c.healthScore.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'health_score'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _healthLabel(c.healthScore.value),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(10, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        i < c.healthScore.value
                            ? Icons.circle
                            : Icons.circle_outlined,
                        color: Colors.white,
                        size: 10,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _healthLabel(int score) {
    if (score >= 8) return 'Excellent état agronomique';
    if (score >= 6) return 'État satisfaisant';
    if (score >= 4) return 'Attention recommandée';
    return 'Intervention urgente requise';
  }

  // ── Alertes et conseils ───────────────────────────────────────────────────

  Widget _buildAlertsSection(PredictionController c) {
    if (c.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'alerts_and_advices'.tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        ...c.alerts.map(
          (a) => _buildAlertTile(
            a['message'] as String,
            a['level'] as AlertLevel,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTile(String message, AlertLevel level) {
    final configs = {
      AlertLevel.success: (
        color: const Color(0xFF38A169),
        bg: const Color(0xFFF0FFF4),
        icon: Icons.check_circle_outline,
      ),
      AlertLevel.info: (
        color: const Color(0xFF3182CE),
        bg: const Color(0xFFEBF8FF),
        icon: Icons.info_outline,
      ),
      AlertLevel.warning: (
        color: const Color(0xFFDD6B20),
        bg: const Color(0xFFFFFAF0),
        icon: Icons.warning_amber_outlined,
      ),
      AlertLevel.danger: (
        color: const Color(0xFFE53E3E),
        bg: const Color(0xFFFFF5F5),
        icon: Icons.error_outline,
      ),
    };

    final cfg = configs[level]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cfg.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(cfg.icon, color: cfg.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cfg.color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Graphique humidité avec IC et prédiction ──────────────────────────────

  Widget _buildHumidityChart(PredictionController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop,
                  color: Color(0xFF3182CE), size: 20),
              const SizedBox(width: 8),
              Text(
                'humidity_trend'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              const Spacer(),
              _trendBadge(c.trendH.value, '%'),
            ],
          ),
          const SizedBox(height: 16),
          if (c.humidityHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'no_history'.tr,
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: CustomPaint(
                size: const Size(double.infinity, 140),
                painter: LineChartPainter(
                  values: c.humidityHistory,
                  color: const Color(0xFF3182CE),
                  fillColor:
                      const Color(0xFF3182CE).withOpacity(0.08),
                  predValue: c.predHumidity.value,
                  ciLow: c.ciLow.value,
                  ciHigh: c.ciHigh.value,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 16,
                  height: 3,
                  color:
                      const Color(0xFF3182CE).withOpacity(0.25)),
              const SizedBox(width: 6),
              Text(
                '${'confidence_interval'.tr} 95%',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 20),
              Container(
                  width: 16,
                  height: 3,
                  color: const Color(0xFFE53E3E)),
              const SizedBox(width: 6),
              Text(
                'prediction'.tr,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Badge tendance ─────────────────────────────────────────────────────────

  Widget _trendBadge(double trend, String unit) {
    final isUp = trend > 0;
    final isNeutral = trend.abs() < 0.1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNeutral
            ? Colors.grey.shade100
            : isUp
                ? const Color(0xFFF0FFF4)
                : const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNeutral
                ? Icons.remove
                : isUp
                    ? Icons.trending_up
                    : Icons.trending_down,
            size: 14,
            color: isNeutral
                ? Colors.grey
                : isUp
                    ? const Color(0xFF38A169)
                    : const Color(0xFFE53E3E),
          ),
          const SizedBox(width: 4),
          Text(
            '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isNeutral
                  ? Colors.grey
                  : isUp
                      ? const Color(0xFF38A169)
                      : const Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grille prédictions prochain cycle ─────────────────────────────────────

  Widget _buildPredictionsGrid(PredictionController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'next_cycle_predictions'.tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _predCard(
              icon: Icons.water_drop,
              label: 'humidity'.tr,
              value: '${c.predHumidity.value.toStringAsFixed(1)}%',
              trend: c.trendH.value,
              color: const Color(0xFF3182CE),
            ),
            _predCard(
              icon: Icons.thermostat,
              label: 'temperature'.tr,
              value: '${c.predTemp.value.toStringAsFixed(1)}°C',
              trend: c.trendT.value,
              color: const Color(0xFFDD6B20),
            ),
            _predCard(
              icon: Icons.electric_bolt,
              label: 'conductivity'.tr,
              value: '${c.predEc.value.toStringAsFixed(0)} µS',
              trend: c.trendEc.value,
              color: const Color(0xFF805AD5),
            ),
            _predCard(
              icon: Icons.science,
              label: 'pH',
              value: c.zones.isNotEmpty
                  ? (c.zones[c.selectedZoneIndex.value]['ph'] ?? '--')
                      .toString()
                  : '--',
              trend: 0,
              color: const Color(0xFF319795),
            ),
          ],
        ),
      ],
    );
  }

  Widget _predCard({
    required IconData icon,
    required String label,
    required String value,
    required double trend,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (trend != 0) _trendBadge(trend, ''),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Carte NPK ─────────────────────────────────────────────────────────────

  Widget _buildNPKCard(PredictionController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Color(0xFF38A169), size: 20),
              const SizedBox(width: 8),
              Text(
                'npk_predictions'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _npkRow('N', 'nitrogen'.tr, c.predN.value,
              c.trendN.value, 150, const Color(0xFF38A169)),
          const SizedBox(height: 12),
          _npkRow('P', 'phosphorus'.tr, c.predP.value,
              c.trendP.value, 100, const Color(0xFF805AD5)),
          const SizedBox(height: 12),
          _npkRow('K', 'potassium'.tr, c.predK.value,
              c.trendK.value, 200, const Color(0xFFDD6B20)),
        ],
      ),
    );
  }

  Widget _npkRow(String symbol, String label, double value,
      double trend, double maxVal, Color color) {
    final pct = (value / maxVal).clamp(0.0, 1.0);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            symbol,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5568))),
                  Text(
                    '${value.toStringAsFixed(1)} mg/kg',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _trendBadge(trend, ''),
      ],
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'no_zones'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — Graphique linéaire avec IC et point de prédiction
// ─────────────────────────────────────────────────────────────────────────────

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color fillColor;
  final double predValue;
  final double ciLow;
  final double ciHigh;

  const LineChartPainter({
    required this.values,
    required this.color,
    required this.fillColor,
    required this.predValue,
    required this.ciLow,
    required this.ciHigh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final allVals = [...values, predValue, ciLow, ciHigh];
    final minV = allVals.reduce((a, b) => a < b ? a : b) - 5;
    final maxV = allVals.reduce((a, b) => a > b ? a : b) + 5;
    final range = (maxV - minV).clamp(1.0, double.infinity);

    double toX(int i) =>
        i * size.width / (values.length.toDouble());
    double toY(double v) =>
        size.height - ((v - minV) / range * size.height);

    // ── Zone IC (bande translucide) ────────────────────────────────────────
    final ciPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final ciPath = Path()
      ..moveTo(toX(0), toY(ciHigh));
    for (var i = 0; i < values.length; i++) {
      ciPath.lineTo(toX(i), toY(ciHigh));
    }
    for (var i = values.length - 1; i >= 0; i--) {
      ciPath.lineTo(toX(i), toY(ciLow));
    }
    ciPath.close();
    canvas.drawPath(ciPath, ciPaint);

    // ── Aire sous la courbe ────────────────────────────────────────────────
    final fillPath = Path()
      ..moveTo(toX(0), size.height)
      ..lineTo(toX(0), toY(values[0]));
    for (var i = 1; i < values.length; i++) {
      final x0 = toX(i - 1);
      final y0 = toY(values[i - 1]);
      final x1 = toX(i);
      final y1 = toY(values[i]);
      fillPath.cubicTo(
        x0 + (x1 - x0) / 2, y0,
        x0 + (x1 - x0) / 2, y1,
        x1, y1,
      );
    }
    fillPath
      ..lineTo(toX(values.length - 1), size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fillColor..style = PaintingStyle.fill);

    // ── Courbe principale ──────────────────────────────────────────────────
    final linePath = Path()
      ..moveTo(toX(0), toY(values[0]));
    for (var i = 1; i < values.length; i++) {
      final x0 = toX(i - 1);
      final y0 = toY(values[i - 1]);
      final x1 = toX(i);
      final y1 = toY(values[i]);
      linePath.cubicTo(
        x0 + (x1 - x0) / 2, y0,
        x0 + (x1 - x0) / 2, y1,
        x1, y1,
      );
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // ── Point de prédiction avec ligne pointillée ──────────────────────────
    final predX = toX(values.length);
    final predY = toY(predValue);

    _drawDashed(
      canvas,
      Paint()
        ..color = const Color(0xFFE53E3E).withOpacity(0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
      toX(values.length - 1),
      toY(values.last),
      predX,
      predY,
    );

    // Cercle rouge = prédiction
    canvas.drawCircle(
      Offset(predX, predY),
      5,
      Paint()..color = const Color(0xFFE53E3E),
    );
    canvas.drawCircle(
      Offset(predX, predY),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDashed(Canvas canvas, Paint paint,
      double x1, double y1, double x2, double y2) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = (dx * dx + dy * dy).clamp(1.0, double.infinity);
    final ndx = dx / len * dashLen;
    final ndy = dy / len * dashLen;

    var cx = x1;
    var cy = y1;
    var drawn = 0.0;
    var drawing = true;

    while (drawn < len) {
      final ex = cx + ndx;
      final ey = cy + ndy;
      if (drawing) canvas.drawLine(Offset(cx, cy), Offset(ex, ey), paint);
      cx = ex + (drawing ? dx / len * gapLen : 0);
      cy = ey + (drawing ? dy / len * gapLen : 0);
      drawn += dashLen + (drawing ? gapLen : 0);
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(LineChartPainter old) =>
      old.values != values || old.predValue != predValue;
}