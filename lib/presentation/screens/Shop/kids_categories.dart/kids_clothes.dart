import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class KidsClothes extends StatefulWidget {
  const KidsClothes({super.key});

  @override
  State<KidsClothes> createState() => _KidsClothesState();
}

class _KidsClothesState extends State<KidsClothes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(type: "Kids Clothes ",)
    );
  }
}