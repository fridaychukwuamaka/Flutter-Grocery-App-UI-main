import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grocery_app/common_widgets/app_text.dart';
import 'package:grocery_app/helpers/column_with_seprator.dart';
import 'package:grocery_app/screens/account/info_details.dart';
import 'package:grocery_app/screens/account/order_history.dart';
import 'package:grocery_app/screens/login.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';

import 'account_item.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = '...';
  String userEmail = '..';
  String userPhone = '..';
  String userAddress = '..';
  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    DocumentSnapshot<Map<String, dynamic>> userInfo =
        await db.collection('users').doc(auth.currentUser.uid).get();

    setState(() {
      userName = userInfo.get('fullname');
      userEmail = userInfo.get('email');
      userPhone = userInfo.get('phoneNum');
      userAddress = userInfo.get('address');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading:
                    SizedBox(width: 65, height: 65, child: getImageHeader()),
                title: AppText(
                  text: userName,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: AppText(
                  text: userEmail,
                  color: Color(0xff7C7C7C),
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              Column(
                children: getChildrenWithSeperator(
                  widgets: accountItems.map((e) {
                    return getAccountItemWidget(e);
                  }).toList(),
                  seperator: Divider(
                    thickness: 1,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              logoutButton(context),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget logoutButton(context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: RaisedButton(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: Color(0xffF2F3F2),
        textColor: Colors.white,
        elevation: 0.0,
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                "assets/icons/account_icons/logout_icon.svg",
              ),
            ),
            Text(
              "Log Out",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
            Container()
          ],
        ),
        onPressed: () async {
          await auth.signOut();

          await GetStorage().remove('auth-token');

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
        },
      ),
    );
  }

  Widget getImageHeader() {
    String imagePath = "assets/icons/account_icon.svg";
    return CircleAvatar(
      radius: 5.0,
      child: SvgPicture.asset(
        imagePath,
        color: Colors.white,
      ),
      backgroundColor: Colors.grey,
    );
  }

  Widget getAccountItemWidget(AccountItem accountItem) {
    return GestureDetector(
      onTap: () {
        if (accountItem.label == 'My Details') {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => InfoDetails(
              phoneNum: userPhone,
              address: userAddress,
            ),
          );
        } else if (accountItem.label == 'Orders') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => OrderHistory(),
            ),
          );
        }

        /*  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => InfoDetails(),
          ),
        ); */
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                accountItem.iconPath,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              accountItem.label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }
}
