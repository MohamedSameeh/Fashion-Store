import 'package:awesome_dialog/awesome_dialog.dart';
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

  var emailController=TextEditingController();
  var passController=TextEditingController();
  bool passwordVisible = false;
  GlobalKey<FormState>formKey=GlobalKey<FormState>();

  void _showErrorMessage(String message,String title){
    if(!mounted)return; //this to check if the screen still exist or no
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
  Future signIn() async{
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passController.text
      );
      if(credential.user!.emailVerified){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loginOrNot',true); //change the state of user login or not
        Navigator.pushReplacementNamed(context, 'homepage');
      }else{
        if(!mounted)return; //this to check if the screen still exist or no
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

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) { //if user not choose account and disable the dialog this condition not complete te body of function to not happen any error
        return;
      }
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      //go to homepage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('loginOrNot',true); //change the state of user login or not
      Navigator.pushNamed(context, 'homepage');
    }catch(e){
      print('Error during Google Sign In: $e');

    }
  }

  Future signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider
          .credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('loginOrNot',true); //change the state of user login or not
      Navigator.pushNamed(context, 'homepage');
    }catch(e){
      print("Error with sign in facebook: $e");

    }
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
      body: Container(
        child: ListView(
          children: [
            SizedBox(
              height: 150.h,
            ),
            Container(
                margin: EdgeInsets.only(left: 20, top: 20, right: 20),
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 35.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )),
            Container(
                margin: EdgeInsets.only(left: 20, top: 10),
                child: Text(
                  'Login To Continue Using The App',
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 80.h,
            ),
            Form(
              key: formKey,
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                width: 400,
                color: Colors.white,
                child: TextFormField(
                  validator:(value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  controller:emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
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
                validator:(value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller:passController,
                obscureText: !passwordVisible,//This will obscure text dynamically
                decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
              padding: const EdgeInsets.only(left: 230,top: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('forgot_password');
                },
                child: Text('forgot password?',style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),
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
                  if(formKey.currentState!.validate()){
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
                ))),
            Container(
              margin: EdgeInsets.only(right: 10, top: 20,left: 80),
              child: Row(children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(right: 20,),
                  decoration: BoxDecoration(color: Colors.indigo[50],borderRadius: BorderRadius.circular(50)),
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
                  decoration: BoxDecoration(color: Colors.indigo[50],borderRadius: BorderRadius.circular(50)),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ))),
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


