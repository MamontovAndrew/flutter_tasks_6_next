import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../res/assets.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class MainRouter extends StatefulWidget {
  const MainRouter({super.key});

  @override
  State<MainRouter> createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const <Widget>[
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildBottomNavItem(
      String label, String iconPath, String activeIconPath, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        _selectedIndex == index ? activeIconPath : iconPath,
        height: 32,
        width: 76,
        fit: BoxFit.scaleDown,
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12,
        unselectedFontSize: 12,
        unselectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        type: BottomNavigationBarType.fixed,
        items: [
          _buildBottomNavItem(
              'Главная', Assets.homeIcon, Assets.homeActiveIcon, 0),
          _buildBottomNavItem(
              'Корзина', Assets.cartIcon, Assets.cartActiveIcon, 1),
          _buildBottomNavItem(
              'Профиль', Assets.userIcon, Assets.userActiveIcon, 2),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
