import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late int _stock;
  late String _imageUrl;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _stock = widget.product.stock;
    _imageUrl = widget.product.imageUrl;
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      Product updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        description: _description,
        price: _price,
        stock: _stock,
        imageUrl: _imageUrl,
        createdAt: widget.product.createdAt,
      );

      try {
        await apiService.updateProduct(updatedProduct);
        Navigator.pop(context, updatedProduct);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении продукта')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать товар'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Название товара'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Описание товара'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: 'Цена товара'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите цену';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.tryParse(value ?? '0') ?? 0;
                },
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: InputDecoration(labelText: 'Количество на складе'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите количество';
                  }
                  return null;
                },
                onSaved: (value) {
                  _stock = int.tryParse(value ?? '0') ?? 0;
                },
              ),
              TextFormField(
                initialValue: _imageUrl,
                decoration: InputDecoration(labelText: 'URL изображения товара'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите URL изображения';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'Введите корректный URL';
                  }
                  return null;
                },
                onSaved: (value) {
                  _imageUrl = value ?? '';
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
