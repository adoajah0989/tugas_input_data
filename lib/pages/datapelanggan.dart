import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Customer {
  String kodePelanggan;
  String namaPelanggan;
  String NPWP;
  String alamat;

  Customer({
    required this.kodePelanggan,
    required this.namaPelanggan,
    required this.NPWP,
    required this.alamat,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        kodePelanggan: json['kodePelanggan'] as String,
        namaPelanggan: json['namaPelanggan'] as String,
        NPWP: json['NPWP'] as String,
        alamat: json['alamat'] as String,
      );

  Map<String, dynamic> toJson() => {
        'kodePelanggan': kodePelanggan,
        'namaPelanggan': namaPelanggan,
        'NPWP': NPWP,
        'alamat': alamat,
      };
}

class DataPelanggan extends StatefulWidget {
  @override
  _DataPelangganState createState() => _DataPelangganState();
}

class _DataPelangganState extends State<DataPelanggan> {
  List<Customer> customers = [];
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _NPWPController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String? _selectedKodePelanggan;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> _loadData() async {
    final snapshot = await db.collection('customers').get();
    setState(() {
      customers =
          snapshot.docs.map((doc) => Customer.fromJson(doc.data())).toList();
    });
  }

  Future<void> _saveData(Customer customer) async {
    await db.collection('customers').add(customer.toJson());
  }

  Future<void> _deleteData(String kodePelanggan) async {
    final snapshot = await db
        .collection('customers')
        .where('kodePelanggan', isEqualTo: kodePelanggan)
        .get();
    for (var doc in snapshot.docs) {
      await db.collection('customers').doc(doc.id).delete();
    }
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      icon: const Icon(Icons.check),
      primaryColor: Colors.green,
      backgroundColor: Colors.white,
      context: context,
      title: const Text('Data telah dihapus'),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void addCustomer() {
    final String namaPelanggan = _namaPelangganController.text;
    final String NPWP = _NPWPController.text;
    final String alamat = _alamatController.text;

    if (_selectedKodePelanggan == null ||
        namaPelanggan.isEmpty ||
        NPWP.isEmpty ||
        alamat.isEmpty) {
      showToast('Semua field harus diisi');
      return;
    }

    final newCustomer = Customer(
      kodePelanggan: _selectedKodePelanggan!,
      namaPelanggan: namaPelanggan,
      NPWP: NPWP,
      alamat: alamat,
    );

    setState(() {
      customers.add(newCustomer);
    });

    _namaPelangganController.clear();
    _NPWPController.clear();
    _alamatController.clear();
    _saveData(newCustomer);
  }

  void showToast(String message) {
    toastification.show(
      alignment: Alignment.bottomCenter,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      icon: const Icon(Icons.cancel),
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      dragToClose: true,
    );
  }

  void onChangedFunction(value) {
    setState(() {
      if (value != null) {
        _selectedKodePelanggan = value;
      } else {
        showToast('Nilai tidak boleh kosong');
      }
    });
  }

  void deleteCustomer(int index) {
    final customer = customers[index];
    setState(() {
      customers.removeAt(index);
    });
    _deleteData(customer.kodePelanggan);
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
        title: Text('Data Pelanggan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Kode Pelanggan: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          TextSpan(
                            text: customer.kodePelanggan,
                            style: const TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama Pelanggan: ${customer.namaPelanggan}'),
                        Text('NPWP: ${customer.NPWP}'),
                        Text('Alamat: ${customer.alamat}'),
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
                                'Apakah Anda yakin ingin menghapus data ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteCustomer(index);
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
                      value: _selectedKodePelanggan,
                      items: ["P001", "P002", "P003"]
                          .map(
                            (kode) => DropdownMenuItem<String>(
                              value: kode,
                              child: Text(kode),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          onChangedFunction(value);
                        });
                      },
                      decoration: InputDecoration(labelText: 'Kode Pelanggan'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _namaPelangganController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _NPWPController,
                      decoration: InputDecoration(
                        labelText: 'NPWP',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addCustomer();
                      Navigator.pop(context);
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
    home: DataPelanggan(),
  ));
}
