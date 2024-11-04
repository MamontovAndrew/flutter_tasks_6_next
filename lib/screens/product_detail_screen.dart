import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<CartItem> cartItems;
  final Function(Product)? addToCart;
  final Function(Product, int)? updateCartItemQuantity;

  ProductDetailScreen({
    required this.product,
    required this.cartItems,
    this.addToCart,
    this.updateCartItemQuantity,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    CartItem? cartItem = widget.cartItems.firstWhereOrNull(
          (item) => item.product == widget.product,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.product.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Text(
                '${widget.product.price.toStringAsFixed(0)} ₽',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 16),
              cartItem == null
                  ? ElevatedButton(
                onPressed: () {
                  if (widget.addToCart != null) {
                    widget.addToCart!(widget.product);
                    setState(() {});
                  }
                },
                child: Text('В корзину'),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.updateCartItemQuantity != null) {
                        int newQuantity = cartItem.quantity - 1;
                        widget.updateCartItemQuantity!(
                            widget.product, newQuantity);
                        setState(() {});
                      }
                    },
                    icon: Icon(Icons.remove),
                  ),
                  Text('${cartItem.quantity}'),
                  IconButton(
                    onPressed: () {
                      if (widget.updateCartItemQuantity != null) {
                        int newQuantity = cartItem.quantity + 1;
                        widget.updateCartItemQuantity!(
                            widget.product, newQuantity);
                        setState(() {});
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                widget.product.description,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
