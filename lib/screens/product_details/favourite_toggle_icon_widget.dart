import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/services/db.dart';

class FavoriteToggleIcon extends StatefulWidget {
  const FavoriteToggleIcon({this.productId});
  final DocumentReference productId;
  @override
  _FavoriteToggleIconState createState() => _FavoriteToggleIconState();
}

class _FavoriteToggleIconState extends State<FavoriteToggleIcon> {
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            db.collection('favourites').doc(auth.currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List products = [];
            if (snapshot.data.exists) {
              products = snapshot.data.get('products');

              if (products.contains(widget.productId)) {
                favorite = true;
              } else {
                favorite = false;
              }
            }

            return InkWell(
              onTap: () async {
                if (favorite == true) {
                  products.remove(widget.productId);
                  await db
                      .collection('favourites')
                      .doc(auth.currentUser.uid)
                      .set(
                    {
                      'products': products,
                    },
                  );
                  setState(() {
                    favorite = !favorite;
                  });
                } else {
                  products.add(widget.productId);
                  db.collection('favourites').doc(auth.currentUser.uid).set(
                    {
                      'products': products,
                    },
                  );
                  setState(() {
                    favorite = !favorite;
                  });
                }
              },
              child: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? Colors.red : Colors.blueGrey,
                size: 30,
              ),
            );
          } else {
            return InkWell(
              onTap: () {
                setState(() {
                  favorite = !favorite;
                });
              },
              child: Icon(
                Icons.favorite_border,
                color: Colors.blueGrey,
                size: 30,
              ),
            );
          }
        });
  }
}
