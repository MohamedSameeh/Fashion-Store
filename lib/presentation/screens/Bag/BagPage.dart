import 'package:flutter/material.dart';

class BagPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  int _selectedIndex = 2; // Bag Page is selected

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on the selected tab
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homePage'); // Navigate to HomePage
        break;
      case 1:
        Navigator.pushNamed(context, '/shop_screen'); // Navigate to Shop Screen
        break;
      case 2:
      // Stay on the Bag page, do nothing
        break;
      case 3:
        Navigator.pushNamed(context, '/favoritesScreen'); // Navigate to Favorites Screen
        break;
      case 4:
        Navigator.pushNamed(context, '/Profile_Page'); // Navigate to Profile Page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0.0; // Default total amount for an empty bag

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Bag',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'No items in your bag yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
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
                    Text('\$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Checkout logic or disabled if no items
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.red,
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
      
    );
  }
}
