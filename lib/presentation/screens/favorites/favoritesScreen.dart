import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool isGridView = false; // To toggle between list and grid
  List<String> favoriteItems = []; // To store favorite items

  // Sample data
  List<Map<String, String>> items = [
    {'name': 'Shirt', 'price': '32\$', 'image': 'assets/images/8.jpeg'},
    {'name': 'Longsleeve Violeta', 'price': '46\$', 'image': 'assets/images/10.jpg'},
    {'name': 'T-Shirt', 'price': '25\$', 'image': 'assets/images/11.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                FilterChip(label: Text('Summer'), onSelected: (_) {}),
                SizedBox(width: 8),
                FilterChip(label: Text('T-Shirts'), onSelected: (_) {}),
                SizedBox(width: 8),
                FilterChip(label: Text('Shirts'), onSelected: (_) {}),
              ],
            ),
            Divider(),
            Expanded(
              child: isGridView ? buildGridView() : buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the list view layout
  Widget buildListView() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.asset(items[index]['image']!, width: 50, height: 50),
          title: Text(items[index]['name']!),
          subtitle: Text(items[index]['price']!),
          trailing: IconButton(
            icon: Icon(
              favoriteItems.contains(items[index]['name'])
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () {
              setState(() {
                if (favoriteItems.contains(items[index]['name'])) {
                  favoriteItems.remove(items[index]['name']);
                } else {
                  favoriteItems.add(items[index]['name']!);
                }
              });
            },
          ),
        );
      },
    );
  }

  // Build the grid view layout
  Widget buildGridView() {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(items[index]['name']!),
            subtitle: Text(items[index]['price']!),
            trailing: IconButton(
              icon: Icon(
                favoriteItems.contains(items[index]['name'])
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  if (favoriteItems.contains(items[index]['name'])) {
                    favoriteItems.remove(items[index]['name']);
                  } else {
                    favoriteItems.add(items[index]['name']!);
                  }
                });
              },
            ),
          ),
          child: Image.asset(
            items[index]['image']!,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}