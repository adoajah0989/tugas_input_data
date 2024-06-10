import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Task {
  String kodeLayanan;
  String Layanan;

  Task({
    required this.kodeLayanan,
    required this.Layanan,
  });

  factory Task.fromJson(String json) => Task(
        kodeLayanan: jsonDecode(json)['kodeLayanan'] as String,
        Layanan: jsonDecode(json)['Layanan'] as String,
      );

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        kodeLayanan: map['kodeLayanan'] as String,
        Layanan: map['Layanan'] as String,
      );

  Map<String, dynamic> toMap() => {
        'kodeLayanan': kodeLayanan,
        'Layanan': Layanan,
      };

  String toJson() => jsonEncode(toMap());
}

class DataJenisPage extends StatefulWidget {
  @override
  _DataJenisPageState createState() => _DataJenisPageState();
}

class _DataJenisPageState extends State<DataJenisPage> {
  List<Task> tasks = [];
  final TextEditingController _LayananController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _selectedKodeLayanan;

  Future<void> _loadData() async {
    final snapshot = await db.collection('tasks').get();
    setState(() {
      tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    });
  }

  Future<void> _saveData(Task task) async {
    await db.collection('tasks').add(task.toMap());
  }

  Future<void> _deleteData(String kodeLayanan) async {
    final snapshot = await db
        .collection('tasks')
        .where('kodeLayanan', isEqualTo: kodeLayanan)
        .get();
    for (var doc in snapshot.docs) {
      await db.collection('tasks').doc(doc.id).delete();
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

  void addTask() {
    final String Layanan = _LayananController.text;

    if (_selectedKodeLayanan == null || Layanan.isEmpty) {
      showToast('Kode layanan dan nama layanan tidak boleh kosong');
      return;
    }

    final newTask = Task(
      kodeLayanan: _selectedKodeLayanan!,
      Layanan: Layanan,
    );

    setState(() {
      tasks.add(newTask);
    });

    _LayananController.clear();
    _saveData(newTask);
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
        _selectedKodeLayanan = value;
      } else {
        showToast('Nilai tidak boleh kosong');
      }
    });
  }

  void deleteTask(int index) {
    final task = tasks[index];
    setState(() {
      tasks.removeAt(index);
    });
    _deleteData(task.kodeLayanan);
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Kode Layanan: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          TextSpan(
                            text: task.kodeLayanan,
                            style: const TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text('Nama Layanan: ${task.Layanan}'),
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
                                    deleteTask(index);
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
                      value: _selectedKodeLayanan,
                      items: ["A001", "A002", "A003"]
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
                      decoration: InputDecoration(labelText: 'Kode Layanan'),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _LayananController,
                      decoration: InputDecoration(
                        labelText: 'Nama Layanan',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addTask();
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
    home: DataJenisPage(),
  ));
}
