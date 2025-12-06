import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:depd_mvvm_2025/data/app_exception.dart';
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';
import 'package:depd_mvvm_2025/shared/shared.dart';

class NetworkApiServices implements BaseApiServices {
  @override
  Future<dynamic> getApiResponse(String endpoint) async {
    try {
      // --- PERBAIKAN DI SINI ---
      // Menggunakan Uri.parse agar karakter '?' tidak di-encode menjadi '%3F'
      // Pastikan Const.subUrl sudah mengandung '/' di akhir (sesuai file const.dart kamu)
      final String fullUrl = "https://${Const.baseUrl}${Const.subUrl}$endpoint";
      final uri = Uri.parse(fullUrl);
      // -------------------------

      _logRequest('GET', uri, Const.apiKey);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
      );

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network request timeout!');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  @override
  Future<dynamic> postApiResponse(String endpoint, dynamic data) async {
    try {
      // Ubah juga di sini untuk konsistensi, meskipun POST jarang pakai query params di URL
      final String fullUrl = "https://${Const.baseUrl}${Const.subUrl}$endpoint";
      final uri = Uri.parse(fullUrl);

      _logRequest('POST', uri, Const.apiKey, data);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'key': Const.apiKey,
        },
        body: data,
      );

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('No internet connection!');
    } on TimeoutException {
      throw FetchDataException('Network request timeout!');
    } on FormatException {
      throw FetchDataException('Invalid response format!');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  void _logRequest(String method, Uri uri, String apiKey, [dynamic data]) {
    print("== $method REQUEST ==");
    print("Final URL ($method): $uri");
    if (data != null) {
      print("Data body: $data");
    }
    print("");
  }

  void _logResponse(int statusCode, String? contentType, String body) {
    // ... (kode _logResponse tetap sama)
    print("Status code: $statusCode");
    print("Content-Type: ${contentType ?? '-'}");
    if (body.isEmpty) {
      print("Body: <empty>");
    } else {
      print("Body: $body"); // Disederhanakan untuk contoh
    }
    print("");
  }

  dynamic _returnResponse(http.Response response) {
    _logResponse(
      response.statusCode,
      response.headers['content-type'],
      response.body,
    );

    switch (response.statusCode) {
      case 200:
        try {
          final decoded = jsonDecode(response.body);
          if (decoded == null) throw FetchDataException('Empty JSON');
          return decoded;
        } catch (_) {
          throw FetchDataException('Invalid JSON');
        }
      case 400:
        throw BadRequestException(response.body);
      case 404:
        throw NotFoundException('Not Found: ${response.body}');
      case 500:
        throw ServerErrorException('Server error: ${response.body}');
      default:
        throw FetchDataException(
          'Unexpected status ${response.statusCode}: ${response.body}',
        );
    }
  }
}