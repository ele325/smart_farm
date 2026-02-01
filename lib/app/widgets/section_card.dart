import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color titleColor;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.titleColor = Colors.green, // Couleur par défaut SmartFarm
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Bords très arrondis (Moderne)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Ombre très légère
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte avec le titre
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Contenu de la carte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: child,
          ),
        ],
      ),
    );
  }
}