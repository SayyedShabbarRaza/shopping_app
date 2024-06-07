import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';
import 'package:shopping/screens/edit_product_screen.dart';

class UsersProductsScreen extends StatelessWidget {
  const UsersProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Providerr>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => EditScreen()));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: products.list.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text(products.list[index].title),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(products.list[index].imageUrl),
              ),
              trailing: Container(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) =>
                                  EditScreen(id: products.list[index].id)));
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.amber,
                        )),
                    IconButton(
                      onPressed: () async{
                        try{
                       await products.remove(products.list[index].id).then((_) {
                          Get.snackbar('Success', 'Item Removed');
                        });}catch(error) {
                          Get.snackbar('Error', 'Failed to remove item.');
                        };
                      },
                      icon: const Icon(Icons.delete, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
