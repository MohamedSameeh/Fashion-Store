import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class AccessoriesWomen extends StatefulWidget {
  const AccessoriesWomen({super.key});

  @override
  State<AccessoriesWomen> createState() => _AccessoriesWomenState();
}

class _AccessoriesWomenState extends State<AccessoriesWomen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CategoriesDetails(
      type: "Women Accessories ",
    ));
  }
}
