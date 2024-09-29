import 'package:depi_final_project/presentation/screens/Shop/shop_screen.dart';
import 'package:depi_final_project/presentation/screens/favorites/favoritesScreen.dart';
import 'package:depi_final_project/presentation/screens/profile/profileScreen.dart';
import 'package:depi_final_project/presentation/widgets/HomepageScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Widget> Screens = [
    Homepagescreen(),
    ShopScreen(),
    Favoritesscreen(),
    Profilescreen(),
  ];
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            // Update the index when a tab is clicked
            setState(() {
              _currentIndex = index;
              
            });
            return ;
          },
          currentIndex: _currentIndex, // Set the selected tab
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.black, // Color for the selected icon
          unselectedItemColor: Colors.grey, // Color for unselected icons
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Shop'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: Screens[_currentIndex],
      ),
    );
  }
}
