import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  var emailController = TextEditingController();
  var passController = TextEditingController();
  bool passwordVisible = false;
  bool sendEmailVerification = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _showErrorMessage(String message, String title) {
    if (!mounted) return; //this to check if the screen still exist or no
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

  /*
    Future return type:The function is asynchronous, indicated by the Future keyword. It will perform the sign-in operation asynchronously and return a Future object, which allows you to handle success or failure at a later time.
    await keyword:The function waits for the sign-in process to complete before moving to the next line of code. This ensures that the operation is completed before the function proceeds (or returns an error if sign-in fails).
     */
  Future signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loginOrNot', true);
        Navigator.pushReplacementNamed(context, 'homepage');
      } else {
        if (!mounted) return;
        setState(() {
          sendEmailVerification = true;
        });
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.rightSlide,
          title: 'info',
          desc: 'Please go to your email to verify your account',
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        ).show();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorMessage('No user found for that email.', 'Error!!!');
      } else if (e.code == 'wrong-password') {
        _showErrorMessage('Wrong password provided for that user.', 'Error!!!');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return; // User canceled the sign in
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase with Google credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the signed-in user's email
      String? email = userCredential.user?.email;

      // Check if the user exists in Fire store
      QuerySnapshot query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isEmpty) {
        // create a new user in Fire store
        addUserDetails(googleUser.displayName.toString(), email!, "", "", "");
      }


      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('loginOrNot', true);

      // Navigate to the homepage
      Navigator.pushNamed(context, 'homepage');
    } catch (e) {
      print('Error during Google Sign In: $e');
    }
  }


  Future<void> signInWithFacebook() async {
    try {

      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        // Sign in to Firebase with Facebook
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        // Get the signed-in user's email
        String? email = userCredential.user?.email;

        if (email != null) {
          // Check if the user exists in Fire store
          QuerySnapshot query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
          if (query.docs.isEmpty) {
            // create a new user in Fire store
            addUserDetails(userCredential.user!.displayName.toString(), email, "", "", "");
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loginOrNot', true);

          // Navigate to the homepage
          Navigator.pushNamed(context, 'homepage');
        } else {
          print("Email not available");
        }
      } else {
        print("Facebook login failed: ${loginResult.status}");
      }
    } catch (e) {
      _showErrorMessage("Error with Facebook sign in", "This email is used before by different sign in ,please sign in by the same method you signed it before");
      print("Error with Facebook sign in: $e");
    }
  }



  Future addUserDetails(String userName, String email, String password, String phone,String profile_image) async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'user_name': userName,
      'email': email,
      'password': password,
      'phone_number': phone,
      'profile_image':profile_image
    });
  }

/*
dispose() is called automatically when a widget’s state is permanently destroyed.
Why it's important: It prevents memory leaks by ensuring that unnecessary resources are released.
 */
  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            SizedBox(height: 150.h),
            Container(
              margin: EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 35.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                'Login To Continue Using The App',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 80.h),
            sendEmailVerification == true
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Send email verification"),
                    ),
                  )
                : Text(""),
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
                  border: OutlineInputBorder(),
                ),
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
                  prefixIcon: Icon(Icons.lock),
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
                  border: const OutlineInputBorder(),
                  labelText: 'Enter Your Password',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 230, top: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('forgot_password');
                },
                child: Text(
                  'forgot password?',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 100.w,
              margin: EdgeInsets.only(left: 85, right: 85, top: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color.fromARGB(255, 120, 82, 255)),
              child: MaterialButton(
                minWidth: 100.w,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    signIn();
                  }
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
                ),
              ),
            ),
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
                        "Don't have an account?",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 34),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('signUp');
                    },
                    child: Text(
                      'Sign up',
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

//error in linking two accounts and when log in with in sign in screen remove the photo of profile