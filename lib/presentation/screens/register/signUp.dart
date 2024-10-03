import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
              margin: EdgeInsets.only(left: 60, right: 60, top: 30),
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
              margin: EdgeInsets.only(right: 10, top: 20,left: 50),
              child: Row(children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(right: 20,),
                  decoration: BoxDecoration(color: Colors.indigo[50],borderRadius: BorderRadius.circular(50)),
                  child: MaterialButton(
                    onPressed: () {
                      signInWithFacebook(context);
                    },
                    child: Image.asset(
                      'assets/images/fb1.png',
                      width: 160.w,
                      height: 150.h,
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(left: 40),
                  decoration: BoxDecoration(color: Colors.indigo[50],borderRadius: BorderRadius.circular(50)),
                  child: MaterialButton(
                    onPressed: () {
                      signInWithGoogle(context);
                    },
                    child: Image.asset(
                      'assets/images/google.png',
                      width: 125.w,
                      height: 150.h,
                    ),
                  ),
                ),
              ]),
            ),
              Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Container(
                      margin: EdgeInsets.only(top: 50, bottom: 15),
                      child: Center(
                          child: Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ))),
                ),
                    Container(
              
              margin: EdgeInsets.only(top: 34),
              
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('signIn');
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Color.fromARGB(255, 120, 82, 255),
                  ),
                ),
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

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
    );

    // Ensure user is logged out before showing the sign-in screen
    await googleSignIn.signOut();

    // Prompt user to select an account
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to the homepage after successful sign-in
    Navigator.of(context).pushNamed('homepage');

    return userCredential;
  } on FirebaseAuthException catch (e) {
    print('Error during Google sign-in: $e');
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Google Sign-In Failed',
      desc: 'Please try again.',
    ).show();
    return null;
  }
}

Future<UserCredential?> signInWithFacebook(BuildContext context) async {
  try {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Check if the login was successful
    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(
        loginResult.accessToken!.tokenString, // Change this to loginResult.accessToken!.value if needed
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      
      // Navigate to the homepage after successful sign-in
      Navigator.of(context).pushReplacementNamed('homepage');

      return userCredential;
    } else {
      // Handle error for unsuccessful login
      String message;
      if (loginResult.status == LoginStatus.cancelled) {
        message = 'Login cancelled';
      } else {
        message = 'Login failed: ${loginResult.message}';
      }
      throw Exception(message);
    }
  } on FirebaseAuthException catch (e) {
    // Handle Firebase authentication error
    print('FirebaseAuthException: $e');
    return null;
  } catch (e) {
    // Handle any other errors
    print('Error during Facebook sign-in: $e');
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Login Failed',
      desc: e.toString(),
    ).show();
    return null;
  }
}
