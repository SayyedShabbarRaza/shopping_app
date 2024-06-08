class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });
}

class CartItems {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItems({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}


class OrderItems {
  final String id;
  final double amount;
  final List<CartItems> products;
  final DateTime dateTime;

  OrderItems(
      {required this.id,
      required this.amount,
      required this.dateTime,
      required this.products});
}
