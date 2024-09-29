import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            SizedBox(
              height: 150.h,
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 35.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 80.h,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              width: 400,
              color: Colors.white,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 50.h,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              width: 400.w,
              color: Colors.white,
              child: TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              width: 330,
              margin: EdgeInsets.only(left: 10, right: 10,top: 40),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 120, 82, 255)),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('homepage');
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 30, bottom: 15),
                child: Center(
                    child: Text(
                  'Or Login With',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ))),
            Container(
                width: 300,
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.redAccent),
                child: MaterialButton(
                  onPressed: () {},
                  child: Row(children: [
                    Image.asset(
                      'assets/images/google.png',
                      width: 50.w,
                      height: 80.h,
                    ),
                    Text(
                      'Login with Google',
                      style: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 330,
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.blue),
              child: MaterialButton(
                onPressed: () {},
                child: Row(children: [
                  Image.asset(
                    'assets/images/fb1.png',
                    width: 50.w,
                    height: 80.h,
                  ),
                  Text(
                    'Login with Facebook',
                    style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 80, bottom: 15),
                child: Center(
                    child: Text(
                  'Dont have an account?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ))),
            Container(
              width: 330,
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.green),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('signUp');
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
