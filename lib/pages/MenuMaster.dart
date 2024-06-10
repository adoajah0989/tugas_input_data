import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tugas_input_data/components/buttonText.dart';
import 'package:tugas_input_data/components/item.dart';
import 'package:tugas_input_data/pages/KategoriLayanan.dart';
import 'package:tugas_input_data/pages/dataLayanan.dart';
import 'package:tugas_input_data/pages/dataProyek.dart';
import 'package:tugas_input_data/pages/datapelanggan.dart';

class MenuMaster extends StatefulWidget {
  const MenuMaster({Key? key}) : super(key: key);

  @override
  _MenuMasterState createState() => _MenuMasterState();
}

class _MenuMasterState extends State<MenuMaster> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Data Layanan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          itemClick(
                              icon: "📈",
                              Judul: "jenis layanan",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DataJenisPage()));
                              }),
                          itemClick(
                              icon: "💁‍♂️",
                              Judul: "Kategori layanan",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            KategoriLayanan()));
                              }),
                          itemClick(
                              icon: "💉",
                              Judul: "data pelanggan",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DataPelanggan()));
                              }),
                          itemClick(
                              icon: "🪜",
                              Judul: "data proyek",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DataProyek()));
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MenuMaster(),
  ));
}
