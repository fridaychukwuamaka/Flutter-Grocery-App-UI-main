import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery_app/common_widgets/app_button.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';
import 'package:grocery_app/widgets/item_counter_widget.dart';

import 'favourite_toggle_icon_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GroceryItem groceryItem;
  final DocumentReference productId;

  const ProductDetailsScreen(this.groceryItem, {this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int amount = 1;

  Future<void> incrementAmount() async {
    DocumentSnapshot<Map<String, dynamic>> cart =
        await db.collection('carts').doc(auth.currentUser.uid).get();
    List products = cart.get('products');

    int index = products
        .indexWhere((element) => element['product'] == widget.productId);

    var numItem = amount;

    if (index != -1) {
      numItem = products[index]['numItem'];
      var maxItem =
          await db.collection('products').doc(widget.productId.id).get();

      if (numItem < maxItem.get('stock')) {
        products[index]['numItem'] = numItem;

        setState(() {
          amount = numItem;
        });
      }
    } else {
      products.add(
        {
          'numItem': numItem,
          'product': widget.productId,
        },
      );
    }
    db.collection('carts').doc(auth.currentUser.uid).update(
      {'products': products},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 74,
        child: Column(
          children: [
            AppButton(
              label: "Add To Basket",
              onPressed: () async {
                await incrementAmount();
                Get.snackbar(
                  'Message',
                  'Cart added!!',
                  backgroundColor: AppColors.primaryColor,
                  colorText: Colors.white,
                  borderRadius: 0,
                  margin: EdgeInsets.all(0),
                );
              },
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            getImageHeaderWidget(),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      widget.groceryItem.name,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    subtitle: AppText(
                      text: widget.groceryItem.description,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff7C7C7C),
                    ),
                    trailing: FavoriteToggleIcon(productId: widget.productId),
                  ),
                  //Spacer(),
                  Row(
                    children: [
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: db
                              .collection('carts')
                              .doc(auth.currentUser.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data.exists) {
                              List products = [];

                              products = snapshot.data.get('products');

                              var cart = products.where(
                                (element) =>
                                    element['product'].id ==
                                    widget.productId.id,
                              );

                              if (cart.isNotEmpty) {
                                amount = cart.single['numItem'];
                              }

                              return ItemCounterWidget(
                                stock: amount,
                                productId: widget.productId,
                                onAmountChanged: (newAmount) {
                                  setState(() {
                                    amount = newAmount;
                                  });
                                },
                              );
                            } else {
                              return ItemCounterWidget(
                                stock: amount,
                                onAmountChanged: (newAmount) {
                                  setState(() {
                                    amount = newAmount;
                                  });
                                },
                              );
                            }
                          }),
                      Spacer(),
                      Text(
                        "NGN${getTotalPrice().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(thickness: 1),
                  getProductDataRowWidget("Product Details"),
                  Divider(thickness: 1),
                  getProductDataRowWidget("Nutritions",
                      customWidget: nutritionWidget()),
                  Divider(thickness: 1),
                  getProductDataRowWidget(
                    "Review",
                    customWidget: ratingWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImageHeaderWidget() {
    return Container(
      height: 250,
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        gradient: new LinearGradient(
            colors: [
              const Color(0xFF3366FF).withOpacity(0.1),
              const Color(0xFF3366FF).withOpacity(0.09),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Image(
        image: NetworkImage(widget.groceryItem.imagePath),
      ),
    );
  }

  Widget getProductDataRowWidget(String label, {Widget customWidget}) {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          AppText(text: label, fontWeight: FontWeight.w600, fontSize: 16),
          Spacer(),
          if (customWidget != null) ...[
            customWidget,
            SizedBox(
              width: 20,
            )
          ],
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }

  Widget nutritionWidget() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xffEBEBEB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: AppText(
        text: "100gm",
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Color(0xff7C7C7C),
      ),
    );
  }

  Widget ratingWidget() {
    Widget starIcon() {
      return Icon(
        Icons.star,
        color: Color(0xffF3603F),
        size: 20,
      );
    }

    return Row(
      children: [
        starIcon(),
        starIcon(),
        starIcon(),
        starIcon(),
        starIcon(),
      ],
    );
  }

  double getTotalPrice() {
    return amount * widget.groceryItem.price;
  }
}
