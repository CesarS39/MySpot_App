import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {

  final String imagePath;
  final String title;
  final double rating;
  final String description;
  final double price;

  const PlaceDetailScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.rating,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen principal
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(imagePath),
                ),
                const SizedBox(height: 20),

                // Título y botón favorito
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.favorite, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow),
                    const SizedBox(width: 4),
                    Text(
                      "$rating (355 Reviews)",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Descripción
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Facilities (ejemplo visual, puedes personalizar)
                const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    FacilityIcon(icon: Icons.heat_pump, label: "Heater"),
                    FacilityIcon(icon: Icons.restaurant, label: "Dinner"),
                    FacilityIcon(icon: Icons.hot_tub, label: "Tub"),
                    FacilityIcon(icon: Icons.pool, label: "Pool"),
                  ],
                ),
                const SizedBox(height: 30),

                // Precio y botón
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$$price",
                      style: const TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Book Now", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FacilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
