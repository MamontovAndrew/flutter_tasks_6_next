import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> favoriteList;
  final Function(Product) onFavoriteToggle;
  final List<CartItem> cartItems;
  final Function(Product) addToCart;
  final Function(Product, int) updateCartItemQuantity;

  HomeScreen({
    required this.favoriteList,
    required this.onFavoriteToggle,
    required this.cartItems,
    required this.addToCart,
    required this.updateCartItemQuantity,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = apiService.getProducts();
  }

  void refreshProducts() {
    setState(() {
      futureProducts = apiService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Магазин'),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final productList = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];

                return ProductCard(
                  product: product,
                  isFavorite: widget.favoriteList.contains(product),
                  onFavoriteToggle: () {
                    setState(() {
                      widget.onFavoriteToggle(product);
                    });
                  },
                  cartItems: widget.cartItems,
                  addToCart: widget.addToCart,
                  updateCartItemQuantity: widget.updateCartItemQuantity,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: product,
                          cartItems: widget.cartItems,
                          addToCart: widget.addToCart,
                          updateCartItemQuantity: widget.updateCartItemQuantity,
                        ),
                      ),
                    );
                    if (result == true) {
                      refreshProducts();
                    }
                  },

                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(),
            ),
          );
          if (newProduct != null) {
            await apiService.createProduct(newProduct);
            refreshProducts();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Добавить товар',
      ),
    );
  }
}
