import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartList = Provider.of<CartProvider>(context);
    return Scaffold(
        body: Column(
      children: [
        Expanded(
            child: ListView.builder(
          itemBuilder: (context, index) => Dismissible(
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              cartList.removeItem(cartList.items.keys.toList()[index]);
              Get.snackbar('Item removed from cart', '');
            },
            key: Key(cartList.items.values.toList()[index].id),
            background: Container(
              color: Theme.of(context).colorScheme.error,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: FittedBox(
                            child: Text(
                                'Rs:${cartList.items.values.toList()[index].price}'))),
                  ),
                  title: Text(cartList.items.values.toList()[index].title),
                  subtitle: Text(
                      'Total Rs:${(cartList.items.values.toList()[index].price * cartList.items.values.toList()[index].quantity).toStringAsFixed(0)}'),
                  trailing: Text(
                      '${cartList.items.values.toList()[index].quantity}X'),
                ),
              ),
            ),
          ),
          itemCount: cartList.items.length,
        )),
        Card(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20),
              ),
              Chip(
                  label:
                      Text('Rs:${cartList.totalAmount.toStringAsFixed(0)}')),
              OrderButton(),
            ],
          ),
        ),
      ],
    ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({super.key});
  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var isLoading = false;
  var err = false;
  @override
  Widget build(BuildContext context) {
    final cartList = Provider.of<CartProvider>(context, listen: false);
    final userData = Provider.of<UserData>(context, listen: false);
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF25D366), // WhatsApp-like green button background
          foregroundColor: Colors.white,
        ),
        onPressed: (cartList.totalAmount <= 0 || isLoading)
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });
                try {
                 final enteredname= userData.name;
                 final enteredPhone= userData.phoneNo;
                 final enteredAddress= userData.address;
                  await Provider.of<Orders>(context, listen: false).addOrder(
                      cartList.items.values.toList(),
                      cartList.totalAmount,
                      enteredname,enteredPhone,enteredAddress);
                } catch (error) {
                  err = true;
                  Get.snackbar(
                      'Check your Internet Connection', error.toString());
                }
                setState(() {
                  isLoading = false;
                });
                if (err == false) {
                  cartList.clear();
                  Get.snackbar('Order Placed', '');
                }
              },
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('ORDER NOW'));
  }
}
