import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class MensNew extends StatefulWidget {
  const MensNew({super.key});

  @override
  State<MensNew> createState() => _MensNewState();
}

class _MensNewState extends State<MensNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CategoriesDetails(
      type: "Mens New ",
    ));
  }
}
