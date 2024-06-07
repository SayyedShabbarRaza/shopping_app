import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping/models/Model.dart';
import 'package:http/http.dart' as http;

class Providerr extends ChangeNotifier {
  List<Product> _list = [
    Product(
        id: 'p1',
        title: 'Kurta',
        description: 'Shalwar Kameez is national dress',
        price: 39.99,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSi3qg2AOu1ZhHLwUaKVt6usfcq54OE8c6eSA&s'),
    // Product(
    //     id: 'p2',
    //     title: 'waistcoat',
    //     description: 'A Red Shirt',
    //     price: 15.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSi3qg2AOu1ZhHLwUaKVt6usfcq54OE8c6eSA&s'),
    // Product(
    //     id: 'p3',
    //     title: 'Shalwar Kameez',
    //     description: 'A Red Shirt',
    //     price: 29.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKCXHk0XXPD0r4QJm2fK3HWfHQh-9adp63rA&s'),
    // Product(
    //     id: 'p4',
    //     title: 'Red Shirt',
    //     description: 'A Red Shirt',
    //     price: 19.99,
    //     imageUrl:
    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyhGBv8KUt-Q1ovsiuhDB2ytGSAs7JvY0OBw&s'),
  ];
  final String authToken;
  Providerr(this.authToken, this._list);
  List<Product> get list => _list;
  Product findById(String id) {
    return _list.firstWhere((prod) => prod.id == id);
  }

  Future<void> add(Product product) async {
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/products.json', {'auth': authToken});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _list.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchData() async {
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/products.json', {'auth': authToken});
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    final List<Product> loadedProducts = [];
    extractedData.forEach((productId, productData) {
      loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl']));
    });
    _list = loadedProducts;
    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) async {
    final prodIndex = _list.indexWhere((element) => element.id == id);
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': authToken});
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        }));
    _list[prodIndex] = newProduct;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': authToken});
    await http.delete(url);
    _list.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}

class FavouriteProvider extends ChangeNotifier {
  final List<int> _favList = [];
  List<int> get favList => _favList;
  void toggleFavourite(int index) {
    if (_favList.contains(index)) {
      _favList.remove(index);
    } else {
      _favList.add(index);
    }
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  Map<String, CartItems> _items = {};
  Map<String, CartItems> get items => _items;

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartValue) => CartItems(
              id: existingCartValue.id,
              title: existingCartValue.title,
              quantity: existingCartValue.quantity + 1,
              price: existingCartValue.price));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItems(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}

class Orders extends ChangeNotifier {
  List<OrderItems> _orders = [];
  List<OrderItems> get orders => _orders;
  final String authToken;
  final String userId;
  Orders(this.authToken, this._orders, this.userId);
  Future<void> fetch() async {
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/$userId/orders.json', {'auth': authToken});
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    final List<OrderItems> loadedProducts = [];
    extractedData.forEach((orderId, productData) {
      loadedProducts.add(OrderItems(
        id: orderId.toString(),
        amount: productData['amount'],
        dateTime: DateTime.parse(productData['dateTime']),
        products: (productData['products'] as List<dynamic>)
            .map((e) => CartItems(
                id: e['id'],
                title: e['title'],
                quantity: e['quantity'],
                price: e['price']))
            .toList(),
      ));
    });
    _orders = loadedProducts.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItems> cartProducts, double total) async {
    final url = Uri.https('shoppingapp-a1a41-default-rtdb.firebaseio.com',
        '/$userId/orders.json', {'auth': authToken});
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    _orders.add(OrderItems(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts));
    notifyListeners();
  }
}

class Auth extends ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB-uDz8xambC8GZuEThI0iyIo4RT30sF2o');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData['expiresIn'])),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('key', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('key')) {
      return false;
    }
    final extractedUserData = prefs.getString('key');
    if (extractedUserData == null) {
      return false;
    }
    final userData = json.decode(extractedUserData) as Map<String, dynamic>;
    final expiryDateString = userData['expiryDate'] as String;
    final expiryDate = DateTime.parse(expiryDateString);

    if (expiryDate.isBefore(DateTime.now())) {
      // Token expired, clear user data and return false
      logout();
      return false;
    }

    _token = userData['token'] as String;
    _userId = userData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('key');
  }

  void _autoLogout() {
    final timeToEx = _expiryDate!.difference(DateTime.now()).inSeconds;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    _authTimer = Timer(Duration(seconds: timeToEx), logout);
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
