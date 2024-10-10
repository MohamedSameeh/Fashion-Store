import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/presentation/screens/Bag/ShippingAddressesPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/UserInformationPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4; // Assuming Profile is selected by default
  String searchQuery = ''; // To hold the search query

  String userName = "", userEmail = "";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation or any other logic here
    });
  }

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
          userName = data['user name'];
          userEmail = data['Email'];
        } else {
          print('Document data is null');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print("error.............$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for the list tiles
    List<Map<String, String>> items = [
      {'title': 'My orders', 'subtitle': 'Already have 12 orders'},
      {'title': 'Shipping addresses', 'subtitle': '3 addresses'},
      {'title': 'Settings', 'subtitle': 'My information'},
    ];

    // Filter the items based on the search query
    List<Map<String, String>> filteredItems = items
        .where((item) =>
            item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          /* IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Optionally, you could add additional functionality here if needed
            },
          ),*/
        ],
      ),
      body: FutureBuilder(
          future: _fetchUserData(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>?> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Text('Loading Your Data...');
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage('https://via.placeholder.com/150'),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(userEmail, style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Search TextField
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value; // Update the search query
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // List of items (filtered based on search)
                      ...filteredItems.map((item) {
                        return ListTile(
                          title: Text(item['title']!),
                          subtitle: Text(item['subtitle']!),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            if (item['title'] == 'Shipping addresses') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ShippingAddressesPage()), // Navigate to ShippingAddressesPage
                              );
                            } else if (item['title'] == 'Settings') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserInformationPage()),
                              );
                            }
                          },
                        );
                      }).toList(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  //sign out from google account
                                  GoogleSignIn googleSignIn = GoogleSignIn();
                                  googleSignIn.disconnect();
                                  //sign out from firebase
                                  await FirebaseAuth.instance.signOut();

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('loginOrNot',
                                      false); //change the state of user login or not

                                  Navigator.pushReplacementNamed(
                                      context, 'signIn');
                                },
                                icon: Icon(Icons.exit_to_app)),
                          ])
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
