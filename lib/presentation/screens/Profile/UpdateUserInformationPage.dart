import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime(1989, 12, 12);

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser?.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          fullNameController.text = data['user name'];
          emailController.text = data['Email'];
          phoneController.text = data['phone number'];
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
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser?.uid)
          .update({
        'user name': fullNameController.text,
        'Email': emailController.text,
        'phone number': phoneController.text,
      });
      //show success message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: "Success",
        desc: "updated Successfully",
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pushNamed(context, 'homepage');
        },
      ).show();
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    dateController.text = formatDate(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = formatDate(selectedDate);
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            return Text('Loading Your Data...');
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
                    Text('Update Personal Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: dateController,
                          decoration:
                              InputDecoration(labelText: 'Date of Birth'),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            // Navigate to forgotPassword.dart page using MaterialPageRoute
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotpasswordScreen(),
                              ),
                            );
                          },
                          child: Text('Change',
                              style: TextStyle(color: Colors.blue)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 400,
                      margin: EdgeInsets.only(left: 10, right: 10, top: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red,
                      ),
                      child: MaterialButton(
                        minWidth: 100,
                        onPressed: () async {
                          //update data
                          updateUserProfileByUid();
                        },
                        child: Text(
                          'Update',
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
            );
          }
        },
      ),
    );
  }
}
