import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  String address = "@gmail.com";
  TextEditingController gmailController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  bool isEmailSend = false; //to handel the UI
  bool passwordVisible = false;

  final _formKey = GlobalKey<FormState>();

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

  Future<void> updateUserPassword() async {
    try {
      //update the fire store
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .update({'password': newPasswordController.text});

      //update the password
      User? user = FirebaseAuth.instance.currentUser;
      await user?.updatePassword(newPasswordController.text);

      //show success message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Success",
        desc: "updated Successfully",
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pushReplacementNamed(context, 'profilePage');
        },
      ).show();
    } catch (e) {
      print('Error updating password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    isEmailSend ? "Set New Password" : "Change Password",
                    style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  isEmailSend
                      ? "Please enter your new password"
                      : 'Please, enter your email address. You will receive a link to verify your email.',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!isEmailSend) //show Email field
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 15),
                        width: 400,
                        child: TextFormField(
                          controller: gmailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Email is required';
                            } else if (!RegExp(
                                    r'^[\w-\.]+@(gmail\.com|fsc\.bu\.edu\.eg|outlook\.com)$')
                                .hasMatch(val)) {
                              return 'Enter a valid email (e.g., example@gmail.com)';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    if (isEmailSend) //show new password field
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 15),
                        width: 400,
                        child: TextFormField(
                          controller: newPasswordController,
                          obscureText: !passwordVisible,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'New password is required';
                            }
                            return null;
                          },
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
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    Container(
                      width: 400, // Adjust width as per your design
                      margin: EdgeInsets.only(left: 10, right: 10, top: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red,
                      ),
                      child: MaterialButton(
                        minWidth: 100,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            //to handel if user enter wrong email
                            if (!isEmailSend) {
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: gmailController.text);
                                setState(() {
                                  isEmailSend = true;
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Email Verified successfully!'),
                                ));
                              } catch (e) {
                                _showErrorMessage(
                                    "Enter correct Email....", "Error!!");
                              }
                            } else {
                              // password update
                              updateUserPassword();
                            }
                          }
                        },
                        child: Text(
                          isEmailSend ? 'Change' : 'Send',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
