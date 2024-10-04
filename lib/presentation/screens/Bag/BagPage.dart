import 'package:flutter/material.dart';

List<String> images = [
  'assets/images/10.jpg',
  'assets/images/11.jpg',
  'assets/images/12.jpg',
  'assets/images/13.jpg',
  'assets/images/4.jpg',
  'assets/images/5.jpg',
];

class BagPage extends StatefulWidget {
  @override
  _BagPageState createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  int _selectedIndex = 2; //    Bag Page is selected

  // Sample items in the bag with fields (name, color, size, price, quantity, image)
  List<Map<String, dynamic>> items = [
    {
      'name': 'Pullover',
      'color': 'Black',
      'size': 'L',
      'price': 51.0,
      'quantity': 1,
      'image': images[1], // Updated to use reference from the images list
    },
    {
      'name': 'T-Shirt',
      'color': 'Gray',
      'size': 'L',
      'price': 30.0,
      'quantity': 1,
      'image': images[1], // Updated to use reference from the images list
    },
    {
      'name': 'Sport Dress',
      'color': 'Black',
      'size': 'M',
      'price': 43.0,
      'quantity': 1,
      'image': images[1], // Updated to use reference from the images list
    },
  ];

  String searchQuery = '';

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
    // Filter items based on the search query
    List<Map<String, dynamic>> filteredItems = items.where((item) {
      return item['name'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Calculate total amount
    double totalAmount = filteredItems.fold(
      0.0,
          (sum, item) => sum + (item['price'] * item['quantity']),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Bag',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Optionally handle search icon press if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
            ),
          ),
          Expanded(
            child: filteredItems.isNotEmpty
                ? ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    child: Container(
                    
                      child: ListTile(
                        leading: Image.asset(
                          item['image'], // Use asset image from list
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['name']),
                        subtitle: Text(
                            'Color: ${item['color']} | Size: ${item['size']}'),
                        trailing: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${item['price']}\$'),
                              Container(
                                padding: EdgeInsets.only(),
                                height: 40,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0,top: 1),
                                      child: IconButton(
                                        icon: Icon(Icons.remove,size: 25,),
                                        onPressed: () {
                                          setState(() {
                                            if (item['quantity'] > 1) {
                                              item['quantity']--;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(item['quantity'].toString(),style: TextStyle(fontSize: 20),),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add,size: 25,),
                                      onPressed: () {
                                        setState(() {
                                          item['quantity']++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                'No items found!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
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
                    Text('\$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Checkout Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage()),
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

// CheckoutPage (The checkout page created earlier)
class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
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
            Text('Shipping address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Jane Doe'),
                subtitle: Text('3 Newbridge Court\nChino Hills, CA 91709, United States'),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Payment Method
            Text('Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

            // Delivery Method
            Text('Delivery method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeliveryMethodButton(image: 'assets/images/fedex.png', title: 'FedEx', days: '2-3 days'),
                DeliveryMethodButton(image: 'assets/images/usps.png', title: 'USPS', days: '2-3 days'),
                DeliveryMethodButton(image: 'assets/images/dhl.png', title: 'DHL', days: '2-3 days'),
              ],
            ),
            SizedBox(height: 20),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order:', style: TextStyle(fontSize: 16)),
                Text('112\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery:', style: TextStyle(fontSize: 16)),
                Text('15\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('127\$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: Text('SUBMIT ORDER', style: TextStyle(fontSize: 18, color: Colors.white)),
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

  const DeliveryMethodButton({required this.image, required this.title, required this.days});

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
