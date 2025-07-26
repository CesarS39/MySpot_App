import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed; // NO debe ser opcional ni permitir null

  const SocialButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key); // ✅ NO uses const en `onPressed` ni pongas null
  //     👆 Esta línea está bien. El error no está aquí.

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed, // Asegúrate de que siempre se le pase una función válida
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}