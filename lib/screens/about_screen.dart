import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              'About Us',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'The Bridal Touch is dedicated to creating beautiful bridal looks for weddings, engagements, receptions, and special occasions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}