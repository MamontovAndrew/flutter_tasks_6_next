import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final List<CartItem> cartItems;
  final VoidCallback onTap;
  final void Function(Product)? addToCart;
  final void Function(Product, int)? updateCartItemQuantity;

  ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.cartItems,
    required this.onTap,
    this.addToCart,
    this.updateCartItemQuantity,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    CartItem? cartItem = widget.cartItems.firstWhereOrNull(
          (item) => item.product == widget.product,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    child: Image.network(
                      widget.product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: widget.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: widget.onFavoriteToggle,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.product.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '${widget.product.price.toStringAsFixed(0)} ₽',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: cartItem == null
                  ? ElevatedButton(
                onPressed: widget.addToCart != null
                    ? () {
                  widget.addToCart!(widget.product);
                  setState(() {});
                }
                    : null,
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
            ),
          ],
        ),
      ),
    );
  }
}