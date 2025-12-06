part of 'pages.dart';

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  late HomeViewModel homeViewModel;
  final weightController = TextEditingController();
  
  // Controller untuk input pencarian negara tujuan
  final searchController = TextEditingController();

  // Opsi kurir internasional (biasanya Pos Indonesia & TIKI support internasional di RajaOngkir Basic)
  final List<String> courierOptions = ["pos", "tiki"];
  String selectedCourier = "pos";

  // State ID
  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  int? selectedDestinationId; // ID Negara/Kota Tujuan

  @override
  void initState() {
    super.initState();
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    // Load provinsi jika belum ada (untuk dropdown asal)
    if (homeViewModel.provinceList.status == Status.notStarted) {
      homeViewModel.getProvinceList();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Ongkir Internasional"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === CARD FORM INPUT ===
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- SECTION ORIGIN (ASAL) ---
                        const Text(
                          "Asal Pengiriman (Indonesia)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        
                        // Dropdown Provinsi Asal
                        Consumer<HomeViewModel>(
                          builder: (context, vm, _) {
                            final provinces = vm.provinceList.data ?? [];
                            return DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Provinsi Asal",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              value: selectedProvinceOriginId,
                              items: provinces.map((p) {
                                return DropdownMenuItem<int>(
                                  value: p.id,
                                  child: Text(p.name ?? '', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (newId) {
                                setState(() {
                                  selectedProvinceOriginId = newId;
                                  selectedCityOriginId = null;
                                });
                                if (newId != null) vm.getCityOriginList(newId);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Kota Asal
                        Consumer<HomeViewModel>(
                          builder: (context, vm, _) {
                            final cities = vm.cityOriginList.data ?? [];
                            // Validasi agar value dropdown konsisten
                            final validId = cities.any((c) => c.id == selectedCityOriginId) 
                                ? selectedCityOriginId 
                                : null;

                            return DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Kota Asal",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              value: validId,
                              items: cities.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name ?? '', overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (newId) {
                                setState(() => selectedCityOriginId = newId);
                              },
                            );
                          },
                        ),
                        
                        const Divider(height: 30),

                        // --- SECTION DESTINATION (TUJUAN) ---
                        // Konsep "Direct Search"
                        const Text(
                          "Tujuan Pengiriman (Luar Negeri)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        
                        // Input Search & Button
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: "Cari Negara/Kota Tujuan",
                                  hintText: "Contoh: Singapore",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      if (searchController.text.length >= 3) {
                                        // Panggil fungsi search di ViewModel
                                        homeViewModel.searchInternationalDestination(searchController.text);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Masukkan minimal 3 karakter")),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                onSubmitted: (val) {
                                  if (val.length >= 3) homeViewModel.searchInternationalDestination(val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Dropdown Hasil Pencarian Tujuan
                        Consumer<HomeViewModel>(
                          builder: (context, vm, _) {
                            if (vm.internationalDestinationList.status == Status.loading) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              );
                            }
                            
                            final destinations = vm.internationalDestinationList.data ?? [];
                            
                            if (vm.internationalDestinationList.status == Status.completed && destinations.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("Tujuan tidak ditemukan.", style: TextStyle(color: Colors.red)),
                              );
                            }

                            if (destinations.isEmpty) return const SizedBox.shrink();

                            // Reset selection if not in new list
                            final validDest = destinations.any((d) => d.id == selectedDestinationId) 
                                ? selectedDestinationId 
                                : null;

                            return DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Pilih Hasil Pencarian",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.blue[50],
                              ),
                              value: validDest,
                              items: destinations.map((d) {
                                return DropdownMenuItem<int>(
                                  value: d.id,
                                  child: Text(d.name ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => selectedDestinationId = val);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // --- BERAT & KURIR ---
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Berat (gram)",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Kurir",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                value: selectedCourier,
                                items: courierOptions.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => selectedCourier = val ?? "pos");
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Tombol Hitung
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedCityOriginId != null &&
                                  selectedDestinationId != null &&
                                  weightController.text.isNotEmpty) {
                                
                                homeViewModel.checkInternationalCost(
                                  selectedCityOriginId.toString(),
                                  selectedDestinationId.toString(),
                                  int.parse(weightController.text),
                                  selectedCourier,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Mohon lengkapi data asal, tujuan, dan berat.")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Cek Ongkir Internasional", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === HASIL LIST ONGKIR ===
                const Text("Hasil Ongkir:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                
                Consumer<HomeViewModel>(
                  builder: (context, vm, _) {
                    if (vm.internationalCostList.status == Status.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vm.internationalCostList.status == Status.error) {
                      return Center(
                        child: Text(vm.internationalCostList.message ?? "Terjadi kesalahan", style: const TextStyle(color: Colors.red)),
                      );
                    }
                    if (vm.internationalCostList.status == Status.completed) {
                      final costs = vm.internationalCostList.data ?? [];
                      if (costs.isEmpty) {
                        return const Center(child: Text("Tidak ada layanan tersedia."));
                      }
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: costs.length,
                        itemBuilder: (context, index) {
                          // Reuse CardCost widget
                          return CardCost(costs[index]);
                        },
                      );
                    }
                    return const SizedBox.shrink(); // Not started
                  },
                ),
              ],
            ),
          ),
          
          // Loading Overlay Global
          Consumer<HomeViewModel>(
            builder: (context, vm, _) {
              return vm.isLoading
                  ? Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator()))
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}