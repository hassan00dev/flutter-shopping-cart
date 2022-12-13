import 'package:flutter/material.dart';
import 'package:products/models/product.dart';
import 'package:products/screens/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:products/Widgets/product_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final List<ProductData> _data = [];
  bool isLoading = true;
  int countItems = 8;
  ScrollController scrollController = ScrollController();

  void getData() async {
    print("init api call");
    var url = Uri.https('dummyjson.com', '/products');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      for (Map<String, dynamic> product in jsonResponse['products']) {
        setState(() {
          _data.add(ProductData.fromJson(product));
          countItems = _data.length;
          isLoading = false;
        });
      }
    }
  }

  void _openProduct(context, int id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Product(id: id)));
  }

  @override
  void initState() {
    super.initState();
    getData();
    scrollController.addListener(_onScrollListView);
  }

  void _onScrollListView() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget _loading() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: const Color(0xFFD6D6D6),
      child: Container(
        margin: const EdgeInsets.all(5.0),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(),
              ),
              Expanded(
                flex: 3,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _product(int index){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ProductItem(
          productData: _data[index],
          thumbnail: CachedNetworkImage(
            imageUrl: _data[index].thumbnail,
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
          ),
          title: _data[index].title,
          category: _data[index].category,
          price: _data[index].price,
          onOpen: () {
            _openProduct(context, _data[index].id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: ListView.builder(
        controller: scrollController,
        itemCount: countItems,
        itemBuilder: (context, index) {
          double itemOffset = index * 90;
          double totalOffset = scrollController.offset;

          double animationValue = 1;
          double opacity = 1;
          if (itemOffset < totalOffset) {
            double difference = (totalOffset - itemOffset) / 100;
            animationValue = difference;
            animationValue = (1 - animationValue).abs();
            opacity = animationValue.abs();
            if (opacity > 1) {
              opacity = 1;
            } else if (opacity < 0) {
              opacity = 0;
            }
          }

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              alignment: Alignment.center,
              scale: animationValue,
              child: isLoading ? _loading() : _product(index),
            ),
          );
        },
      ),
    );
  }
}
