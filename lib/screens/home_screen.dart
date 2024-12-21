import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';

enum SortType {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
}

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

  // Параметры фильтра и сортировки
  String searchQuery = '';
  double minPrice = 0;
  double maxPrice = 999999; // Большое число как верхняя граница
  SortType currentSort = SortType.nameAsc;

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

  // Функция локальной фильтрации и сортировки
  List<Product> _filterAndSortProducts(List<Product> allProducts) {
    // Фильтрация по поиску (подстроке в названии)
    List<Product> filtered = allProducts.where((product) {
      final matchesName = product.name.toLowerCase().contains(searchQuery.toLowerCase());
      // Можно также искать по description, если нужно
      return matchesName;
    }).toList();

    // Фильтрация по ценовому диапазону
    filtered = filtered.where((product) {
      return (product.price >= minPrice) && (product.price <= maxPrice);
    }).toList();

    // Сортировка
    switch (currentSort) {
      case SortType.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortType.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Магазин'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => refreshProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Блок фильтров
          _buildFilterControls(),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final productList = snapshot.data!;
                  // Применяем фильтрацию и сортировку
                  final visibleProducts = _filterAndSortProducts(productList);

                  if (visibleProducts.isEmpty) {
                    return Center(child: Text('Нет товаров по заданным критериям'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: visibleProducts.length,
                    itemBuilder: (context, index) {
                      final product = visibleProducts[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(),
            ),
          );
          if (newProduct != null && newProduct is Product) {
            await apiService.createProduct(newProduct);
            refreshProducts();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Добавить товар',
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: InputDecoration(
              labelText: 'Поиск по названию',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          SizedBox(height: 8),

          // Слайдер цены (или пара TextField для min/max)
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Мин. цена',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      minPrice = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Макс. цена',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      maxPrice = double.tryParse(value) ?? 999999;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Сортировка
          Row(
            children: [
              Text('Сортировка: '),
              SizedBox(width: 8),
              DropdownButton<SortType>(
                value: currentSort,
                items: [
                  DropdownMenuItem(
                    value: SortType.nameAsc,
                    child: Text('Название (A-Z)'),
                  ),
                  DropdownMenuItem(
                    value: SortType.nameDesc,
                    child: Text('Название (Z-A)'),
                  ),
                  DropdownMenuItem(
                    value: SortType.priceAsc,
                    child: Text('Цена (возр.)'),
                  ),
                  DropdownMenuItem(
                    value: SortType.priceDesc,
                    child: Text('Цена (убыв.)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentSort = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
