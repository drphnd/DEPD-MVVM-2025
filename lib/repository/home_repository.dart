import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart';

class HomeRepository {
  final _apiServices = NetworkApiServices();

  // ===============================================================
  // DOMESTIK (Tetap sama, tidak berubah)
  // ===============================================================

  Future<List<Province>> fetchProvinceList() async {
    final response = await _apiServices.getApiResponse('destination/province');
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }
    final data = response['data'];
    if (data is! List) return [];
    return data.map((e) => Province.fromJson(e)).toList();
  }

  Future<List<City>> fetchCityList(var provId) async {
    final response = await _apiServices.getApiResponse(
      'destination/city/$provId',
    );
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }
    final data = response['data'];
    if (data is! List) return [];
    return data.map((e) => City.fromJson(e)).toList();
  }

  Future<List<Costs>> checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    final response = await _apiServices
        .postApiResponse('calculate/domestic-cost', { // Sesuai Postman: 'calculate/domestic-cost'
          "origin": origin,
          "destination": destination,
          "weight": weight.toString(),
          "courier": courier,
        });

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }
    final data = response['data'];
    if (data is! List) return [];
    return data.map((e) => Costs.fromJson(e)).toList();
  }

  // ===============================================================
  // INTERNASIONAL (Sesuai File Postman Anda)
  // ===============================================================

  // 1. Cari Tujuan Internasional
  // URL Postman: https://rajaongkir.komerce.id/api/v1/destination/international-destination
  Future<List<City>> fetchInternationalDestination(String query) async {
    final response = await _apiServices.getApiResponse(
      'destination/international-destination?search=$query', 
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    // Mapping hasil JSON ke model City
    // Postman response: [{"country_id": "1", "country_name": "Singapore"}, ...]
    return data.map((e) => City(
      id: int.tryParse(e['country_id'].toString()), // Convert string "1" jadi int 1
      name: e['country_name'],
    )).toList();
  }

  // 2. Cek Ongkir Internasional
  // URL Postman: https://rajaongkir.komerce.id/api/v1/calculate/international-cost
  Future<List<Costs>> checkInternationalCost(
    String origin,
    String destination,
    int weight,
    String courier,
  ) async {
    final response = await _apiServices.postApiResponse(
      'calculate/international-cost', 
      {
        "origin": origin,
        "destination": destination, // ID Negara tujuan
        "weight": weight.toString(),
        "courier": courier,
      },
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }
}