import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../register/forgotPassword.dart';

class UpdateUserInformationPage extends StatefulWidget {
  const UpdateUserInformationPage({super.key});

  @override
  _UpdateUserInformationPageState createState() =>
      _UpdateUserInformationPageState();
}

class _UpdateUserInformationPageState extends State<UpdateUserInformationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser?.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          fullNameController.text = data['user_name'];
          emailController.text = data['email'];
          phoneController.text = data['phone_number'];
        } else {
          print('Document data is null');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print("error.............$e");
    }
    return null;
  }

  Future<void> updateUserProfileByUid() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .update({
        'user_name': fullNameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
      });

      //update the email if updated
      User? user = FirebaseAuth.instance.currentUser;
      await user?.updateEmail(emailController.text);


      // Show success message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Success",
        desc: "Updated Successfully",
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pushNamed(context, 'homepage');
        },
      ).show();
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid 11-digit phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update My Info'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Reloading data...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) => validateName(value!),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => validateEmail(value!),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => validatePhoneNumber(value!),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 400,
                      margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red,
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          updateUserProfileByUid();
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
