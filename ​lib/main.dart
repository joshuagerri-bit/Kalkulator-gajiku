import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const GajiApp());
}

class GajiApp extends StatelessWidget {
  const GajiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Gaji & Lembur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      home: const PayrollHomePage(),
    );
  }
}

class DailyAttendance {
  String date;
  int hadir;
  String ket;
  double ot1;
  double ot2;
  double ot3;

  DailyAttendance({
    required this.date,
    this.hadir = 1,
    this.ket = '',
    this.ot1 = 0,
    this.ot2 = 0,
    this.ot3 = 0,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'hadir': hadir,
        'ket': ket,
        'ot1': ot1,
        'ot2': ot2,
        'ot3': ot3,
      };

  factory DailyAttendance.fromJson(Map<String, dynamic> json) => DailyAttendance(
        date: json['date'] ?? '',
        hadir: json['hadir'] ?? 0,
        ket: json['ket'] ?? '',
        ot1: (json['ot1'] ?? 0).toDouble(),
        ot2: (json['ot2'] ?? 0).toDouble(),
        ot3: (json['ot3'] ?? 0).toDouble(),
      );
}

class CustomComponent {
  String label;
  double amount;

  CustomComponent({required this.label, required this.amount});

  Map<String, dynamic> toJson() => {'label': label, 'amount': amount};
  factory CustomComponent.fromJson(Map<String, dynamic> json) =>
      CustomComponent(
          label: json['label'] ?? '', amount: (json['amount'] ?? 0).toDouble());
}

class PayrollHomePage extends StatefulWidget {
  const PayrollHomePage({super.key});

  @override
  State<PayrollHomePage> createState() => _PayrollHomePageState();
}

class _PayrollHomePageState extends State<PayrollHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _idr =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final _companyCtrl = TextEditingController(text: 'PT. GEMAH RIPAH');
  final _projectCtrl =
      TextEditingController(text: 'PROYEK PT. BATARA ELOK SEMESTA TERPADU');
  final _nikCtrl = TextEditingController(text: '254023');
  final _nameCtrl = TextEditingController(text: 'MAICHEL GERRI JOSHUA');
  final _deptCtrl = TextEditingController(text: 'SHORTENING');
  final _periodCtrl =
      TextEditingController(text: '22 Ags 2025 s/d 21 Sep 2025');
  final _cityDateCtrl = TextEditingController(text: 'Gresik, 30 Sep 2025');
  final _makerCtrl = TextEditingController(text: 'Mujib Ahmad');

  final _rateHarianCtrl = TextEditingController(text: '162471');
  final _rateOt1Ctrl = TextEditingController(text: '42261');
  final _rateOt2Ctrl = TextEditingController(text: '56348');
  final _rateOt3Ctrl = TextEditingController(text: '84522');

  final _bpjsLabelCtrl =
      TextEditingController(text: 'BPJS Ket. Sept 2025 & BPJS Kes. Okt 2025');
  final _bpjsAmountCtrl = TextEditingController(text: '194965');
  final _pph21Ctrl = TextEditingController(text: '16250');

  final _alfaCtrl = TextEditingController(text: '0');
  final _izinCtrl = TextEditingController(text: '1');
  final _sakitCtrl = TextEditingController(text: '0');
  final _pulangAwalCtrl = TextEditingController(text: '0');
  final _telatCtrl = TextEditingController(text: '0');

