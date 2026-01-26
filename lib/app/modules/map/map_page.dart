import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Map')),
      body: Center(
        child: Icon(Icons.map, size: 120, color: Colors.green),
      ),
    );
  }
}
