import 'package:flutter/material.dart';

class itemClick extends StatelessWidget {
  final String icon;
  final String Judul;
  final VoidCallback onPressed;

  itemClick({
    required this.icon,
    required this.Judul,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 45,
                  color: Color.fromARGB(255, 101, 122, 241),
                ),
              ),
              Container(
                height: 60,
                width: 250,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 101, 122, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onPressed,
                  child: Text(
                    Judul,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(255, 255, 244, 1),
                    ),

                    // Jika teks terlalu panjang, gunakan ellipsis
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
