import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';
import '../models/globals.dart' as globals;

String? _getUserId() => globals.globalUserId;


class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Не удалось загрузить продукты');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Не удалось создать продукт');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/delete/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось удалить продукт');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/update/${product.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Не удалось обновить продукт');
    }
  }

  Future<List<Product>> getFavorites() async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.get(
      Uri.parse('$baseUrl/favorites?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить избранные товары');
    }
  }

  Future<void> addFavorite(int productId) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.post(
      Uri.parse('$baseUrl/favorites?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Не удалось добавить в избранное');
    }
  }

  Future<void> removeFavorite(int productId) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/remove/$productId?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось удалить из избранного');
    }
  }

  Future<void> createOrder() async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final url = '$baseUrl/orders?user_id=$userId';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 201) {
      print('Order created: ${response.body}');
    } else {
      print(response.statusCode);
      // throw Exception('Ошибка при создании заказа: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<dynamic>> getOrders() async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final url = '$baseUrl/orders?user_id=$userId';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Ошибка при загрузке заказов: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<CartItem>> getCart() async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.get(
      Uri.parse('$baseUrl/cart?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить корзину');
    }
  }

  Future<void> addToCart(int productId) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.post(
      Uri.parse('$baseUrl/cart?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Не удалось добавить в корзину');
    }
  }

  Future<List<dynamic>> getOrderItems(int orderId) async {
    final url = '$baseUrl/orders/$orderId/items';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Ошибка при загрузке товаров заказа: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateCartItem(int productId, int quantity) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.put(
      Uri.parse('$baseUrl/cart/update/$productId?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось обновить количество товара в корзине');
    }
  }

  Future<void> removeFromCart(int productId) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$productId?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось удалить товар из корзины');
    }
  }

  Future<UserProfile> getUserProfile() async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile?user_id=$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return UserProfile(
        name: data['username'] ?? '',
        email: data['email'] ?? '',
        imagePath: null,
      );
    } else {
      throw Exception('Не удалось загрузить профиль пользователя');
    }
  }


  Future<void> updateUserProfile(String name, String email) async {
    final userId = _getUserId();
    if (userId == null) throw Exception('Пользователь не авторизован.');

    final body = {
      'user_id': userId,
      'username': name,
      'email': email,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile/update'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка при обновлении профиля: ${response.body}');
    }
  }

}
