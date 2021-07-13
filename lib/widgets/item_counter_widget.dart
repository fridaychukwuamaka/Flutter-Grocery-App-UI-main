import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';

class ItemCounterWidget extends StatefulWidget {
  final Function onAmountChanged;
  final int stock;
  final productId;
  final int maxItem;

  const ItemCounterWidget({
    Key key,
    this.onAmountChanged,
    @required this.stock,
    this.maxItem,
    this.productId,
  }) : super(key: key);

  @override
  _ItemCounterWidgetState createState() => _ItemCounterWidgetState();
}

class _ItemCounterWidgetState extends State<ItemCounterWidget> {
  int amount;

  @override
  Widget build(BuildContext context) {
    amount = widget.stock;
    return Row(
      children: [
        iconWidget(Icons.remove,
            iconColor: AppColors.darkGrey, onPressed: decrementAmount),
        SizedBox(width: 18),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream:
                db.collection('carts').doc(auth.currentUser.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List products = snapshot.data.get('products');

                int index = products.indexWhere(
                    (element) => element['product'] == widget.productId);

                var qty = 1;

                if (index != -1) {
                  qty = products[index]['numItem'];
                }
                return Container(
                  width: 30,
                  child: Center(
                    child: getText(
                      text: qty.toString(),
                      fontSize: 18,
                      isBold: true,
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 30,
                  child: Center(
                    child: getText(
                      text: '',
                      fontSize: 18,
                      isBold: true,
                    ),
                  ),
                );
              }
            }),
        SizedBox(width: 18),
        iconWidget(Icons.add,
            iconColor: AppColors.primaryColor, onPressed: incrementAmount)
      ],
    );
  }

  Future<void> incrementAmount() async {
    DocumentSnapshot<Map<String, dynamic>> cart =
        await db.collection('carts').doc(auth.currentUser.uid).get();
    List products = cart.get('products');

    int index = products
        .indexWhere((element) => element['product'] == widget.productId);

    var numItem = 1;

    if (index != -1) {
      numItem = products[index]['numItem'];
      var maxItem =
          await db.collection('products').doc(widget.productId.id).get();

      
      if (numItem < maxItem.get('stock')) {
        products[index]['numItem'] = numItem + 1;

        setState(() {
          amount = numItem + 1;

          updateParent();
        });
      }
    } else {
      products.add(
        {
          'numItem': 2,
          'product': widget.productId,
        },
      );

      setState(() {
        amount = 2;

        updateParent();
      });
    }
    db.collection('carts').doc(auth.currentUser.uid).update(
      {'products': products},
    );
  }

  Future<void> decrementAmount() async {
    DocumentSnapshot<Map<String, dynamic>> cart =
        await db.collection('carts').doc(auth.currentUser.uid).get();
    List products = cart.get('products');

    int index = products
        .indexWhere((element) => element['product'] == widget.productId);

    var numItem = 1;

    if (index != -1) {
      numItem = products[index]['numItem'];
      var maxItem =
          await db.collection('products').doc(widget.productId.id).get();

      
      if (numItem != 1) {
        products[index]['numItem'] = numItem - 1;

        setState(() {
          amount = numItem - 1;

          updateParent();
        });
      }
    }
    db.collection('carts').doc(auth.currentUser.uid).update(
      {'products': products},
    );
  }

  void updateParent() {
    if (widget.onAmountChanged != null) {
      widget.onAmountChanged(amount);
    }
  }

  Widget iconWidget(IconData iconData, {Color iconColor, onPressed}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Color(0xffE2E2E2),
          ),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor ?? Colors.black,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget getText(
      {String text,
      double fontSize,
      bool isBold = false,
      color = Colors.black}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
  }
}
