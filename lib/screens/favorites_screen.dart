import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Product> favoriteList;
  final Function(Product) onFavoriteToggle;
  final Function(Product) addToCart;
  final Function(Product, int) updateCartItemQuantity;
  final List<CartItem> cartItems;

  FavoritesScreen({
    required this.favoriteList,
    required this.onFavoriteToggle,
    required this.addToCart,
    required this.updateCartItemQuantity,
    required this.cartItems,
  });

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: widget.favoriteList.isEmpty
          ? Center(child: Text('Нет избранных товаров'))
          : GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: widget.favoriteList.length,
        itemBuilder: (context, index) {
          final product = widget.favoriteList[index];

          return ProductCard(
            product: product,
            isFavorite: widget.favoriteList.contains(product),
            onFavoriteToggle: () {
              widget.onFavoriteToggle(product);
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
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }
}
