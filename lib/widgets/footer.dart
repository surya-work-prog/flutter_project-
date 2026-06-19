import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.pink.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'The Bridal Touch',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Bridal Makeup Artist | Beauty & Elegance'),
          SizedBox(height: 10),
          Text('© 2026 All Rights Reserved'),
        ],
      ),
    );
  }
}