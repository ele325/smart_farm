import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historical Data')),
      body: Center(
        child: Text(
          'Charts will appear here\n(Humidity / Temperature)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
