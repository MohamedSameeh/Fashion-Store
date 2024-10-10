import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class SalesViewAllPage extends StatefulWidget {
  const SalesViewAllPage({super.key});

  @override
  State<SalesViewAllPage> createState() => _SalesViewAllPageState();
}

class _SalesViewAllPageState extends State<SalesViewAllPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CategoriesDetails(
        type: "Sale",
      ),
    );
  }
}
