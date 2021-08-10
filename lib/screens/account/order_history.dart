import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';
import 'package:intl/intl.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          title: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: AppText(
              text: 'Order History',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db
              .collection('orders')
              .where('buyerId', isEqualTo: auth.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data.docs;
             
              return ListView.builder(
                padding: EdgeInsets.only(top: 40),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  final time = DateTime.fromMillisecondsSinceEpoch(
                      data[index].get('order_date').seconds * 1000);

                  final status = data[index].get('Status');

                  return ListTile(
                    title: Text(
                      'Order ₦{data[index].id}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        status == '0' ? 'Processing' : 'Delivered',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: status == '0'
                              ? Colors.blueGrey
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          '${DateFormat('EEE, M/d/y').format(time)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
