import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/category.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseToken() async {
  final user = FirebaseAuth.instance.currentUser;
  return await user?.getIdToken();
}

class PlaceService {
  static const String baseUrl = "http://192.168.100.105:8000"; // IP de tu Mac

  static Future<List<Map<String, dynamic>>> fetchPopularPlaces() async {
    final token = await getFirebaseToken();
    final url = Uri.parse('$baseUrl/home/popular'); // Ya no incluye ?city=

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('POPULARES response: ${response.body}');

    if (response.statusCode == 200) {
      final List places = jsonDecode(response.body)["results"];
      return places.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar lugares populares: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNearbyPlaces(double lat, double lng) async {
    final token = await getFirebaseToken();
    final url = Uri.parse('$baseUrl/home/nearby?latitude=$lat&longitude=$lng');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('CERCANOS response: ${response.body}');

    if (response.statusCode == 200) {
      final List places = jsonDecode(response.body)["results"];
      return places.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar lugares cercanos: ${response.statusCode}');
    }
  }

  static Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/home/categories');
    final token = await getFirebaseToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Categorías response: ${response.body}'); // 👈 Imprime aquí

    if (response.statusCode == 200) {
      final List categories = jsonDecode(response.body)["results"];
      return categories.map((cat) => CategoryModel.fromJson(cat)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}