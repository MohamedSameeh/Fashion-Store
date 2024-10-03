import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class KidsShoes extends StatefulWidget {
  const KidsShoes({super.key});

  @override
  State<KidsShoes> createState() => _KidsShoesState();
}

class _KidsShoesState extends State<KidsShoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(type: "Kids Shoes ",)
    );
  }
}