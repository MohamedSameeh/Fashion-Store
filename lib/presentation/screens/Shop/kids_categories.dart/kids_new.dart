import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class KidsNew extends StatefulWidget {
  const KidsNew({super.key});

  @override
  State<KidsNew> createState() => _KidsNewState();
}

class _KidsNewState extends State<KidsNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(type: "Kids New",)
    );
  }
}