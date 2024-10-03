import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class MensAccesories extends StatefulWidget {
  const MensAccesories({super.key});

  @override
  State<MensAccesories> createState() => _MensAccesoriesState();
}

class _MensAccesoriesState extends State<MensAccesories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CategoriesDetails(
      type: "Mens Accessories",
    ));
  }
}
