import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class MensClothes extends StatefulWidget {
  const MensClothes({super.key});

  @override
  State<MensClothes> createState() => _MensClothesState();
}

class _MensClothesState extends State<MensClothes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(
        type: "Mens Clothes ",
      )
    );
  }
}