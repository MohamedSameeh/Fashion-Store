import 'package:depi_final_project/presentation/screens/Bag/BagPage.dart';
import 'package:depi_final_project/presentation/screens/Profile/Profile_Page.dart';
import 'package:depi_final_project/presentation/screens/Review/RatingReviewsScreen.dart';
import 'package:depi_final_project/presentation/screens/Shop/shop_screen.dart';
import 'package:depi_final_project/presentation/screens/favorites/favoritesScreen.dart';
import 'package:depi_final_project/presentation/widgets/HomepageScreen.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart'; // Import the stylish bottom bar package

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Widget> Screens = [
    Homepagescreen(),
    ShopScreen(),
    BagPage(),
    FavoriteScreen(),
    ProfilePage(),
  ];

  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
          onTap: (index) {
            setState(() {
              _currentIndex = index;  
            });
          },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
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
    )
        ,body: Screens[_currentIndex],  
      ),
    );
  }
}
