import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../screens/home_screen.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

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
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return AppBar(
      title: InkWell(
        onTap: () => _goHomeSection(context, 'home'),
        child: const Text('The Bridal Touch'),
      ),
      centerTitle: false,
      actions: isMobile
          ? [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _openDrawer(context),
                ),
              ),
            ]
          : [
              _sectionButton(context, 'Home', 'home', currentRoute),
              _sectionButton(context, 'Gallery', 'gallery', currentRoute),
              _sectionButton(context, 'Services', 'services', currentRoute),
              _sectionButton(context, 'Contact', 'contact', currentRoute),
              _routeButton(context, 'Admin', '/login', currentRoute),
              const SizedBox(width: 10),
            ],
    );
  }

  Widget _sectionButton(
    BuildContext context,
    String title,
    String section,
    String? currentRoute,
  ) {
    final bool isActive = currentRoute == '/';

    return TextButton(
      onPressed: () => _goHomeSection(context, section),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

    return TextButton(
      onPressed: () => _goToRoute(context, routeName),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
          decorationColor: Colors.white,
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
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: () => _goHomeSection(context, 'home'),
              child: const Text(
                'The Bridal Touch',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _drawerSectionItem(context, 'Home', 'home'),
            _drawerSectionItem(context, 'Gallery', 'gallery'),
            _drawerSectionItem(context, 'Services', 'services'),
            _drawerSectionItem(context, 'Contact', 'contact'),
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
      title: Text(title),
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
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      onTap: () => _goToRoute(context, routeName),
    );
  }
}