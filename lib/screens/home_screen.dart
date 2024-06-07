import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';
import 'package:shopping/screens/product_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isInit = true;
  var isLoading = false;
  var err = false;
  @override
  void didChangeDependencies() async {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      try {
        await Provider.of<Providerr>(context)
            .fetchData()
            .then((value) => setState(() {
                  isLoading = false;
                }));
      } catch (error) {
        setState(() {
        err = true;
        });
        Get.snackbar('Check your Internet Connection', 'something went wrong');
      }
      isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Providerr>(context, listen: false);
    final list = Provider.of<Providerr>(context).list;
    final cart = Provider.of<CartProvider>(context, listen: false);
     if(isLoading){return
      err?
       Center(child: Text('Something went wrong'),):
         const Center(
            child: CircularProgressIndicator(),
          );}else{
            return 
         GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (context, index) => GridTile(
              footer: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Consumer<FavouriteProvider>(
                    builder: (context, fav, child) {
                      return GridTileBar(
                        leading: IconButton(
                          onPressed: () {
                            cart.addItem(
                                product.list[index].id,
                                product.list[index].price,
                                product.list[index].title);
                            Get.snackbar(
                                'Added to Cart', 'Press again to add more');
                          },
                          icon:
                              const Icon(Icons.shopping_cart_checkout_outlined),
                          color: Colors.amber,
                        ),
                        backgroundColor: Colors.black87,
                        title: Text(
                          list[index].title,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            fav.toggleFavourite(index);
                            if (fav.favList.contains(index)) {
                              Get.snackbar('Added to Favourite', '');
                            } else {
                              Get.snackbar('Removed from Favourite', '');
                            }
                          },
                          icon: Icon(fav.favList.contains(index)
                              ? Icons.favorite
                              : Icons.favorite_border_outlined),
                          color: Colors.amber,
                        ),
                      );
                    },
                  )),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ProductDetails(
                            imageUrl: list[index].imageUrl,
                            title: list[index].title,
                            description: list[index].description,
                            price: list[index].price,
                          )));
                },
                child: Image.network(
                  list[index].imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
  }
          }
}
