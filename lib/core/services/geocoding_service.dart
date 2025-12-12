import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // Usa a API gratuita do OpenStreetMap (Nominatim)
  static Future<LatLng?> getCoordinates(String address) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');
      
      final response = await http.get(url, headers: {
        // O Nominatim exige um User-Agent para não bloquear a requisição
        'User-Agent': 'TaViajandoApp/1.0', 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
      return null;
    }
  }
}