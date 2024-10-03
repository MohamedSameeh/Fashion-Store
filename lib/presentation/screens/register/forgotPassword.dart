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
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Please, enter yout email address. You will recieve a link to create a new password via email.',
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, navigate to the specified route
                            Navigator.of(context)
                                .pushNamed(''); // Specify the correct route
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
