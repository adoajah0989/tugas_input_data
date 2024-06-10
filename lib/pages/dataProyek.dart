import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';

class Customer {
  String pelangganProyek;
  String pelanggan;
  String telpFax;
  String email;

  Customer({
    required this.pelangganProyek,
    required this.pelanggan,
    required this.telpFax,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        pelangganProyek: json['pelangganProyek'] as String,
        pelanggan: json['pelanggan'] as String,
        telpFax: json['telpFax'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'pelangganProyek': pelangganProyek,
        'pelanggan': pelanggan,
        'telpFax': telpFax,
        'email': email,
      };
}

class DataProyek extends StatefulWidget {
  @override
  _DataProyekState createState() => _DataProyekState();
}

class _DataProyekState extends State<DataProyek> {
  List<Customer> db_proyek = [];
  final TextEditingController _pelangganController = TextEditingController();
  final TextEditingController _telpFaxController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedPelangganProyek;
  bool isLoading = true;

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> _loadData() async {
    final snapshot = await db.collection('db_proyek').get();
    setState(() {
      db_proyek =
          snapshot.docs.map((doc) => Customer.fromJson(doc.data())).toList();
      isLoading = false; // Data fetched, stop loading
    });
  }

  Future<void> _saveData(Customer customer) async {
    await db.collection('db_proyek').add(customer.toJson());
  }

  Future<void> _deleteData(String pelangganProyek) async {
    final snapshot = await db
        .collection('db_proyek')
        .where('pelangganProyek', isEqualTo: pelangganProyek)
        .get();
    for (var doc in snapshot.docs) {
      await db.collection('db_proyek').doc(doc.id).delete();
    }
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      icon: const Icon(Icons.check),
      primaryColor: Colors.green,
      backgroundColor: Colors.white,
      context: context, // optional if you use ToastificationWrapper
      title: Text('data telah di hapus'),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  void addCustomer() {
    final String pelanggan = _pelangganController.text;
    final String telpFax = _telpFaxController.text;
    final String email = _emailController.text;

    if (_selectedPelangganProyek == null ||
        pelanggan.isEmpty ||
        telpFax.isEmpty ||
        email.isEmpty) {
      showToast('Semua field harus diisi');
      return;
    }

    final newCustomer = Customer(
      pelangganProyek: _selectedPelangganProyek!,
      pelanggan: pelanggan,
      telpFax: telpFax,
      email: email,
    );

    setState(() {
      db_proyek.add(newCustomer);
    });

    _pelangganController.clear();
    _telpFaxController.clear();
    _emailController.clear();
    _saveData(newCustomer);
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
        _selectedPelangganProyek = value;
      } else {
        showToast('Nilai tidak boleh kosong');
      }
    });
  }

  void deleteCustomer(int index) {
    final customer = db_proyek[index];
    setState(() {
      db_proyek.removeAt(index);
    });
    _deleteData(customer.pelangganProyek);
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
        title: Text('Data Proyek'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: db_proyek.length,
                    itemBuilder: (context, index) {
                      final customer = db_proyek[index];
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(10)),
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
                                  text: customer.pelangganProyek,
                                  style: const TextStyle(),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama Pelanggan: ${customer.pelanggan}'),
                              Text('Telp/Fax: ${customer.telpFax}'),
                              Text('Email: ${customer.email}'),
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
                      value: _selectedPelangganProyek,
                      items: ["P001", "P002", "P003"]
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
                      decoration: InputDecoration(labelText: 'Kode Pelanggan'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _pelangganController,
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _telpFaxController,
                      decoration: InputDecoration(
                        labelText: 'Telp/Fax',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
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
    home: DataProyek(),
  ));
}
