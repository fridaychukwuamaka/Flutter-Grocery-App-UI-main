import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/screens/product_details/product_details_screen.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/widgets/grocery_item_card_widget.dart';

class FavouriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        /*     leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.only(left: 25),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FilterScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.only(right: 25),
              child: Icon(
                Icons.sort,
                color: Colors.black,
              ),
            ),
          ),
        ],
        */
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: AppText(
            text: 'Favourite',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream:
              db.collection('favourites').doc(auth.currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.exists) {
              List favouriteList = [];

              favouriteList = snapshot.data.get('products');

              return StaggeredGridView.count(
                crossAxisCount: 4,
                // I only need two card horizontally
                children: favouriteList.map((item) {
                  DocumentReference<Map<String, dynamic>> val = item;
                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: val.get(),
                      builder: (context, favourite) {
                        if (favourite.hasData) {
                          GroceryItem groceryItem = GroceryItem(
                            name: favourite.data.get('name'),
                            stock: favourite.data.get('stock'),
                            price: favourite.data.get('price').toDouble(),
                            description: favourite.data.get('desc'),
                            imagePath: favourite.data.get('img'),
                          );
                          return GestureDetector(
                            onTap: () {
                              onItemClicked(context, groceryItem, val);
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: GroceryItemCardWidget(
                                item: groceryItem,
                              ),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      });
                }).toList(),
                staggeredTiles: favouriteList
                    .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                    .toList(),
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 0.0, // add some space
              );
            } else {
              return Container(
                child: Center(
                  child: AppText(
                    text: "No Favorite Items",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C7C7C),
                  ),
                ),
              );
            }
          }),
    );
  }

  void onItemClicked(BuildContext context, GroceryItem groceryItem,
      DocumentReference productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
                groceryItem,
                productId: productId,
              )),
    );
  }
}
