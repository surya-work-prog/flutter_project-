import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/services_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/contact_screen.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget{
  const NavBar({super.key});

  @override
  @override
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('The Bridal Touch'),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('Home'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
          child: const Text('About'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServicesScreen()),
            );
          },
          child: const Text('Services'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GalleryScreen()),
            );
          },
          child: const Text('Gallery'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactScreen()),
            );
          },
          child: const Text('Contact'),
        ),
      ],
    );
  }
}