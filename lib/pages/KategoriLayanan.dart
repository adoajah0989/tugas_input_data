import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toastification/toastification.dart';

class Task {
  String kodeKategori;
  String Nama_layanan;
  String referensi;
  String ukuran;
  int harga;

  Task({
    required this.kodeKategori,
    required this.Nama_layanan,
    required this.referensi,
    required this.ukuran,
    required this.harga,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        kodeKategori: json['kodeKategori'] as String,
        Nama_layanan: json['Nama_layanan'] as String,
        referensi: json['referensi'] as String,
        ukuran: json['ukuran'] as String,
        harga: json['harga'] as int,
      );

  Map<String, dynamic> toJson() => {
        'kodeKategori': kodeKategori,
        'Nama_layanan': Nama_layanan,
        'referensi': referensi,
        'ukuran': ukuran,
        'harga': harga,
      };
}

class KategoriLayanan extends StatefulWidget {
  @override
  _KategoriLayananState createState() => _KategoriLayananState();
}

class _KategoriLayananState extends State<KategoriLayanan> {
  List<Task> tasks = [];
  final TextEditingController _namaLayananController = TextEditingController();
  final TextEditingController _referensiController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String? _selectedKodeKategori;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getStringList('tasks');
    if (encodedData != null) {
      setState(() {
        tasks =
            encodedData.map((data) => Task.fromJson(jsonDecode(data))).toList();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = tasks.map((task) => jsonEncode(task.toJson())).toList();
    prefs.setStringList('tasks', encodedData);
  }

  void addTask() {
    final String Nama_layanan = _namaLayananController.text;
    final String referensi = _referensiController.text;
    final String ukuran = _ukuranController.text;
    final int harga = int.tryParse(_hargaController.text) ?? 0;

    if (_selectedKodeKategori == null ||
        Nama_layanan.isEmpty ||
        referensi.isEmpty ||
        ukuran.isEmpty ||
        harga == 0) {
      showToast('Semua field harus diisi');
      return;
    }

    final newTask = Task(
      kodeKategori: _selectedKodeKategori!,
      Nama_layanan: Nama_layanan,
      referensi: referensi,
      ukuran: ukuran,
      harga: harga,
    );

    setState(() {
      tasks.add(newTask);
    });

    _namaLayananController.clear();
    _referensiController.clear();
    _ukuranController.clear();
    _hargaController.clear();
  }

  void showToast(String message) {
    toastification.show(
      alignment: Alignment.bottomCenter,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      icon: const Icon(Icons.cancel),

      context: context, // optional if you use ToastificationWrapper
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      dragToClose: true,
    );
  }

  void onChangedFunction(value) {
    setState(() {
      if (value != null) {
        _selectedKodeKategori = value;
      } else {
        showToast('Nilai tidak boleh kosong');
      }
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    showToast('Data berhasil dihapus');

    _saveData();
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data saat aplikasi dimulai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Jenis Layanan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Kode Kategori: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          TextSpan(
                            text: task.kodeKategori,
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Layanan: ${task.Nama_layanan}'),
                        Text('Referensi: ${task.referensi}'),
                        Text('Ukuran: ${task.ukuran}'),
                        Text('Harga: ${task.harga}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Hapus Data'),
                              content: Text(
                                  'Apakah Anda yakin ingin menghapus data ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteTask(index);
                                    _saveData();
                                  },
                                  child: Text('Hapus'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Batal'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Tambah Data'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedKodeKategori,
                      items: ["K001", "K002", "K003"]
                          .map((kode) => DropdownMenuItem<String>(
                                value: kode,
                                child: Text(kode),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          onChangedFunction(value);
                        });
                      },
                      decoration:
                          InputDecoration(labelText: 'Kode Kategori Layanan'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _namaLayananController,
                      decoration: InputDecoration(
                        labelText: 'Nama Layanan',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _referensiController,
                      decoration: InputDecoration(
                        labelText: 'Referensi',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _ukuranController,
                      decoration: InputDecoration(
                        labelText: 'Ukuran',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addTask();
                      Navigator.pop(context);
                      _saveData();
                    },
                    child: Text('Tambah'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: KategoriLayanan(),
  ));
}
