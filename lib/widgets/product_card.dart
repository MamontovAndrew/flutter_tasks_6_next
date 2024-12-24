import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Toast для уведомлений
import 'package:collection/collection.dart'; // Для поиска cartItem
import '../models/product.dart';
import '../models/cart_item.dart';
import 'package:flutter3/main.dart';

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
    final product = widget.product;

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
            // Изображение и иконка избранного
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
            // Название товара
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Цена
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '${product.price.toStringAsFixed(0)} ₽',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            // Контролы корзины
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCartControls(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartControls(BuildContext context) {
    final product = widget.product;
    final cartItem = widget.cartItems.firstWhereOrNull(
          (item) => item.product.id == product.id,
    );

    // Если товара нет на складе
    if (product.stock == 0) {
      return Text(
        'Нет в наличии',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    // Если товара еще нет в корзине
    if (cartItem == null) {
      return ElevatedButton(
        onPressed: () async {
          if (widget.addToCart != null) {
            try {
              widget.addToCart!(product); // Просто вызываем метод
              setState(() {}); // Обновляем состояние после добавления
            } catch (e) {
              final errorMessage = e.toString();
              if (errorMessage.contains('400') || errorMessage.contains('Not enough stock')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Недостаточно на складе!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            }
          }
        },
        child: Text('В корзину'),
      );
    }

    // Если товар уже в корзине
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () async {
            if (widget.updateCartItemQuantity != null) {
              try {
                widget.updateCartItemQuantity!(
                  product,
                  cartItem.quantity - 1, // Передаем новое значение
                );
                setState(() {}); // Обновляем состояние после изменения
              } catch (e) {
                final errorMessage = e.toString();
                if (errorMessage.contains('400') || errorMessage.contains('Not enough stock')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Недостаточно на складе!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            }
          },
          icon: Icon(Icons.remove),
        ),
        Text('${cartItem.quantity}'),
        IconButton(
          onPressed: () async {
            if (widget.updateCartItemQuantity != null) {
              try {
                widget.updateCartItemQuantity!(
                  product,
                  cartItem.quantity + 1, // Передаем новое значение
                );
                setState(() {}); // Обновляем состояние после изменения
              } catch (e) {
                final errorMessage = e.toString();
                if (errorMessage.contains('400') || errorMessage.contains('Not enough stock')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Недостаточно на складе!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            }
          },
          icon: Icon(Icons.add),
        ),
      ],
    );


  }
}
