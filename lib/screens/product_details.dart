import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  final String description;
  final String title;
  final String imageUrl;
  final double price;
  const ProductDetails(
      {super.key,
      required this.imageUrl,
      required this.description,
      required this.title,
      required this.price});
  @override
  Widget build(BuildContext context) {
    // final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Container(color: Colors.amber.withOpacity(0.5),
            height: 400,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          Text('Rs:$price',style:const TextStyle(color: Colors.amber,fontSize: 20),),
          Text(description)
        ],
      ),
    );
  }
}
