import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;  // Assuming Profile is selected by default

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation or any other logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My profile',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('mennaelwan@mail.com', style: TextStyle(fontSize: 16)),
                    ],
                  )
                ],
              ),
              SizedBox(height: 30),
              ListTile(
                title: Text('My orders'),
                subtitle: Text('Already have 12 orders'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                title: Text('Shipping addresses'),
                subtitle: Text('3 addresses'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                title: Text('Payment methods'),
                subtitle: Text('Visa **34'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                title: Text('Promocodes'),
                subtitle: Text('You have special promocodes'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                title: Text('My reviews'),
                subtitle: Text('Reviews for 4 items'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                title: Text('Settings'),
                subtitle: Text('Notifications, password'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    
    );
  }
}
