import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            SizedBox(
              height: 100.h,
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                      fontSize: 35.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 50.h,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              width: 400,
              color: Colors.white,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 50.h,
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
              margin: EdgeInsets.only(left: 10, right: 10, top: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 120, 82, 255)),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('homepage');
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
            Container(
                margin: EdgeInsets.only(top: 30, bottom: 15),
                child: Center(
                    child: Text(
                  'Or sign up With',
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
                      'Sign up with Google',
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
                    'Sign up with Facebook',
                    style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 50, bottom: 15),
                child: Center(
                    child: Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ))),
            Container(
              width: 330,
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.green),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('signIn');
                },
                child: Text(
                  'Sign in',
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
