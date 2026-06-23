import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/responsive_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ResponsiveContainer(
              child: Column(
                children: const [
                  SizedBox(height: 20),

                  Text(
                    'About Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'The Bridal Touch is dedicated to creating beautiful bridal looks for weddings, engagements, receptions, and special occasions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}