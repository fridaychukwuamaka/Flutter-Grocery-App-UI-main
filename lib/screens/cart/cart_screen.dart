import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/common_widgets/app_button.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/helpers/column_with_seprator.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/widgets/chart_item_widget.dart';

import 'checkout_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Cart",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream:
                db.collection('carts').doc(auth.currentUser.uid).snapshots(),
            builder: (context, snapshot) {
              double cartValue = 0;
              List cartList = [];

              StoreDb().calculateTotal();

              if (snapshot.hasData &&
                  snapshot.data.exists &&
                  snapshot.data.get('products').isNotEmpty) {
                cartList = snapshot.data.get('products');
                cartValue = snapshot.data.get('total').toDouble();
                return ListView(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: getChildrenWithSeperator(
                        addToLastChild: false,
                        widgets: cartList.map((item) {
                          print(item['numItem']);
                          DocumentReference<Map<String, dynamic>> val =
                              item['product'];

                          return FutureBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                              future: val.get(),
                              builder: (context, cartMap) {
                                if (cartMap.hasData) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    width: double.maxFinite,
                                    child: CartItemWidget(
                                      productId: val,
                                      item: GroceryItem(
                                        stock: item['numItem'],
                                        imagePath:
                                            'assets/images/grocery_images/banana.png',
                                        name: cartMap.data.get('name'),
                                        description: cartMap.data.get('desc'),
                                        price: cartMap.data
                                            .get('price')
                                            .toDouble(),
                                      ),
                                      onRemoveItem: () {
                                        StoreDb().removeFromCart(
                                            item['product'],
                                            item['numItem'],
                                            snapshot.data.get('total'),
                                            cartMap.data
                                                .get('price')
                                                .toDouble());
                                      },
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              });
                        }).toList(),
                        seperator: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                          ),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    getCheckoutButton(
                      context,
                      cartValue,
                      cartList,
                    )
                  ],
                );
              } else {
                return Center(
                  child: AppText(
                    text: "No Cart Items",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C7C7C),
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget getCheckoutButton(
      BuildContext context, double cartValue, List products) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: AppButton(
        label: "Go To Check Out",
        fontWeight: FontWeight.w600,
        padding: EdgeInsets.symmetric(vertical: 30),
        trailingWidget: getButtonPriceWidget(cartValue),
        onPressed: () {
          print(cartValue);
          showBottomSheet(context, cartValue, products);
        },
      ),
    );
  }

  Widget getButtonPriceWidget(double cartValue) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Color(0xff489E67),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "\$$cartValue",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void showBottomSheet(context, total, List products) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return CheckoutBottomSheet(
            total: total,
            products: products,
          );
        });
  }
}
