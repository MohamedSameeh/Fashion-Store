import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  int _selectedIndex = 2;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homePage');
        break;
      case 1:
        Navigator.pushNamed(context, '/shop_screen');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/favoritesScreen');
        break;
      case 4:
        Navigator.pushNamed(context, '/Profile_Page');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'My Bag',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userid',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          leading: Image.network(
                            item['proimage'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['proname']),
                          subtitle: Text(
                              'Color: ${item['procolor']} | Size: ${item['prosize']}'),
                          trailing: Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${item['proprice']}\$'),
                                Container(
                                  padding: EdgeInsets.only(),
                                  height: 40,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 0, top: 1),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            size: 25,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 4),
                                      //   child: Text(
                                      //     item['quantity'].toString(),
                                      //     style: TextStyle(fontSize: 20),
                                      //   ),
                                      // ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          size: 25,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total amount:', style: TextStyle(fontSize: 18)),
                    Text('\$50',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'CHECK OUT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Bag'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address
            Text('Shipping address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Jane Doe'),
                subtitle: Text(
                    '3 Newbridge Court\nChino Hills, CA 91709, United States'),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Image.asset('assets/images/mastercard.png', width: 40),
                title: Text('**** **** **** 3947'),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text('Delivery method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeliveryMethodButton(
                    image: 'assets/images/fedex.png',
                    title: 'FedEx',
                    days: '2-3 days'),
                DeliveryMethodButton(
                    image: 'assets/images/usps.png',
                    title: 'USPS',
                    days: '2-3 days'),
                DeliveryMethodButton(
                    image: 'assets/images/dhl.png',
                    title: 'DHL',
                    days: '2-3 days'),
              ],
            ),
            SizedBox(height: 20),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order:', style: TextStyle(fontSize: 16)),
                Text('112\$',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery:', style: TextStyle(fontSize: 16)),
                Text('15\$',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('127\$',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Handle submit order
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Center(
                child: Text('SUBMIT ORDER',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryMethodButton extends StatelessWidget {
  final String image;
  final String title;
  final String days;

  const DeliveryMethodButton(
      {required this.image, required this.title, required this.days});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, width: 50),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14)),
        Text(days, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
