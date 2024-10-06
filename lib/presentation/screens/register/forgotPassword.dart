import 'package:awesome_dialog/awesome_dialog.dart';
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
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    "Forgot Password",
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
                  'Please, enter your email address. You will receive a link to create a new password via email.',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                            try{
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: gmailController.text);
                              if(!mounted)return; //this to check if the screen still exist or no
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'info',
                                desc: 'Please go to your email to reset Your Password',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  await Future.delayed(Duration(seconds: 2));
                                  // If the form is valid, navigate to the specified route
                                  Navigator.of(context)
                                      .pushNamed('signIn'); // Specify the correct route
                                },

                              ).show();


                            }catch(e){
                              _showErrorMessage("Enter correct Email....", "Error!!");
                            }
                          }
                        },
                        child: Text(
                          'SEND',
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
