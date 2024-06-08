import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';
import 'package:shopping/screens/product_details.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
        final list = Provider.of<Providerr>(context).list;
    final favList = Provider.of<FavouriteProvider>(context);
    return Scaffold(
      body: GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: favList.favList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) => GridTile(
        footer: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
             list[favList.favList[index]].title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => ProductDetails(
                      imageUrl: list[index].imageUrl,
                      title: list[index].title, description: list[index].description,price: list[index].price,
                    )));
          },
          child: Image.network(
            list[favList.favList[index]].imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
    );
  }
}