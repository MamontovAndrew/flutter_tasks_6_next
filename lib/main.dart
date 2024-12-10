import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';
import '../styles/app_styles.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shop',
      theme: AppStyles.mainTheme.copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  List<Product> favoriteList = [];
  List<CartItem> cartItems = [];

  UserProfile userProfile = UserProfile();

  ApiService apiService = ApiService();

  void loadFavorites() async {
    try {
      List<Product> favorites = await apiService.getFavorites();
      setState(() {
        favoriteList = favorites;
      });
    } catch (e) {}
  }

  void loadCart() async {
    try {
      List<CartItem> cart = await apiService.getCart();
      setState(() {
        cartItems = cart;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
    loadCart();
  }

  void addToCart(Product product) async {
    try {
      await apiService.addToCart(product.id!);
      loadCart();
    } catch (e) {}
  }

  void updateCartItemQuantity(Product product, int quantity) async {
    try {
      if (quantity <= 0) {
        await apiService.removeFromCart(product.id!);
      } else {
        await apiService.updateCartItem(product.id!, quantity);
      }
      loadCart();
    } catch (e) {}
  }

  void removeFromCart(Product product) async {
    try {
      await apiService.removeFromCart(product.id!);
      loadCart();
    } catch (e) {}
  }

  void toggleFavorite(Product product) async {
    try {
      if (favoriteList.contains(product)) {
        await apiService.removeFavorite(product.id!);
      } else {
        await apiService.addFavorite(product.id!);
      }
      loadFavorites();
    } catch (e) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      HomeScreen(
        favoriteList: favoriteList,
        onFavoriteToggle: toggleFavorite,
        cartItems: cartItems,
        addToCart: addToCart,
        updateCartItemQuantity: updateCartItemQuantity,
      ),
      FavoritesScreen(
        favoriteList: favoriteList,
        onFavoriteToggle: toggleFavorite,
        addToCart: addToCart,
        updateCartItemQuantity: updateCartItemQuantity,
        cartItems: cartItems,
      ),
      ProfileScreen(
        userProfile: userProfile,
      ),
      CartScreen(
        cartItems: cartItems,
        updateCartItemQuantity: updateCartItemQuantity,
        removeFromCart: removeFromCart,
      ),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
        ],
      ),
    );
  }
}
