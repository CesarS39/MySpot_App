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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen + botones
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(imagePath),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.favorite, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Título y rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Show map", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 18),
                  const SizedBox(width: 4),
                  Text('$rating (355 Reviews)', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),

              // Descripción
              Text(description),
              const SizedBox(height: 10),
              const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  FacilityIcon(label: "1 Heater", icon: Icons.ac_unit),
                  FacilityIcon(label: "Dinner", icon: Icons.restaurant),
                  FacilityIcon(label: "1 Tub", icon: Icons.bathtub),
                  FacilityIcon(label: "Pool", icon: Icons.pool),
                ],
              ),
              const SizedBox(height: 20),

              // Precio + Botón
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\$${price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text("Book Now"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FacilityIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const FacilityIcon({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
