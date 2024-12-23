import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  ApiService apiService = ApiService();
  late Future<List<dynamic>> futureOrders;

  Map<int, List<dynamic>> orderItemsMap = {};
  Set<int> expandedOrderIds = {};

  @override
  void initState() {
    super.initState();
    futureOrders = apiService.getOrders();
  }

  Future<void> _toggleOrderItems(int orderId) async {
    if (expandedOrderIds.contains(orderId)) {
      setState(() {
        expandedOrderIds.remove(orderId);
      });
      return;
    }

    if (!orderItemsMap.containsKey(orderId)) {
      try {
        final items = await apiService.getOrderItems(orderId);
        orderItemsMap[orderId] = items;
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка при загрузке товаров заказа: $e')));
        return;
      }
    }

    setState(() {
      expandedOrderIds.add(orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои заказы'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Данных нет.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              final int orderId = o["order_id"];
              final bool isExpanded = expandedOrderIds.contains(orderId);

              return Card(
                child: ExpansionTile(
                  title: Text('Заказ №$orderId, сумма: ${o["total"]} ₽'),
                  subtitle: Text('Статус: ${o["status"]}, Дата: ${o["created_at"]}'),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      _toggleOrderItems(orderId);
                    } else {
                      setState(() {
                        expandedOrderIds.remove(orderId);
                      });
                    }
                  },
                  children: _buildOrderItems(orderId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderItems(int orderId) {
    if (!expandedOrderIds.contains(orderId)) {
      return [];
    }
    // берем items из orderItemsMap
    final items = orderItemsMap[orderId];
    if (items == null) {
      return [ListTile(title: Text('Загрузка...'))];
    }
    if (items.isEmpty) {
      return [ListTile(title: Text('Нет товаров'))];
    }
    return items.map<Widget>((item) {
      return ListTile(
        title: Text('${item["name"]} x ${item["quantity"]}'),
        subtitle: Text('Цена: ${item["price"]} ₽'),
      );
    }).toList();
  }
}
