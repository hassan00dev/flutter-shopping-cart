import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:products/Boxes.dart';
import 'package:products/models/cart.dart';
import 'package:products/models/product.dart';
import 'package:products/services/dummyjson.dart';

class Product extends StatefulWidget {
  const Product({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  State<Product> createState() => _ProductState(this.id);
}

class _ProductState extends State<Product> {
  final int id;
  final Box<Cart> cartBox = Boxes.getCart();
  Cart? itemInCart;

  _ProductState(this.id);

  final PageController controller = PageController();

  late ProductData productData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    DummyJson.getProduct(id).then((product) {
      setState(() {
        productData = product;
        isLoading = false;
      });
    });

    _setItemInCart();
  }

  void _setItemInCart(){
    var cartItems = cartBox.values
        .cast<Cart>()
        .where((element) => element.product_id == id);

    if (cartItems.isNotEmpty) {
      itemInCart = cartItems.first;
    }

    print(itemInCart);
    print(cartBox.values.cast<Cart>());
  }

  void _addItemToCart() {
    if (itemInCart != null) {
      itemInCart!.quantity = itemInCart!.quantity + 1;
      itemInCart!.save();
      print('+1 added to cart');
    } else {
      cartBox.add(Cart(product_id: productData.id));
      _setItemInCart();
      print('added to cart');
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Detail Screen"),
      ),
      body: !isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: screenHeight / 2.0,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: productData.images.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CachedNetworkImage(
                          imageUrl: productData.images[index],
                          placeholder: (context, url) => Image.asset(
                            'assets/images/default.png',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              productData.title.toString(),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          // Container(
                          //   alignment: Alignment.topRight,
                          //   child: RatingBar.builder(
                          //     initialRating: 3,
                          //     minRating: 0,
                          //     maxRating: 5,
                          //     direction: Axis.horizontal,
                          //     allowHalfRating: true,
                          //     itemCount: 5,
                          //     itemPadding:
                          //         const EdgeInsets.symmetric(horizontal: 4.0),
                          //     itemBuilder: (context, _) => const Icon(
                          //       Icons.star,
                          //       color: Colors.amber,
                          //     ),
                          //     onRatingUpdate: (rating) {
                          //       print(rating);
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Text(
                              r'Price: $' + productData.price.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              r'Available Stock: ' +
                                  productData.stock.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.blueAccent,
                                size: 30,
                              ),
                              onTap: () {
                                _addItemToCart();
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Text(
                          productData.description.toString(),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  r'Categories:   ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Chip(
                                  padding: const EdgeInsets.all(0),
                                  backgroundColor: Colors.blue,
                                  label: Text(productData.category.toString(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  r'Brands:   ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Chip(
                                  padding: const EdgeInsets.all(0),
                                  backgroundColor: Colors.green,
                                  label: Text(productData.brand.toString(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: const CircularProgressIndicator(),
            ),
    );
  }
}
