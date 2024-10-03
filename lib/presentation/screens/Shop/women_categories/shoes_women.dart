import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class ShoesWomen extends StatefulWidget {
  const ShoesWomen({super.key});

  @override
  State<ShoesWomen> createState() => _ShoesWomenState();
}

class _ShoesWomenState extends State<ShoesWomen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(type: "Women Shoes ",)
    );
  }
}