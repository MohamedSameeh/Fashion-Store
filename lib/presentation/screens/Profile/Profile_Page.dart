import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depi_final_project/AboutUs.dart';
import 'package:depi_final_project/presentation/screens/Bag/BagPage.dart';
import 'package:depi_final_project/presentation/screens/Bag/ShippingAddressesPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/UpdateUserInformationPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/utils.dart';
import 'package:depi_final_project/presentation/screens/favorites/favoritesScreen.dart';
import 'package:depi_final_project/presentation/screens/order/order_page.dart';
import 'package:depi_final_project/presentation/screens/register/forgotPassword.dart';
import 'package:depi_final_project/presentation/screens/register/signIn.dart';
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
  String searchQuery = ''; // To hold the search query

  String userName = "", userEmail = "",phone="",orders="";
  Uint8List? _image;


  // Stream<Map<String, dynamic>> _fetchUserData() {
  //   final firebaseUser = FirebaseAuth.instance.currentUser;
  //
  //   if (firebaseUser != null) {
  //     return FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).snapshots().map((snapshot) {
  //       if (snapshot.exists) {
  //         Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //
  //         userName = data['user_name'];
  //         userEmail = data['email'];
  //
  //         // Load the image
  //         NetworkAssetBundle(Uri.parse(data['profile_image']))
  //             .load('')
  //             .then((value) => _image = value.buffer.asUint8List());
  //
  //         return data;  // Return the data to the StreamBuilder
  //       } else {
  //         throw Exception('Document does not exist');
  //       }
  //     });
  //   } else {
  //     // If the user is not logged in, return an empty stream
  //     return Stream.empty();
  //   }
  // }

  //change the photo of profile

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if(firebaseUser==null){
        print('No user is logged in');
        return null;
      }
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          userName = data['user_name'];
          userEmail = data['email'];
          phone = data['phone_number'];

          // Fetch and display the saved profile image from Fire store
          String? profileImageUrl = data['profile_image'];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            _image =
            await NetworkAssetBundle(Uri.parse(profileImageUrl)).load('').then((value) => value.buffer.asUint8List());
          }
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
      {'title': 'My orders', 'subtitle': 'Already have $orders orders'},
      {'title': 'Cart','subtitle':'see my products'},
      {'title': 'Favorite','subtitle':'see my favorite'},
      {'title': 'Shipping addresses', 'subtitle': '3 addresses'},
    ];
    List<Map<String, String>> setting = [
      {'title': 'Edit Profile', 'subtitle': 'edit information'},
      {'title': 'Edit Password','subtitle':'change password'},
      {'title': 'About US','subtitle':'Team'},
    ];
    // Filter the items based on the search query
    List<Map<String, String>> filteredItems = items
        .where((item) =>
            item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    List<Map<String, String>> filteredItemsSetting = setting
        .where((item) =>
        item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
        ],
      ),
      body: FutureBuilder(
          future: _fetchUserData(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>?> snapshot) {
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
                                  backgroundImage:_image!=null?MemoryImage(_image!): AssetImage('assets/images/placeholder.png')
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
                        SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text('Account Info',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          ]
                        ),
                        SizedBox(height: 10),

                       // List of items (filtered based on search)
                        ...filteredItems.map((item) {
                          return ListTile(
                            title: Text(item['title']!),
                            subtitle: Text(item['subtitle']!),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.red,),
                            onTap: () {
                              if (item['title'] == 'My orders') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MyOrdersPage()),
                                );
                              }
                                else if (item['title'] == 'Cart') {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) =>
                                BagPage()),
                                );
                                }
                              else if (item['title'] == 'Favorite') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FavoriteScreen()),
                                );
                              }
                              else if(item['title'] == 'Shipping addresses') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShippingAddressesPage()), // Navigate to ShippingAddressesPage
                                );
                              }

                            },
                          );
                        }).toList(),
                        SizedBox(height: 20),

                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Text('Account Setting',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ]
                        ),

                        ...filteredItemsSetting.map((item) {
                          return ListTile(
                            title: Text(item['title']!),
                            subtitle: Text(item['subtitle']!),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.red,),
                            onTap: () {
                              if (item['title'] == 'Edit Profile') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                         UpdateUserInformationPage()),
                                );
                              }
                              else if (item['title'] == 'Edit Password') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotpasswordScreen()),
                                );
                              }
                              else if (item['title'] == 'About US') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AboutUS()),
                                );
                              }
                            },
                          );
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigate to forgotPassword.dart page using MaterialPageRoute
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>SigninScreen(),
                                    ),
                                  );
                                },
                                child: Text('Log out',
                                    style: TextStyle(color: Colors.red,fontSize: 18)),
                              )
                            ],
                          ),
                        ),
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
