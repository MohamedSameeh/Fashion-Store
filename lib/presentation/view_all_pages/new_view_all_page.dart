import 'package:depi_final_project/presentation/widgets/categoriesDetails.dart';
import 'package:flutter/material.dart';

class NewViewAllPage extends StatefulWidget {
  const NewViewAllPage({super.key});

  @override
  State<NewViewAllPage> createState() => _NewViewAllPageState();
}

class _NewViewAllPageState extends State<NewViewAllPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:CategoriesDetails(type: "New ",),
    );
  }
}