import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Product> products = body
          .map((dynamic item) => Product.fromJson(item))
          .toList();
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
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Product> favorites = body
          .map((dynamic item) => Product.fromJson(item))
          .toList();
      return favorites;
    } else {
      throw Exception('Не удалось загрузить избранные товары');
    }
  }

  Future<void> addFavorite(int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Не удалось добавить в избранное');
    }
  }

  Future<void> removeFavorite(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/remove/$productId'),
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось удалить из избранного');
    }
  }

  Future<List<CartItem>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<CartItem> cart = body
          .map((dynamic item) => CartItem.fromJson(item))
          .toList();
      return cart;
    } else {
      throw Exception('Не удалось загрузить корзину');
    }
  }

  Future<void> addToCart(int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Не удалось добавить в корзину');
    }
  }

  Future<void> updateCartItem(int productId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/update/$productId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось обновить количество товара в корзине');
    }
  }

  Future<void> removeFromCart(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$productId'),
    );

    if (response.statusCode != 204) {
      throw Exception('Не удалось удалить товар из корзины');
    }
  }
}
