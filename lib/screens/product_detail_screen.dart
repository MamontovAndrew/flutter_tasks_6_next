import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<CartItem> cartItems;
  final void Function(Product) addToCart;
  final void Function(Product, int) updateCartItemQuantity;

  ProductDetailScreen({
    required this.product,
    required this.cartItems,
    required this.addToCart,
    required this.updateCartItemQuantity,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ApiService apiService = ApiService();

  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    CartItem? cartItem = widget.cartItems.firstWhereOrNull(
          (item) => item.product == widget.product,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProduct,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: isDeleting ? null : _deleteProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.product.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              '${widget.product.price.toStringAsFixed(0)} ₽',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.product.description),
            ),
            SizedBox(height: 16),
            cartItem == null
                ? ElevatedButton(
              onPressed: () {
                widget.addToCart(widget.product);
                setState(() {});
              },
              child: Text('Добавить в корзину'),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    widget.updateCartItemQuantity(
                      widget.product,
                      cartItem.quantity - 1,
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.remove),
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  onPressed: () {
                    widget.updateCartItemQuantity(
                      widget.product,
                      cartItem.quantity + 1,
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProduct() async {
    final updatedProduct = await Navigator.push<Product?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: widget.product),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        widget.product.name = updatedProduct.name;
        widget.product.description = updatedProduct.description;
        widget.product.price = updatedProduct.price;
        widget.product.imageUrl = updatedProduct.imageUrl;
      });
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подтверждение'),
        content: Text('Вы уверены, что хотите удалить этот продукт?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        isDeleting = true;
      });

      try {
        await apiService.deleteProduct(widget.product.id!);
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении продукта')),
        );
      }
    }
  }

}
