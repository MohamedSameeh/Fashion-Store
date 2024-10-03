import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class ClothesWomen extends StatefulWidget {
  const ClothesWomen({super.key});

  @override
  State<ClothesWomen> createState() => _ClothesWomenState();
}

class _ClothesWomenState extends State<ClothesWomen> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: CategoriesDetails(type: "Women Clothes ",)
    );
  }
}