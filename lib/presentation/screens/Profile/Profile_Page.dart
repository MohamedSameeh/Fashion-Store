import 'package:depi_final_project/add_product.dart';
import 'package:depi_final_project/presentation/screens/Profile/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../AboutUs.dart';
import '../Bag/BagPage.dart';
import '../Bag/ShippingAddressesPage.dart';
import '../favorites/favoritesScreen.dart';
import '../order/order_page.dart';
import '../register/forgotPassword.dart';
import '../register/signIn.dart';
import 'UpdateUserInformationPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String searchQuery = '';

  String userName = "", userEmail = "", phone = "", orders = "";
  Uint8List? _image;
  Future<Map<String, dynamic>?>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
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
          String? profileImageUrl = data['profile_image'];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            _loadProfileImage(profileImageUrl);
          }

          return data;
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

  Future<void> _loadProfileImage(String profileImageUrl) async {
    try {
      _image = await NetworkAssetBundle(Uri.parse(profileImageUrl))
          .load('')
          .then((value) => value.buffer.asUint8List());
      setState(() {});
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });

    String downloadUrl = await uploadImage(img);

    if (downloadUrl.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'profile_image': downloadUrl,
      });
    }
  }

  Future<String> uploadImage(Uint8List image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${FirebaseAuth.instance.currentUser?.uid}.jpg');

      await storageRef.putData(image);

      String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> items = [
      {'title': 'My orders', 'subtitle': 'Already have $orders orders'},
      {'title': 'Cart', 'subtitle': 'see my products'},
      {'title': 'Favorite', 'subtitle': 'see my favorite'},
      {'title': 'Shipping addresses', 'subtitle': '3 addresses'},
    ];
    List<Map<String, String>> setting = [
      {'title': 'Edit Profile', 'subtitle': 'edit information'},
      {'title': 'Edit Password', 'subtitle': 'change password'},
      {'title': 'About US', 'subtitle': 'Team'},
    ];

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.black54],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDataFuture,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data available'));
          } else {
            return Stack(
              children: [
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
                              children: [
                                _image != null
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage: MemoryImage(_image!),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: snapshot
                                                .data?['profile_image'] ??
                                            'https://via.placeholder.com/150',
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                          radius: 50,
                                          backgroundImage: imageProvider,
                                        ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          radius: 50,
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          radius: 50,
                                          backgroundImage:
                                              AssetImage('assets/images/5.jpg'),
                                        ),
                                      ),
                                Positioned(
                                  left: 50,
                                  bottom: -10,
                                  child: IconButton(
                                      onPressed: selectImage,
                                      icon: Icon(Icons.add_a_photo)),
                                )
                              ],
                            ),
                            SizedBox(width: 18),
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
                                Text(userEmail, style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Divider(
                                indent: 5,
                                color: Colors.black,
                              ),
                              Text(
                                'Account Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Divider()
                            ]),
                        SizedBox(height: 10),
                        ...filteredItems.map((item) {
                          return ListTile(
                            title: Text(item['title']!),
                            subtitle: Text(item['subtitle']!),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.red,
                            ),
                            onTap: () {
                              if (item['title'] == 'My orders') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyOrdersPage()),
                                );
                              } else if (item['title'] == 'Cart') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BagPage()),
                                );
                              } else if (item['title'] == 'Favorite') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FavoriteScreen()),
                                );
                              } else if (item['title'] ==
                                  'Shipping addresses') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShippingAddressesPage()),
                                );
                              }
                            },
                          );
                        }).toList(),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Account Setting',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                        ...filteredItemsSetting.map((item) {
                          return ListTile(
                            title: Text(item['title']!),
                            subtitle: Text(item['subtitle']!),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.red,
                            ),
                            onTap: () {
                              if (item['title'] == 'Edit Profile') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateUserInformationPage()),
                                );
                              } else if (item['title'] == 'Edit Password') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotpasswordScreen()),
                                );
                              } else if (item['title'] == 'About US') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutUS()),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SigninScreen(),
                                    ),
                                  );
                                },
                                child: Text('Log out',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18)),
                              )
                            ],
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     IconButton(
                        //         onPressed: () {
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //               builder: (context) => AddProduct(),
                        //             ),
                        //           );
                        //         },
                        //         icon: Icon(Icons.settings)),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
