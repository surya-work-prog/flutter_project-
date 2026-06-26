import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../screens/home_screen.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _goHomeSection(BuildContext context, String section) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute != '/') {
      Navigator.pushReplacementNamed(context, '/');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeScreen.scrollToSection(context, section);
      });
      return;
    }

    HomeScreen.scrollToSection(context, section);
  }

  void _goToRoute(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == routeName) return;

    Navigator.pushReplacementNamed(context, routeName);
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Material(
      elevation: 2,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              InkWell(
                onTap: () => _goHomeSection(context, 'home'),
                child: const Text(
                  'The Bridal Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C2A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Color(0xFF4A2C2A),
                    ),
                    onPressed: () => _openDrawer(context),
                  ),
                )
              else
                Row(
                  children: [
                    _sectionButton(context, 'Home', 'home', currentRoute),
                    _sectionButton(context, 'About', 'about', currentRoute),
                    _sectionButton(context, 'Services', 'services', currentRoute),
                    _sectionButton(context, 'Gallery', 'gallery', currentRoute),
                    _sectionButton(context, 'Contact', 'contact', currentRoute),
                    const SizedBox(width: 8),
                    _routeButton(context, 'Admin', '/login', currentRoute),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionButton(
    BuildContext context,
    String title,
    String section,
    String? currentRoute,
  ) {
    final bool isActive = currentRoute == '/';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => _goHomeSection(context, section),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4A2C2A),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: const Color(0xFF4A2C2A),
          ),
        ),
      ),
    );
  }

  Widget _routeButton(
    BuildContext context,
    String title,
    String routeName,
    String? currentRoute,
  ) {
    final bool isActive = currentRoute == routeName;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton(
        onPressed: () => _goToRoute(context, routeName),
        style: OutlinedButton.styleFrom(
          foregroundColor: isActive ? Colors.white : const Color(0xFFC48A8A),
          backgroundColor:
              isActive ? const Color(0xFFC48A8A) : Colors.transparent,
          side: const BorderSide(color: Color(0xFFC48A8A)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goHomeSection(BuildContext context, String section) {
    Navigator.pop(context);

    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute != '/') {
      Navigator.pushReplacementNamed(context, '/');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeScreen.scrollToSection(context, section);
      });
      return;
    }

    HomeScreen.scrollToSection(context, section);
  }

  void _goToRoute(BuildContext context, String routeName) {
    Navigator.pop(context);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) return;

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          children: [
            InkWell(
              onTap: () => _goHomeSection(context, 'home'),
              child: const Text(
                'The Bridal Touch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C2A),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _drawerSectionItem(context, 'Home', 'home'),
            _drawerSectionItem(context, 'About', 'about'),
            _drawerSectionItem(context, 'Services', 'services'),
            _drawerSectionItem(context, 'Gallery', 'gallery'),
            _drawerSectionItem(context, 'Contact', 'contact'),
            const Divider(height: 28),
            _drawerRouteItem(context, 'Admin', '/login', currentRoute),
          ],
        ),
      ),
    );
  }

  Widget _drawerSectionItem(
    BuildContext context,
    String title,
    String section,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4A2C2A),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _goHomeSection(context, section),
    );
  }

  Widget _drawerRouteItem(
    BuildContext context,
    String title,
    String routeName,
    String? currentRoute,
  ) {
    final bool isActive = currentRoute == routeName;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFF4A2C2A),
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isActive,
      onTap: () => _goToRoute(context, routeName),
    );
  }
}