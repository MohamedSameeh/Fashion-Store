import 'package:depi_final_project/presentation/screens/Profile/SettingsPage.dart';
import 'package:depi_final_project/presentation/screens/Bag/ShippingAddressesPage.dart'; // Import the ShippingAddressesPage
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4; // Assuming Profile is selected by default
  String searchQuery = ''; // To hold the search query

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation or any other logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sample data for the list tiles
    List<Map<String, String>> items = [
      {'title': 'My orders', 'subtitle': 'Already have 12 orders'},
      {'title': 'Shipping addresses', 'subtitle': '3 addresses'},
      {'title': 'Settings', 'subtitle': 'Notifications, password'},
    ];

    // Filter the items based on the search query
    List<Map<String, String>> filteredItems = items
        .where((item) => item['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menna Elwan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('mennaelwan@gmail.com', style: TextStyle(fontSize: 16)),
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
                        MaterialPageRoute(builder: (context) => ShippingAddressesPage()), // Navigate to ShippingAddressesPage
                      );
                    } else if (item['title'] == 'Settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    }
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.red,
      ),
      */
    );
  }
}
