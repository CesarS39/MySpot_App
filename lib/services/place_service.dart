import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/category.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseToken() async {
  final user = FirebaseAuth.instance.currentUser;
  return await user?.getIdToken();
}

class PlaceService {
  static const String baseUrl = "http://172.20.10.2:8000"; // IP de tu Mac

  static Future<List<Map<String, dynamic>>> fetchPopularPlaces() async {
    final token = await getFirebaseToken();
    final url = Uri.parse('$baseUrl/home/popular');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('POPULARES response: ${response.body}');

    if (response.statusCode == 200) {
      final List places = jsonDecode(response.body)["results"];
      return places.map<Map<String, dynamic>>((json) {
        return {
          ...json,
          "isLiked": json["isLiked"] ?? false,
        };
      }).toList();
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
      return places.map<Map<String, dynamic>>((json) {
        return {
          ...json,
          "isLiked": json["isLiked"] ?? false,
        };
      }).toList();
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
  static Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    final token = await getFirebaseToken();
    if (token == null) throw Exception("Usuario no autenticado");

    final url = Uri.parse('$baseUrl/places/$placeId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('DETALLE LUGAR response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar detalle del lugar: ${response.statusCode}');
    }
  }
  static Future<Map<String, dynamic>> fetchPlaceReviews(String placeId) async {
    final token = await getFirebaseToken();
    if (token == null) throw Exception("Usuario no autenticado");

    final url = Uri.parse('$baseUrl/places/$placeId/reviews');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('RESEÑAS response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al cargar reseñas: ${response.statusCode}');
    }
  }
  static Future<bool> togglePlaceLike(String placeId) async {
    final token = await getFirebaseToken();
    if (token == null) throw Exception("Usuario no autenticado");

    final url = Uri.parse('$baseUrl/places/$placeId/like');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['liked']; // true o false
    } else {
      throw Exception('Error al actualizar favorito');
    }
  }
  }
