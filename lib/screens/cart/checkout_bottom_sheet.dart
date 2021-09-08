import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:get/get.dart';
import 'package:grocery_app/common_widgets/app_button.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/models/sales.dart';
import 'package:grocery_app/screens/cart/cart_screen.dart';
import 'package:grocery_app/screens/order_accepted_screen.dart';
import 'package:grocery_app/services/db.dart';



class CheckoutBottomSheet extends StatefulWidget {
  final double total;
  final List products;

  const CheckoutBottomSheet({
    @required this.total,
    @required this.products,
  });
  @override
  _CheckoutBottomSheetState createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  var publicKey = 'pk_live_b3676f5356cf757564b6be177c5578614b07a2e3';
  final plugin = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(publicKey: publicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 30,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: new Wrap(
        children: <Widget>[
          Row(
            children: [
              AppText(
                text: "Checkout",
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 25,
                  ))
            ],
          ),
          SizedBox(
            height: 45,
          ),
          getDivider(),
          checkoutRow("Delivery", trailingText: "Address"),
          getDivider(),
          checkoutRow("Payment", trailingWidget: Icon(Icons.payment)),
          getDivider(),
          // checkoutRow("Promo Code", trailingText: "Pick Discount"),
          // getDivider(),
          checkoutRow("Total Cost", trailingText: "NGN ${widget.total}"),
          getDivider(),
          SizedBox(
            height: 30,
          ),
          termsAndConditionsAgreement(context),
          Container(
            margin: EdgeInsets.only(
              top: 25,
            ),
            child: AppButton(
              label: "Place Order",
              fontWeight: FontWeight.w600,
              padding: EdgeInsets.symmetric(
                vertical: 25,
              ),
              onPressed: () {
                onPlaceOrderClicked(widget.total, widget.products, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getDivider() {
    return Divider(
      thickness: 1,
      color: Color(0xFFE2E2E2),
    );
  }

  Widget termsAndConditionsAgreement(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: 'By placing an order you agree to our',
          style: TextStyle(
            color: Color(0xFF7C7C7C),
            fontSize: 14,
            fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
                text: " Terms",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            TextSpan(text: " And"),
            TextSpan(
                text: " Conditions",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ]),
    );
  }

  Widget checkoutRow(String label,
      {String trailingText, Widget trailingWidget}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Row(
        children: [
          AppText(
            text: label,
            fontSize: 18,
            color: Color(0xFF7C7C7C),
            fontWeight: FontWeight.w600,
          ),
          Spacer(),
          trailingText == null
              ? trailingWidget
              : AppText(
                  text: trailingText,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }

  Future<void> onPlaceOrderClicked(double total, products, context) async {
    await beginPayment(total, _getReference());

    Sales orders = Sales(
      product: products,
      total: total,
      date: DateTime.now(),
      status: '0',
      buyerId: auth.currentUser.uid,
    );

    StoreDb().placeOrder(orders);

    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return OrderAcceptedScreen();
        });
  }

  Future<void> beginPayment(amount, txref) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await db.collection('users').doc(auth.currentUser.uid).get();

    Flutterwave flutterwave = Flutterwave.forUIPayment(
      context: this.context,
      encryptionKey: "FLWSECK_TESTc20c3fa5d85f",
      publicKey: "FLWPUBK_TEST-613f19998e7345a8ad61afc6e3665058-X",
      currency: 'NGN',
      amount: amount.toString(),
      email: auth.currentUser.email,
      fullName: user.get('fullname'),
      txRef: txref,
      isDebugMode: true,
      phoneNumber: user.get('phoneNum'),
      acceptCardPayment: true,
      acceptUSSDPayment: true,
      acceptAccountPayment: false,
      acceptFrancophoneMobileMoney: false,
      acceptGhanaPayment: false,
      acceptMpesaPayment: false,
      acceptRwandaMoneyPayment: true,
      acceptUgandaPayment: false,
      acceptZambiaPayment: false,
    );

    final ChargeResponse response = await flutterwave.initializeForUiPayments();
  /*   Get.to(CartScreen()); */
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
