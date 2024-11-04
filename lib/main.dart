import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';
import '../styles/app_styles.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';

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

  List<Product> productList = products;
  List<Product> favoriteList = [];
  List<CartItem> cartItems = [];

  UserProfile userProfile = UserProfile();

  void addToCart(Product product) {
    setState(() {
      final existingItem = cartItems.firstWhere(
            (item) => item.product == product,
        orElse: () => CartItem(product: product, quantity: 0),
      );
      if (existingItem.quantity == 0) {
        cartItems.add(CartItem(product: product, quantity: 1));
      } else {
        existingItem.quantity += 1;
      }
    });
  }

  void updateCartItemQuantity(Product product, int quantity) {
    setState(() {
      final cartItem = cartItems.firstWhere((item) => item.product == product);
      cartItem.quantity = quantity;
      if (cartItem.quantity <= 0) {
        cartItems.remove(cartItem);
      }
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      cartItems.removeWhere((item) => item.product == product);
    });
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favoriteList.contains(product)) {
        favoriteList.remove(product);
      } else {
        favoriteList.add(product);
      }
    });
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
        productList: productList,
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