  List<DailyAttendance> _attendanceList = [];
  List<CustomComponent> _extraIncomes = [];
  List<CustomComponent> _extraDeductions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDefaultOrSavedData();
  }

  List<DailyAttendance> _generateSamplePdfData() {
    return [
      DailyAttendance(date: '22 Ags 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '23 Ags 2025', hadir: 1, ot1: 1, ot2: 1),
      DailyAttendance(date: '24 Ags 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '25 Ags 2025', hadir: 0, ket: 'Izin', ot1: 0, ot2: 0),
      DailyAttendance(date: '26 Ags 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '27 Ags 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '28 Ags 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '29 Ags 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '30 Ags 2025', hadir: 1, ot1: 1, ot2: 5),
      DailyAttendance(date: '31 Ags 2025', hadir: 1, ot1: 1, ot2: 4),
      DailyAttendance(date: '01 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '02 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '03 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '04 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '05 Sep 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '06 Sep 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '07 Sep 2025', hadir: 1, ot1: 1, ot2: 4),
      DailyAttendance(date: '08 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '09 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '10 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '11 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '12 Sep 2025', hadir: 1, ot1: 1, ot2: 4),
      DailyAttendance(date: '13 Sep 2025', hadir: 1, ot1: 1, ot2: 5),
      DailyAttendance(date: '14 Sep 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '15 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '16 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '17 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '18 Sep 2025', hadir: 1, ot1: 1, ot2: 0),
      DailyAttendance(date: '19 Sep 2025', hadir: 1, ot1: 0, ot2: 0),
      DailyAttendance(date: '20 Sep 2025', hadir: 1, ot1: 1, ot2: 5),
      DailyAttendance(date: '21 Sep 2025', hadir: 1, ot1: 1, ot2: 4),
    ];
  }

  Future<void> _loadDefaultOrSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('payroll_data_v1');
    if (saved != null) {
      final data = jsonDecode(saved);
      setState(() {
        _companyCtrl.text = data['company'] ?? _companyCtrl.text;
        _projectCtrl.text = data['project'] ?? _projectCtrl.text;
        _nikCtrl.text = data['nik'] ?? _nikCtrl.text;
        _nameCtrl.text = data['name'] ?? _nameCtrl.text;
        _deptCtrl.text = data['dept'] ?? _deptCtrl.text;
        _periodCtrl.text = data['period'] ?? _periodCtrl.text;
        _cityDateCtrl.text = data['cityDate'] ?? _cityDateCtrl.text;
        _makerCtrl.text = data['maker'] ?? _makerCtrl.text;

        _rateHarianCtrl.text = data['rateHarian'] ?? _rateHarianCtrl.text;
        _rateOt1Ctrl.text = data['rateOt1'] ?? _rateOt1Ctrl.text;
        _rateOt2Ctrl.text = data['rateOt2'] ?? _rateOt2Ctrl.text;
        _rateOt3Ctrl.text = data['rateOt3'] ?? _rateOt3Ctrl.text;

        _bpjsLabelCtrl.text = data['bpjsLabel'] ?? _bpjsLabelCtrl.text;
        _bpjsAmountCtrl.text = data['bpjsAmount'] ?? _bpjsAmountCtrl.text;
        _pph21Ctrl.text = data['pph21'] ?? _pph21Ctrl.text;

        _alfaCtrl.text = data['alfa'] ?? '0';
        _izinCtrl.text = data['izin'] ?? '1';
        _sakitCtrl.text = data['sakit'] ?? '0';
        _pulangAwalCtrl.text = data['pulangAwal'] ?? '0';
        _telatCtrl.text = data['telat'] ?? '0';

        _attendanceList = (data['attendance'] as List)
            .map((e) => DailyAttendance.fromJson(e))
            .toList();
        _extraIncomes = (data['extraIncomes'] as List? ?? [])
            .map((e) => CustomComponent.fromJson(e))
            .toList();
        _extraDeductions = (data['extraDeductions'] as List? ?? [])
            .map((e) => CustomComponent.fromJson(e))
            .toList();
      });
    } else {
      setState(() {
        _attendanceList = _generateSamplePdfData();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'company': _companyCtrl.text,
      'project': _projectCtrl.text,
      'nik': _nikCtrl.text,
      'name': _nameCtrl.text,
      'dept': _deptCtrl.text,
      'period': _periodCtrl.text,
      'cityDate': _cityDateCtrl.text,
      'maker': _makerCtrl.text,
      'rateHarian': _rateHarianCtrl.text,
      'rateOt1': _rateOt1Ctrl.text,
      'rateOt2': _rateOt2Ctrl.text,
      'rateOt3': _rateOt3Ctrl.text,
      'bpjsLabel': _bpjsLabelCtrl.text,
      'bpjsAmount': _bpjsAmountCtrl.text,
      'pph21': _pph21Ctrl.text,
      'alfa': _alfaCtrl.text,
      'izin': _izinCtrl.text,
      'sakit': _sakitCtrl.text,
      'pulangAwal': _pulangAwalCtrl.text,
      'telat': _telatCtrl.text,
      'attendance': _attendanceList.map((e) => e.toJson()).toList(),
      'extraIncomes': _extraIncomes.map((e) => e.toJson()).toList(),
      'extraDeductions': _extraDeductions.map((e) => e.toJson()).toList(),
    };
    await prefs.setString('payroll_data_v1', jsonEncode(payload));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua perubahan berhasil disimpan!')),
      );
    }
  }

  int get totalHadir => _attendanceList.fold(0, (sum, item) => sum + item.hadir);
  double get totalOt1 => _attendanceList.fold(0.0, (sum, item) => sum + item.ot1);
  double get totalOt2 => _attendanceList.fold(0.0, (sum, item) => sum + item.ot2);
  double get totalOt3 => _attendanceList.fold(0.0, (sum, item) => sum + item.ot3);

  double get rateHarian => double.tryParse(_rateHarianCtrl.text) ?? 0;
  double get rateOt1 => double.tryParse(_rateOt1Ctrl.text) ?? 0;
  double get rateOt2 => double.tryParse(_rateOt2Ctrl.text) ?? 0;
  double get rateOt3 => double.tryParse(_rateOt3Ctrl.text) ?? 0;

  double get upahHarianTotal => totalHadir * rateHarian;
  double get lembur1Total => totalOt1 * rateOt1;
  double get lembur2Total => totalOt2 * rateOt2;
  double get lembur3Total => totalOt3 * rateOt3;
  double get extraIncomeTotal =>
      _extraIncomes.fold(0.0, (sum, item) => sum + item.amount);

  double get totalPendapatan =>
      upahHarianTotal +
      lembur1Total +
      lembur2Total +
      lembur3Total +
      extraIncomeTotal;

  double get bpjsTotal => double.tryParse(_bpjsAmountCtrl.text) ?? 0;
  double get pph21Total => double.tryParse(_pph21Ctrl.text) ?? 0;
  double get extraDeductionTotal =>
      _extraDeductions.fold(0.0, (sum, item) => sum + item.amount);

  double get totalPotongan => bpjsTotal + pph21Total + extraDeductionTotal;
  double get gajiBersih => totalPendapatan - totalPotongan;

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NIK: ${_nikCtrl.text}'),
                      pw.Text('Nama: ${_nameCtrl.text}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Bagian: ${_deptCtrl.text}'),
                      pw.Text('Periode: ${_periodCtrl.text}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(_companyCtrl.text,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text(_projectCtrl.text,
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['TANGGAL', 'ABSENSI', 'KET', 'OT1', 'OT2', 'OT3'],
                data: _attendanceList
                    .map((e) => [
                          e.date,
                          e.hadir == 1 ? '1' : '',
                          e.ket,
                          e.ot1 > 0 ? e.ot1.toStringAsFixed(0) : '',
                          e.ot2 > 0 ? e.ot2.toStringAsFixed(0) : '',
                          e.ot3 > 0 ? e.ot3.toStringAsFixed(0) : '',
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 12),
              pw.Text('PENDAPATAN',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Bullet(
                  text:
                      'Upah Harian ($totalHadir x ${_idr.format(rateHarian)}): ${_idr.format(upahHarianTotal)}'),
              pw.Bullet(
                  text:
                      'Lembur 1 (${totalOt1.toStringAsFixed(0)} x ${_idr.format(rateOt1)}): ${_idr.format(lembur1Total)}'),
              pw.Bullet(
                  text:
                      'Lembur 2 (${totalOt2.toStringAsFixed(0)} x ${_idr.format(rateOt2)}): ${_idr.format(lembur2Total)}'),
              pw.Bullet(
                  text:
                      'Lembur 3 (${totalOt3.toStringAsFixed(0)} x ${_idr.format(rateOt3)}): ${_idr.format(lembur3Total)}'),
              ..._extraIncomes.map((e) =>
                  pw.Bullet(text: '${e.label}: ${_idr.format(e.amount)}')),
              pw.SizedBox(height: 8),
              pw.Text('POTONGAN & PAJAK',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Bullet(
                  text: '${_bpjsLabelCtrl.text}: ${_idr.format(bpjsTotal)}'),
              pw.Bullet(text: 'Potongan PPh 21: ${_idr.format(pph21Total)}'),
              ..._extraDeductions.map((e) =>
                  pw.Bullet(text: '${e.label}: ${_idr.format(e.amount)}')),
              pw.Divider(),
              pw.Text('Gaji Bersih: ${_idr.format(gajiBersih)}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Text(_cityDateCtrl.text),
                    pw.Text('Maker'),
                    pw.SizedBox(height: 24),
                    pw.Text(_makerCtrl.text,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Slip Gaji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan Data',
            onPressed: _saveData,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Cetak / Export PDF',
            onPressed: _exportPdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: '1. Profil & Tarif'),
            Tab(icon: Icon(Icons.calendar_month), text: '2. Absensi & OT'),
            Tab(icon: Icon(Icons.tune), text: '3. Tambahan & Potongan'),
            Tab(icon: Icon(Icons.receipt_long), text: '4. Slip Gaji'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileAndRatesTab(),
          _buildAttendanceTab(),
          _buildComponentsTab(),
          _buildSlipPreviewTab(),
        ],
      ),
    );
  }

  Widget _buildProfileAndRatesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Identitas Perusahaan & Karyawan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
            controller: _companyCtrl,
            decoration: const InputDecoration(labelText: 'Nama Perusahaan'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        TextField(
            controller: _projectCtrl,
            decoration: const InputDecoration(labelText: 'Nama Proyek'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _nikCtrl,
                    decoration: const InputDecoration(labelText: 'NIK'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: TextField(
                    controller: _deptCtrl,
                    decoration: const InputDecoration(labelText: 'Bagian'),
                    onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama Karyawan'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        TextField(
            controller: _periodCtrl,
            decoration: const InputDecoration(labelText: 'Periode Gaji'),
            onChanged: (_) => setState(() {})),
        const Divider(height: 32),
        const Text('Pengaturan Tarif Upah & Lembur (Rp)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
            controller: _rateHarianCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tarif Upah Harian'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _rateOt1Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tarif OT 1'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _rateOt2Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tarif OT 2'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _rateOt3Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tarif OT 3'),
                    onChanged: (_) => setState(() {}))),
          ],
        ),
        const Divider(height: 32),
        const Text('Pengesahan Slip',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _cityDateCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Kota & Tanggal'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(
                child: TextField(
                    controller: _makerCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Maker'),
                    onChanged: (_) => setState(() {}))),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceTab() {
    return Column(
      children: [
        Container(
          color: Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hadir: $totalHadir hr | OT1: ${totalOt1.toStringAsFixed(0)} | OT2: ${totalOt2.toStringAsFixed(0)} | OT3: ${totalOt3.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _attendanceList.add(DailyAttendance(
                        date: 'Tgl Baru ${_attendanceList.length + 1}',
                        hadir: 1));
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Hari'),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _attendanceList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _attendanceList[index];
              return ListTile(
                dense: true,
                leading: Checkbox(
                  value: item.hadir == 1,
                  onChanged: (val) {
                    setState(() {
                      item.hadir = (val ?? false) ? 1 : 0;
                    });
                  },
                ),
                title: Text(item.date,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Ket: ${item.ket.isEmpty ? "-" : item.ket} | OT1: ${item.ot1.toStringAsFixed(0)}, OT2: ${item.ot2.toStringAsFixed(0)}, OT3: ${item.ot3.toStringAsFixed(0)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDayDialog(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDayDialog(int index) {
    final item = _attendanceList[index];
    final dateCtrl = TextEditingController(text: item.date);
    final ketCtrl = TextEditingController(text: item.ket);
    final ot1Ctrl = TextEditingController(text: item.ot1.toStringAsFixed(0));
    final ot2Ctrl = TextEditingController(text: item.ot2.toStringAsFixed(0));
    final ot3Ctrl = TextEditingController(text: item.ot3.toStringAsFixed(0));
    int hadirVal = item.hadir;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Data Harian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(labelText: 'Tanggal')),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Status Hadir (1)'),
                  value: hadirVal == 1,
                  onChanged: (v) => setDialogState(() => hadirVal = v ? 1 : 0),
                ),
                TextField(
                    controller: ketCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Keterangan (Izin/Sakit/Alfa)')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: ot1Ctrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'OT 1'))),
                    const SizedBox(width: 6),
                    Expanded(
                        child: TextField(
                            controller: ot2Ctrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'OT 2'))),
                    const SizedBox(width: 6),
                    Expanded(
                        child: TextField(
                            controller: ot3Ctrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'OT 3'))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _attendanceList.removeAt(index);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item.date = dateCtrl.text;
                  item.hadir = hadirVal;
                  item.ket = ketCtrl.text;
                  item.ot1 = double.tryParse(ot1Ctrl.text) ?? 0;
                  item.ot2 = double.tryParse(ot2Ctrl.text) ?? 0;
                  item.ot3 = double.tryParse(ot3Ctrl.text) ?? 0;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Potongan Utama & Pajak',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
            controller: _bpjsLabelCtrl,
            decoration: const InputDecoration(labelText: 'Keterangan BPJS'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        TextField(
            controller: _bpjsAmountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nominal BPJS (Rp)'),
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 10),
        TextField(
            controller: _pph21Ctrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Potongan PPh 21 (Rp)'),
            onChanged: (_) => setState(() {})),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pengembalian Dana / Tunjangan Lain',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _addCustomItemDialog(isIncome: true),
            ),
          ],
        ),
        ..._extraIncomes.asMap().entries.map((entry) => ListTile(
              title: Text(entry.value.label),
              trailing: Text(_idr.format(entry.value.amount)),
              onLongPress: () =>
                  setState(() => _extraIncomes.removeAt(entry.key)),
            )),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Potongan Tambahan Lain',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red),
              onPressed: () => _addCustomItemDialog(isIncome: false),
            ),
          ],
        ),
        ..._extraDeductions.asMap().entries.map((entry) => ListTile(
              title: Text(entry.value.label),
              trailing: Text(_idr.format(entry.value.amount)),
              onLongPress: () =>
                  setState(() => _extraDeductions.removeAt(entry.key)),
            )),
        const Divider(height: 32),
        const Text('Rekap Catatan Absensi (Bawah Slip)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _alfaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Alfa (X)'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _izinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Izin (X)'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _sakitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sakit (X)'),
                    onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _pulangAwalCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Pulang Awal (X)'),
                    onChanged: (_) => setState(() {}))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _telatCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Telat Masuk (X)'),
                    onChanged: (_) => setState(() {}))),
          ],
        ),
      ],
    );
  }

  void _addCustomItemDialog({required bool isIncome}) {
    final labelCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isIncome ? 'Tambah Pendapatan' : 'Tambah Potongan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Nama Komponen')),
            const SizedBox(height: 8),
            TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final item = CustomComponent(
                label: labelCtrl.text,
                amount: double.tryParse(amountCtrl.text) ?? 0,
              );
              setState(() {
                if (isIncome) {
                  _extraIncomes.add(item);
                } else {
                  _extraDeductions.add(item);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_companyCtrl.text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(_projectCtrl.text, style: const TextStyle(fontSize: 12)),
              const Divider(),
              Text('NIK: ${_nikCtrl.text} | Bagian: ${_deptCtrl.text}'),
              Text('Nama: ${_nameCtrl.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Periode: ${_periodCtrl.text}'),
              const Divider(height: 24),
              const Text('PENDAPATAN',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _rowSlip('Upah Harian ($totalHadir x ${_idr.format(rateHarian)})',
                  upahHarianTotal),
              _rowSlip(
                  'Lembur 1 (${totalOt1.toStringAsFixed(0)} x ${_idr.format(rateOt1)})',
                  lembur1Total),
              _rowSlip(
                  'Lembur 2 (${totalOt2.toStringAsFixed(0)} x ${_idr.format(rateOt2)})',
                  lembur2Total),
              _rowSlip(
                  'Lembur 3 (${totalOt3.toStringAsFixed(0)} x ${_idr.format(rateOt3)})',
                  lembur3Total),
              ..._extraIncomes.map((e) => _rowSlip(e.label, e.amount)),
              const Divider(height: 24),
              const Text('POTONGAN & PAJAK',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _rowSlip(_bpjsLabelCtrl.text, bpjsTotal),
              _rowSlip('Potongan PPh 21', pph21Total),
              ..._extraDeductions.map((e) => _rowSlip(e.label, e.amount)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GAJI BERSIH',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(_idr.format(gajiBersih),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                  'Alfa: ${_alfaCtrl.text}X | Izin: ${_izinCtrl.text}X | Sakit: ${_sakitCtrl.text}X | Pulang Awal: ${_pulangAwalCtrl.text}X | Telat: ${_telatCtrl.text}X',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak / Simpan sebagai PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowSlip(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title)),
          Text(_idr.format(amount)),
        ],
      ),
    );
  }
}
