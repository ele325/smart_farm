import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'variateur_control_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/info_card.dart';
import '../../widgets/section_title.dart'; 
class VariateurPage extends StatefulWidget {
  const VariateurPage({super.key});

  @override
  State<VariateurPage> createState() => _VariateurPageState();
}

class _VariateurPageState extends State<VariateurPage> {
  final VariateurControlController _controller = VariateurControlController();
  bool _loading = false;
  double? _tempFreq; // Pour éviter que le slider saute pendant le drag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text("vfd_control".tr), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _controller.variateurStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          bool isSwitched = data['isOn'] ?? false;
          double currentFreq = (data['frequency'] ?? 0.0).toDouble();
          
          double displayFreq = _tempFreq ?? currentFreq;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InfoCard(
                  title: "pump_current_state".tr,
                  value: isSwitched ? "running".tr : "stopped".tr,
                  icon: Icons.settings_input_component,
                  statusColor: isSwitched ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: "actuator".tr,
                  child: AppButton(
                    title: isSwitched ? "stop_pump".tr : "start_pump".tr,
                    isLoading: _loading,
                    onTap: () async {
                      setState(() => _loading = true);
                      await _controller.sendCommand(displayFreq, !isSwitched);
                      setState(() => _loading = false);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: "freq_config".tr,
                  child: Column(
                    children: [
                      Text("${displayFreq.toStringAsFixed(1)} Hz", 
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Slider(
                        value: displayFreq,
                        min: 0, max: 50, divisions: 50,
                        onChanged: (val) => setState(() => _tempFreq = val),
                        onChangeEnd: (val) {
                          _controller.sendCommand(val, isSwitched);
                          setState(() => _tempFreq = null);
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _presetChip(20, "low_flow".tr, isSwitched),
                          _presetChip(35, "normal_flow".tr, isSwitched),
                          _presetChip(50, "boost_flow".tr, isSwitched),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _presetChip(double val, String label, bool isSwitched) {
    return ActionChip(
      label: Text("$label ($val Hz)"),
      onPressed: () => _controller.sendCommand(val, isSwitched),
      backgroundColor: Colors.white,
    );
  }
}