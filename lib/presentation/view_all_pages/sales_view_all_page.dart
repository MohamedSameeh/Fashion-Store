import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class SalesViewAllPage extends StatelessWidget {
  const SalesViewAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoriesDetails(type: 'Sale');
  }
}
