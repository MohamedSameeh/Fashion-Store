import 'package:flutter/material.dart';

class KidsAccesories extends StatefulWidget {
  const KidsAccesories({super.key});

  @override
  State<KidsAccesories> createState() => _KidsAccesoriesState();
}

class _KidsAccesoriesState extends State<KidsAccesories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Center(child: Text('kids accesories'),)
          ],
        ),
      ),
    );
  }
}