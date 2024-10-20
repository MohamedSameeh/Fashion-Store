import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var nameController = TextEditingController();
  bool passwordVisible = false;
  GlobalKey<FormState> registerKey = GlobalKey<FormState>();

  void _showErrorMessage(String message, String title) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      btnCancelOnPress: () {},
      btnOkOnPress: () {},
    ).show();
  }

  void _showSuccessMessageAndGoToLogin() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: "Success",
      desc: "Sign Up Successfully",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        Navigator.pushReplacementNamed(context, 'signIn');
      },
    ).show();
  }

  Future<void> signUp() async {
    try {
      //create user
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );
      //send verify email
      FirebaseAuth.instance.currentUser!.sendEmailVerification();

      //add user details to fire store
      addUserDetails(nameController.text, emailController.text,
          passController.text, "", '');

      //show success message and go to  homepage
      _showSuccessMessageAndGoToLogin();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorMessage('The password provided is too weak.', 'Warning!!');
      } else if (e.code == 'email-already-in-use') {
        _showErrorMessage(
            'The account already exists for that email.', 'Error!!');
      }
    } catch (e) {
      _showErrorMessage(e.toString(), 'Error!!');
    }
  }

  Future addUserDetails(String userName, String email, String password,
      String phone, String profileImage) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'user_name': userName,
      'email': email,
      'password': password,
      'phone_number': phone,
      'profile_image': profileImage
    });
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final email = googleUser.email;

      // Check if the email is used before
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        _showErrorMessage(
            'An account already exists with this email. Please sign in with the appropriate method.',
            'Error');
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Accessing the email after Google Sign-In
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? email = user.email;

          // Add user details to Firestore
          addUserDetails(googleUser.displayName ?? '', email!, '', '', '');
        }

        //show success message and go to homepage
        _showSuccessMessageAndGoToLogin();
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  Future signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Check if the login was successful
      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        final userData = await FacebookAuth.instance.getUserData();
        final email = userData['email'];

        // Check if the email is used before
        List<String> signInMethods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (signInMethods.isNotEmpty) {
          _showErrorMessage(
              'An account already exists with this email. Please sign in with the appropriate method.',
              'Error');
        } else {
          // Sign in to Firebase
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential);

          // Access the user information after Facebook Sign-In
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Retrieve user details from Facebook
            final userData = await FacebookAuth.instance.getUserData();
            String name = userData['name'] ?? "";
            String? email = user.email;

            // Add user details to Fire store
            await addUserDetails(name, email!, '', '', '');

            // Show success message and go to the homepage
            _showSuccessMessageAndGoToLogin();
          } else {
            print("Facebook login failed: ${loginResult.message}");
          }
        }
      }
    } catch (e) {
      print("Error during Facebook sign-in: $e");
      _showErrorMessage("Error during Facebook sign-in", "Error!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: registerKey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_box),
                    labelText: 'Username',
                    border: OutlineInputBorder()),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder()),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: passController,
                obscureText:
                    !passwordVisible, //This will obscure text dynamically
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      //Toggle the state of passwordVisible variable
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              width: 330,
              margin: EdgeInsets.only(left: 85, right: 85, top: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 120, 82, 255)),
              child: MaterialButton(
                onPressed: () {
                  if (registerKey.currentState!.validate()) {
                    signUp();
                  } else {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.rightSlide,
                      title: 'Alert!!',
                      desc: 'Fill All Fields .',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                  }
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
              margin: EdgeInsets.only(right: 10, top: 20, left: 80),
              child: Row(children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(50)),
                  child: MaterialButton(
                    onPressed: () {
                      signInWithFacebook();
                    },
                    child: Image.asset(
                      'assets/images/fb1.png',
                      width: 160.w,
                      height: 150.h,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(left: 40),
                  decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(50)),
                  child: MaterialButton(
                    onPressed: () {
                      signInWithGoogle();
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
