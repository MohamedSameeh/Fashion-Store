import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUS extends StatelessWidget {
  // Sample data for the cards
  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Hend Sayed',
      'image': 'assets/images/placeholder.png',
      'description': 'Mobile app Developer',
    },
    {
      'name': 'Norhan Ayman',
      'image': 'assets/images/placeholder.png',
      'description': 'Mobile app Developer',
    },
    {
      'name': 'Menna Elwan',
      'image': 'assets/images/placeholder.png',
      'description': 'Mobile app Developer',
    },
    {
      'name': 'Mohamed Sameeh',
      'image': 'assets/images/placeholder.png',
      'description': 'Mobile app Developer',
    },
    {
      'name': 'Ibrahim Elareney',
      'image': 'assets/images/placeholder.png',
      'description': 'Mobile app Developer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // GridView for the first four cards
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: teamMembers.length , // First four members
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            child: Image.asset(
                              teamMembers[index]['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                teamMembers[index]['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                teamMembers[index]['description']!,
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}