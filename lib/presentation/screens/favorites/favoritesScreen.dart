import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final favoritesRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading favorites'));
          }

          final favoriteItems = snapshot.data?.docs ?? [];

          if (favoriteItems.isEmpty) {
            return const Center(child: Text('No favorites added'));
          }

          return isGridView
              ? buildGridView(favoriteItems)
              : buildListView(favoriteItems);
        },
      ),
    );
  }

  Widget buildListView(List<QueryDocumentSnapshot> favoriteItems) {
    return ListView.builder(
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        final item = favoriteItems[index];
        return ListTile(
          leading: Image.network(item['image'], width: 50, height: 50),
          title: Text(item['name']),
          subtitle: Text('\$${item['price']}'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () async {
              await item.reference.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from favorites')),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildGridView(List<QueryDocumentSnapshot> favoriteItems) {
    return GridView.builder(
      itemCount: favoriteItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = favoriteItems[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(item['image'], fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['name'], style: const TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('\$${item['price']}',
                    style: const TextStyle(color: Colors.grey)),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () async {
                  await item.reference.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from favorites')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';

// class FavoriteScreen extends StatefulWidget {
//   const FavoriteScreen({super.key});

//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }

// class _FavoriteScreenState extends State<FavoriteScreen> {
//   bool isGridView = false; // To toggle between list and grid
//   List<String> favoriteItems = []; // To store favorite items

//   // Sample data
//   List<Map<String, String>> items = [
//     {'name': 'Shirt', 'price': '32\$', 'image': 'assets/images/8.jpeg'},
//     {'name': 'Longsleeve Violeta', 'price': '46\$', 'image': 'assets/images/10.jpg'},
//     {'name': 'T-Shirt', 'price': '25\$', 'image': 'assets/images/11.jpg'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Favorites'),
//         actions: [
//           IconButton(
//             icon: Icon(isGridView ? Icons.list : Icons.grid_view),
//             onPressed: () {
//               setState(() {
//                 isGridView = !isGridView;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 FilterChip(label: Text('Summer'), onSelected: (_) {}),
//                 SizedBox(width: 8),
//                 FilterChip(label: Text('T-Shirts'), onSelected: (_) {}),
//                 SizedBox(width: 8),
//                 FilterChip(label: Text('Shirts'), onSelected: (_) {}),
//               ],
//             ),
//             Divider(),
//             Expanded(
//               child: isGridView ? buildGridView() : buildListView(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build the list view layout
//   Widget buildListView() {
//     return ListView.builder(
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: Image.asset(items[index]['image']!, width: 50, height: 50),
//           title: Text(items[index]['name']!),
//           subtitle: Text(items[index]['price']!),
//           trailing: IconButton(
//             icon: Icon(
//               favoriteItems.contains(items[index]['name'])
//                   ? Icons.favorite
//                   : Icons.favorite_border,
//             ),
//             onPressed: () {
//               setState(() {
//                 if (favoriteItems.contains(items[index]['name'])) {
//                   favoriteItems.remove(items[index]['name']);
//                 } else {
//                   favoriteItems.add(items[index]['name']!);
//                 }
//               });
//             },
//           ),
//         );
//       },
//     );
//   }

//   // Build the grid view layout
//   Widget buildGridView() {
//     return GridView.builder(
//       itemCount: items.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2 / 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemBuilder: (context, index) {
//         return GridTile(
//           footer: GridTileBar(
//             backgroundColor: Colors.black54,
//             title: Text(items[index]['name']!),
//             subtitle: Text(items[index]['price']!),
//             trailing: IconButton(
//               icon: Icon(
//                 favoriteItems.contains(items[index]['name'])
//                     ? Icons.favorite
//                     : Icons.favorite_border,
//                 color: Colors.red,
//               ),
//               onPressed: () {
//                 setState(() {
//                   if (favoriteItems.contains(items[index]['name'])) {
//                     favoriteItems.remove(items[index]['name']);
//                   } else {
//                     favoriteItems.add(items[index]['name']!);
//                   }
//                 });
//               },
//             ),
//           ),
//           child: Image.asset(
//             items[index]['image']!,
//             fit: BoxFit.cover,
//           ),
//         );
//       },
//     );
//   }
// }
