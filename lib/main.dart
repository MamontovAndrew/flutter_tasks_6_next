import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/auth_page.dart';
import '../styles/app_styles.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      return AuthPage();
    } else {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return AuthPage();
      }
      return MainNavigation();
    }
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

  void checkAuth() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      });
    }
  }

  void loadFavorites() async {
    try {
      List<Product> favorites = await apiService.getFavorites();
      setState(() {
        favoriteList = favorites;
      });
    } catch (e) {
    }
  }

  void loadCart() async {
    try {
      List<CartItem> cart = await apiService.getCart();
      setState(() {
        cartItems = cart;
      });
    } catch (e) {
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
    loadUserProfileFromLocal();
    loadFavorites();
    loadCart();
  }

  Future<void> loadUserProfileFromLocal() async {
    try {
      final localProfile = await apiService.getUserProfile();
      setState(() {
        userProfile = localProfile;
      });
    } catch (e) {
      print('Ошибка загрузки профиля из локальной БД: $e');
    }
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
