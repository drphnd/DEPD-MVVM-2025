import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/repository/home_repository.dart';

// ViewModel untuk mengelola data dan state Home (provinsi, kota, ongkir)
class HomeViewModel with ChangeNotifier {
  // Repository untuk akses API
  final _homeRepo = HomeRepository();

  // ===============================================================
  // BAGIAN DOMESTIK (LAMA)
  // ===============================================================

  // State daftar provinsi
  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();
  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  // Ambil daftar provinsi
  Future getProvinceList() async {
    if (provinceList.status == Status.completed) return;
    setProvinceList(ApiResponse.loading());
    _homeRepo
        .fetchProvinceList()
        .then((value) {
          setProvinceList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setProvinceList(ApiResponse.error(error.toString()));
        });
  }

  // Cache kota per id provinsi agar tidak panggil API berulang
  final Map<int, List<City>> _cityCache = {};

  // State daftar kota asal
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();
  setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  // Ambil kota asal
  Future getCityOriginList(int provId) async {
    if (_cityCache.containsKey(provId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }
    setCityOriginList(ApiResponse.loading());
    _homeRepo
        .fetchCityList(provId)
        .then((value) {
          _cityCache[provId] = value;
          setCityOriginList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setCityOriginList(ApiResponse.error(error.toString()));
        });
  }

  // State daftar kota tujuan
  ApiResponse<List<City>> cityDestinationList = ApiResponse.notStarted();
  setCityDestinationList(ApiResponse<List<City>> response) {
    cityDestinationList = response;
    notifyListeners();
  }

  // Ambil kota tujuan
  Future getCityDestinationList(int provId) async {
    if (_cityCache.containsKey(provId)) {
      setCityDestinationList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }
    setCityDestinationList(ApiResponse.loading());
    _homeRepo
        .fetchCityList(provId)
        .then((value) {
          _cityCache[provId] = value;
          setCityDestinationList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setCityDestinationList(ApiResponse.error(error.toString()));
        });
  }

  // State daftar biaya ongkir (Domestik)
  ApiResponse<List<Costs>> costList = ApiResponse.notStarted();
  setCostList(ApiResponse<List<Costs>> response) {
    costList = response;
    notifyListeners();
  }

  // Flag loading umum
  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Hitung biaya pengiriman Domestik
  Future checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    setLoading(true);
    setCostList(ApiResponse.loading());
    _homeRepo
        .checkShipmentCost(
          origin,
          originType,
          destination,
          destinationType,
          weight,
          courier,
        )
        .then((value) {
          setCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }

  // ===============================================================
  // BAGIAN INTERNASIONAL (BARU) - Tambahkan ini untuk fix error
  // ===============================================================

  // 1. State daftar tujuan internasional (Hasil pencarian)
  ApiResponse<List<City>> internationalDestinationList = ApiResponse.notStarted();
  
  void setInternationalDestinationList(ApiResponse<List<City>> response) {
    internationalDestinationList = response;
    notifyListeners();
  }

  // Fungsi pencarian negara/kota tujuan
  Future<void> searchInternationalDestination(String query) async {
    // Jangan cari jika teks terlalu pendek
    if (query.length < 3) return; 

    // Set status loading khusus untuk dropdown pencarian
    setInternationalDestinationList(ApiResponse.loading());
    
    _homeRepo
        .fetchInternationalDestination(query)
        .then((value) {
          setInternationalDestinationList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setInternationalDestinationList(ApiResponse.error(error.toString()));
        });
  }

  // 2. State hasil ongkir internasional
  ApiResponse<List<Costs>> internationalCostList = ApiResponse.notStarted();
  
  void setInternationalCostList(ApiResponse<List<Costs>> response) {
    internationalCostList = response;
    notifyListeners();
  }

  // Fungsi Cek Ongkir Internasional
  Future<void> checkInternationalCost(
    String origin,
    String destination,
    int weight,
    String courier,
  ) async {
    setLoading(true); // Pakai loading global untuk memblokir layar
    setInternationalCostList(ApiResponse.loading());
    
    _homeRepo
        .checkInternationalCost(origin, destination, weight, courier)
        .then((value) {
          setInternationalCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setInternationalCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }
}