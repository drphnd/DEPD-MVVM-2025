part of 'widgets.dart';

class CardCost extends StatefulWidget {
  final Costs cost;
  const CardCost(this.cost, {super.key});

  @override
  State<CardCost> createState() => _CardCostState();
}

class _CardCostState extends State<CardCost> {
  // Format Mata Uang
  String rupiahMoneyFormatter(int? value) {
    if (value == null) return "Rp0,00";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Format Estimasi Hari
  String formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    String formatted = etd.replaceAll('day', 'hari').replaceAll('days', 'hari');
    // Jika formatnya angka saja (misal "2"), tambahkan "hari"
    if (!formatted.toLowerCase().contains('hari')) {
      formatted = "$formatted hari";
    }
    return formatted;
  }

  // Menampilkan Bottom Sheet Detail
  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView( // Agar aman jika layar kecil
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER (Icon + Nama Kurir + Tombol Close) ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.local_shipping, color: Colors.blue[800]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cost.name ?? "-",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            widget.cost.service ?? "-",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // --- DETAIL INFORMASI ---
                _buildDetailRow("Nama Kurir", widget.cost.name),
                _buildDetailRow("Kode", widget.cost.code?.toUpperCase()),
                _buildDetailRow("Layanan", widget.cost.service),
                _buildDetailRow("Deskripsi", widget.cost.description),
                _buildDetailRow("Biaya", rupiahMoneyFormatter(widget.cost.cost)),
                _buildDetailRow("Estimasi Pengiriman", formatEtd(widget.cost.etd)),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget bantuan untuk membuat baris detail rapi
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Lebar label agar sejajar
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.black)),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? "-" : value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Costs cost = widget.cost;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailModal(context), // Panggil modal baru
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.local_shipping, color: Colors.blue[800]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${cost.name} (${cost.service})",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Biaya: ${rupiahMoneyFormatter(cost.cost)}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Estimasi sampai: ${formatEtd(cost.etd)}",
                      style: TextStyle(color: Colors.green[800], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ketuk untuk detail",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}