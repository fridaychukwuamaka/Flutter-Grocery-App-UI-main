import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grocery_app/common_widgets/app_button.dart';
import 'package:grocery_app/screens/register.dart';
import 'package:grocery_app/services/db.dart';
import 'package:grocery_app/styles/colors.dart';

import 'dashboard/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _loading = false;

  String emailError;
  String passwordError;

  Future<dynamic> login() async {
    UserCredential signIn = await auth
        .signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
        .onError((FirebaseAuthException error, stackTrace) {
      setState(() {
        passwordError = error.message;
      });
      print(error.message);
      return;
    });

    GetStorage().write('auth-token', await signIn.user.getIdToken());

    if (signIn != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(),
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
              'Log In',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Enter your emails and password',
              style: TextStyle(
                color: Color(0xFF7C7C7C),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            InputWidget(
              label: 'Email',
              controller: _emailController,
              errorText: emailError,
              maxLines: 1,
              isObsured: false,
              hint: 'example@mail.com',
            ),
            SizedBox(
              height: 30,
            ),
            InputWidget(
              label: 'Password',
              errorText: passwordError,
              maxLines: 1,
              isObsured: true,
              controller: _passwordController,
              hint: 'password',
            ),
            SizedBox(
              height: 50,
            ),
            AppButton(
              label: 'Log In',
              onPressed: login,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    'Sign Up',
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
                        builder: (BuildContext context) => RegisterPage(),
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

class InputWidget extends StatelessWidget {
  InputWidget({
    Key key,
    @required this.label,
    @required this.hint,
    this.errorText,
    @required this.maxLines,
    @required this.isObsured,
    @required this.controller,
  }) : super(key: key);

  final String label;
  final String hint;
  String errorText = '';
  final int maxLines;
  final bool isObsured;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF7C7C7C),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        TextField(
          obscureText: isObsured,
          maxLines: maxLines,
          controller: controller,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: hint,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: AppColors.primaryColor,
            )),
            border: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Color(0xFFE2E2E2),
            )),
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
