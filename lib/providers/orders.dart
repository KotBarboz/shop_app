import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../keys.dart';
import '../models/http_exception.dart';
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;

  Orders(this.authToken, this._orders);

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    http.Response response;

    final url = Uri.parse('${URL_BASE}orders.json?auth=$authToken');
    final timeStamp = DateTime.now();

    try {
      response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
          'dateTime': timeStamp.toIso8601String(),
        }),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Could not add order');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        )); //
    notifyListeners();
  }

  Future<void> fetchAnsSetOrders() async {
    final url = Uri.parse('${URL_BASE}orders.json?auth=$authToken');

    try {
      final response = await http.get(url);
      final responseBody = json.decode(response.body);
      if (responseBody == null) {
        if (kDebugMode) {
          print('extracted.isEmpty');
        }
        return;
      }
      final extracted = responseBody as Map<String, dynamic>;

      final List<OrderItem> loadedOrders = [];
      extracted.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}
