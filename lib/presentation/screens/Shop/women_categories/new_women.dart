import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class NewWomen extends StatefulWidget {
  const NewWomen({super.key});

  @override
  State<NewWomen> createState() => _NewWomenState();
}

class _NewWomenState extends State<NewWomen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CategoriesDetails(
      type: "Women New ",
    ));
  }
}
