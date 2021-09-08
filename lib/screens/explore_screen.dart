import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/models/category_item.dart';
import 'package:grocery_app/widgets/category_item_card_widget.dart';
import 'package:grocery_app/widgets/search_bar_widget.dart';

import 'category_items_screen.dart';

List<Color> gridColors = [
  Color(0xff53B175),
  Color(0xffF8A44C),
  Color(0xffF7A593),
  Color(0xffD3B0E0),
  Color(0xffFDE598),
  Color(0xffB7DFF5),
  Color(0xff836AF6),
  Color(0xffD73B77),
];

FirebaseFirestore db = FirebaseFirestore.instance;

class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          SvgPicture.asset("assets/icons/app_icon_color.svg"),
          getHeader(),
          Expanded(
            child: getStaggeredGridView(context),
          ),
        ],
      ),
    ));
  }

  Widget getHeader() {
    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Center(
          child: AppText(
            text: "nectar",
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SearchBarWidget(),
        ),
      ],
    );
  }

  Widget getStaggeredGridView(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StaggeredGridView.count(
              padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
              crossAxisCount: 4,
              children: snapshot.data.docs.map((DocumentSnapshot category) {
                CategoryItem categoryItem = CategoryItem(
                  id: category.id,
                  name: category.get('name'),
                  imagePath: category.get('img'),
                );

                return GestureDetector(
                  onTap: () {
                    onCategoryItemClicked(context, categoryItem);
                  },
                  child: CategoryItemCardWidget(
                    item: categoryItem,
                    // color: Colors.green,
                  ),
                );
              }).toList(),

      
              staggeredTiles: snapshot.data.docs
                  .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                  .toList(),
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 15.0, // add some space
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            );
          }
        });
  }

  void onCategoryItemClicked(BuildContext context, CategoryItem categoryItem) {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return CategoryItemsScreen(
          categoryItem: categoryItem,
        );
      },
    ));
  }
}
