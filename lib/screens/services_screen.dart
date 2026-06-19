import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              'Our Services',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: const [
                ServiceCard('Bridal Makeup'),
                ServiceCard('HD Makeup'),
                ServiceCard('Party Makeup'),
                ServiceCard('Engagement Makeup'),
                ServiceCard('Reception Makeup'),
                ServiceCard('Hair Styling'),
              ],
            ),

            const SizedBox(height: 30),

            const Footer(),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;

  const ServiceCard(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 180,
        height: 100,
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}