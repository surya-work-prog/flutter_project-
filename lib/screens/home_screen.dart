import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: LayoutBuilder(
  builder: (context, constraints) {
    double maxWidth = constraints.maxWidth;

    return Center(
      child: Container(
        width: maxWidth > 900 ? 800 : double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              // HERO
              Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink, Colors.pinkAccent],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'The Bridal Touch',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bridal Makeup Artist & Beauty Studio',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // IMAGE SECTION
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _imageBox('Look 1'),
                  _imageBox('Look 2'),
                  _imageBox('Look 3'),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Our Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: const [
                  _ServiceCard('Bridal Makeup'),
                  _ServiceCard('HD Makeup'),
                  _ServiceCard('Party Makeup'),
                ],
              ),

              const SizedBox(height: 20),

              const Footer(),
            ],
          ),
        ),
      ),
    );
  },
),
    );
  }
}


// 📸 Helper function (OUTSIDE class)

Widget _imageBox(String text) {
  return Container(
    width: 100,
    height: 100,
    color: Colors.pinkAccent.shade100,
    child: Center(child: Text(text)),
  );
}


// 💄 Service Card Widget (OUTSIDE class)

class _ServiceCard extends StatelessWidget {
  final String title;

  const _ServiceCard(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.pink),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}