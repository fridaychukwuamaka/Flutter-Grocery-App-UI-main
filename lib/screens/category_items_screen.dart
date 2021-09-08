import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/models/category_item.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/screens/product_details/product_details_screen.dart';
import 'package:grocery_app/widgets/grocery_item_card_widget.dart';

import 'filter_screen.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class CategoryItemsScreen extends StatelessWidget {
  const CategoryItemsScreen({
    @required this.categoryItem,
  });
  final CategoryItem categoryItem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
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
          /*   GestureDetector(
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
          ), */
        ],
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: AppText(
            text: categoryItem.name,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: db
              .collection('products')
              .where('category', isEqualTo: categoryItem.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StaggeredGridView.count(
                crossAxisCount: 4,
                // I only need two card horizontally
                children: snapshot.data.docs.map((DocumentSnapshot item) {
                  // print(item.data());
                  GroceryItem groceryItem = GroceryItem(
                    name: item.get('name'),
                    stock: item.get('stock'),
                    price: item.get('price').toDouble(),
                    description: item.get('desc'),
                    imagePath: item.get('img'),
                  );
                  return GestureDetector(
                    onTap: () {
                      onItemClicked(context, groceryItem, item.reference);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: GroceryItemCardWidget(
                        item: groceryItem,
                      ),
                    ),
                  );
                }).toList(),
                staggeredTiles: snapshot.data.docs
                    .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                    .toList(),
                mainAxisSpacing: 3.0,
                crossAxisSpacing: 0.0, // add some space
              );
            } else {
              return CircularProgressIndicator();
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
