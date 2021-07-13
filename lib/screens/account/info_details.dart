import 'package:flutter/material.dart';

class InfoDetails extends StatelessWidget {
  const InfoDetails({
    Key key,
    @required this.phoneNum,
    @required this.address,
  }) : super(key: key);

  final String phoneNum;
  final String address;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'My Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(
                    'Phone Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(
                    Icons.phone,
                    color: Colors.black,
                    size: 26,
                  ),
                  minLeadingWidth: 1,
                  subtitle: Text(
                    phoneNum,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  minLeadingWidth: 1,
                  trailing: Icon(
                    Icons.location_on_outlined,
                    color: Colors.black,
                    size: 26,
                  ),
                  subtitle: Text(
                   address,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
