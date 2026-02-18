import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading; // Nouveau paramètre pour l'état de chargement

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false, // Par défaut, ce n'est pas en chargement
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        // On désactive le bouton (onTap = null) si isLoading est vrai
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.6),
        ),
        // Si isLoading est vrai, on affiche le cercle, sinon on affiche le texte
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
