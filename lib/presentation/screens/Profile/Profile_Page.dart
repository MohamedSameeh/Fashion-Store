import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/presentation/screens/Bag/ShippingAddressesPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/UserInformationPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
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
  Uint8List? _image;

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
          .collection('users')
          .doc(firebaseUser?.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          userName = data['user_name'];
          userEmail = data['email'];
          _image = await NetworkAssetBundle(Uri.parse(data['profile_image'])).load('').then((value) => value.buffer.asUint8List());
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

  //change the photo of profile
  void selectImage() async{
    Uint8List img= await pickImage(ImageSource.gallery);
    setState(() {
      _image=img;
    });
    // Upload the image and get the download URL
    String downloadUrl = await uploadImage(img);

    if (downloadUrl.isNotEmpty) {
      // Save the image URL to Firestore
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
        'profile_image': downloadUrl,
      });
    }
  }

  Future<String> uploadImage(Uint8List image) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${FirebaseAuth.instance.currentUser?.uid}.jpg');

      // Upload the image
      await storageRef.putData(image);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      return '';
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
              return Center(child: Icon(Icons.refresh,size: 50, color: Colors.red));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else {
              return Stack(
                children:[
                  SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children:[
                                _image!=null ? CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                   MemoryImage(_image!),
                              ):
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                  NetworkImage('https://via.placeholder.com/150'),
                                ),
                                Positioned(
                                    left:50,
                                    bottom: -10,
                                    child: IconButton(onPressed: selectImage, icon: Icon(Icons.add_a_photo)),
                                )
                        ],
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
                            children: [
                               Positioned(
                                 bottom:100 ,
                                 right:80 ,
                                 child: GestureDetector(
                                  onTap: () async {
                                      //sign out from google account
                                      GoogleSignIn googleSignIn = GoogleSignIn();
                                      googleSignIn.disconnect();

                                      await FacebookAuth.instance.logOut();

                                      //sign out from firebase
                                      await FirebaseAuth.instance.signOut();

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool('loginOrNot',
                                          false); //change the state of user login or not

                                      Navigator.pushReplacementNamed(
                                          context, 'signIn');
                                 },
                                 child: Image.asset(
                                       'assets/images/logout.png',
                                         width: 40,
                                        height: 40,
                                                             ),
                                 ),
                               ),
                            ])
                      ],
                    ),
                  ),
                ),
            ],
              );
            }
          }),
    );
  }
}
