import 'package:depi_final_project/presentation/screens/Homepage/homePage.dart';
import 'package:depi_final_project/presentation/screens/Shop/kids_categories.dart/kids_accesories.dart';
import 'package:depi_final_project/presentation/screens/Shop/kids_categories.dart/kids_clothes.dart';
import 'package:depi_final_project/presentation/screens/Shop/kids_categories.dart/kids_new.dart';
import 'package:depi_final_project/presentation/screens/Shop/kids_categories.dart/kids_shoes.dart';
import 'package:depi_final_project/presentation/screens/Shop/mens_categories/mens_accesories.dart';
import 'package:depi_final_project/presentation/screens/Shop/mens_categories/mens_clothes.dart';
import 'package:depi_final_project/presentation/screens/Shop/mens_categories/mens_new.dart';
import 'package:depi_final_project/presentation/screens/Shop/mens_categories/mens_shoes.dart';
import 'package:depi_final_project/presentation/screens/Shop/women_categories/accessories_women.dart';
import 'package:depi_final_project/presentation/screens/Shop/women_categories/clothes_women.dart';
import 'package:depi_final_project/presentation/screens/Shop/women_categories/new_women.dart';
import 'package:depi_final_project/presentation/screens/Shop/women_categories/shoes_women.dart';
import 'package:depi_final_project/presentation/screens/onboarding/onboardingscreen.dart';
import 'package:depi_final_project/presentation/screens/register/signIn.dart';
import 'package:depi_final_project/presentation/screens/register/signUp.dart';
import 'package:depi_final_project/presentation/screens/splashscreen/splashscreen.dart';
import 'package:depi_final_project/presentation/widgets/productdetails.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 2100),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              routes: {
                'signIn': (context) => SigninScreen(),
                'signUp': (context) => SignupScreen(),
                'homepage': (context) => Homepage(),
                'new_women': (context) => NewWomen(),
                'clothes_women': (context) => ClothesWomen(),
                'shoes_women': (context) => ShoesWomen(),
                'accesories_women': (context) => AccessoriesWomen(),
                'new_men': (context) => MensNew(),
                'clothes_men': (context) => MensClothes(),
                'shoes_men': (context) => MensShoes(),
                'accesories_men': (context) => MensAccesories(),
                'new_kids': (context) => KidsNew(),
                'clothes_kids': (context) => KidsClothes(),
                'shoes_kids': (context) => KidsShoes(),
                'accesories_kids': (context) => KidsAccesories(),
                'details_screen': (context) => ProductDetailsPage(),
                'onBoarding': (context) => Onboardingscreen(),
              });
        });
  }
}
