import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

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

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('Failed to create product. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
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
}
