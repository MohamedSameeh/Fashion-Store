import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class MensShoes extends StatefulWidget {
  const MensShoes({super.key});

  @override
  State<MensShoes> createState() => _MensShoesState();
}

class _MensShoesState extends State<MensShoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(type: "Mens Shoes ",)
    );
  }
}