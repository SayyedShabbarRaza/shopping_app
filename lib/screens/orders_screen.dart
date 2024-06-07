import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/Model.dart';
import 'package:shopping/models/provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: FutureBuilder(
          future: Provider.of<Orders>(context,listen: false).fetch(),
          builder: (ctx, data) {
            if (data.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (data.error != null) {
                return const Center(
                  child: Text('something went wrong'),
                );
              } else {
                return Consumer<Orders>(builder: (context, value, child) =>ListView.builder(
                      itemCount: value.orders.length,
                      itemBuilder: (context, index) =>
                          OrdersList(value.orders[index])),
                );
              }
            }
          },
        ));
  }
}

class OrdersList extends StatefulWidget {
  const OrdersList(this.order, {super.key});
  final OrderItems order;
  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  var isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
              title: Text('Rs:${widget.order.amount}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              subtitle: Text(DateFormat('dd/MM/yy/hh:mm:ss')
                  .format(widget.order.dateTime)),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more))),
          if (isExpanded)
            // ignore: sized_box_for_whitespace
            Container(
              height: min(widget.order.products.length * 20.0 + 100, 180),
              child: ListView(
                children: widget.order.products
                    .map((e) => Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 50),
                                    child: Text(
                                      'Item',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    )),
                                Text('quantity x price/per item',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Text(
                                      e.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                Text('${e.quantity}x Rs:${e.price}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ))
                              ],
                            ),
                          ],
                        ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
