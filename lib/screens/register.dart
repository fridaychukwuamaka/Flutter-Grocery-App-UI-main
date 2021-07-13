import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_app/common_widgets/app_button.dart';
import 'package:grocery_app/screens/dashboard/dashboard_screen.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';

import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

  singUp() async {
    User user;

    QuerySnapshot<Map<String, dynamic>> isUser = await db
        .collection('users')
        .where(
          "email",
          isEqualTo: _emailController.text,
        )
        .get();

    print(isUser.docs.isEmpty);

    if (isUser.docs.isEmpty) {
      try {
        user = (await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        ))
            .user;

        await db.collection('users').doc(user.uid).set({
          "uid": user.uid,
          "email": _emailController.text,
          "phoneNum": _phoneController.text,
          "address": _addressController.text,
          "fullname": _fullnameController.text,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen(),
          ),
        );
      } catch (e) {
        throw (e);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              child: SvgPicture.asset("assets/icons/app_icon_color.svg"),
              height: 55,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Enter your credentials to continue',
              style: TextStyle(
                color: Color(0xFF7C7C7C),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InputWidget(
              label: 'Fullname',
              controller: _fullnameController,
              maxLines: 1,
              isObsured: false,
              hint: 'Jane Doe',
            ),
            SizedBox(
              height: 30,
            ),
            InputWidget(
              label: 'Email',
              maxLines: 1,
              controller: _emailController,
              isObsured: false,
              hint: 'example@mail.com',
            ),
            SizedBox(
              height: 30,
            ),
            InputWidget(
              label: 'Password',
              maxLines: 1,
              isObsured: true,
              controller: _passwordController,
              hint: 'password',
            ),
            SizedBox(
              height: 30,
            ),
            InputWidget(
              label: 'Address',
              maxLines: 3,
              isObsured: false,
              controller: _addressController,
              hint: 'Address',
            ),
            SizedBox(
              height: 10,
            ),
            Text.rich(
              TextSpan(
                  text: 'By continuing you agree to our ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C7C7C),
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: 30,
            ),
            AppButton(
              label: 'Sign Up',
              onPressed: singUp,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
              SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _registerFormKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = false;

/*  @override
  void initState() {
    super.initState();

    const delay = const Duration(seconds: 3);
    Future.delayed(delay, () => onTimerFinished());
  }

 Future initfbAuth() async {
  auth = await FirebaseAuth.instance;
 } */

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Form(
        key: _registerFormKey,
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 200.0,
              height: 100.0,
              child: Text(
                'REGISTER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _fullnameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Fullname',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add username';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add email';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  hasFloatingPlaceholder: true,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.lock_open,
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please add password';
                  } else if (value.length < 6) {
                    return 'Password should be more than 6 characters';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.phone),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _addressController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: FlatButton(
                  child: Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    User user;

                    QuerySnapshot<Map<String, dynamic>> isUser = await db
                        .collection('users')
                        .where(
                          "email",
                          isEqualTo: _emailController.text,
                        )
                        .get();

                    print(isUser.docs.isEmpty);

                    if (isUser.docs.isEmpty) {
                      try {
                        user = (await auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ))
                            .user;

                        await db.collection('users').doc(user.uid).set({
                          "uid": user.uid,
                          "email": _emailController.text,
                          "phoneNum": _phoneController.text,
                          "address": _addressController.text,
                          "fullname": _fullnameController.text,
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ),
                        );
                      } catch (e) {
                        throw (e);
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage(),
                        ),
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
