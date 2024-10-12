// import 'package:flutter/material.dart';
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           'Search',
//           style: TextStyle(color: Colors.black),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search settings...',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (query) {
//                 // Handle search logic here
//               },
//             ),
//             SizedBox(height: 20),
//             // Add search results or logic here
//             Expanded(
//               child: Center(
//                 child: Text('Enter a search query to begin'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
