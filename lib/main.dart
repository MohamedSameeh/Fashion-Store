import 'package:depi_final_project/AboutUs.dart';
import 'package:depi_final_project/core/theme/app_theme.dart';
import 'package:depi_final_project/core/theme/theme_controller.dart';
import 'package:depi_final_project/cubits/cart/cart_cubit.dart';
import 'package:depi_final_project/cubits/catalog/catalog_cubit.dart';
import 'package:depi_final_project/cubits/favorites/favorites_cubit.dart';
import 'package:depi_final_project/data/demo/demo_store_repository.dart';
import 'package:depi_final_project/data/firebase/firebase_auth_repository.dart';
import 'package:depi_final_project/data/firebase/firestore_store_repository.dart';
import 'package:depi_final_project/data/store_repository.dart';
import 'package:depi_final_project/presentation/models/product_model.dart';
import 'package:depi_final_project/presentation/screens/Dashboard/owner_dashboard_page.dart';
import 'package:depi_final_project/presentation/screens/Profile/Profile_Page.dart';
import 'package:depi_final_project/presentation/screens/Profile/UpdateUserInformationPage.dart';
import 'package:depi_final_project/presentation/screens/Review/RatingReviewsScreen.dart';
import 'package:depi_final_project/presentation/screens/Homepage/homePage.dart';
import 'package:depi_final_project/presentation/screens/Search/search_screen.dart';
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
import 'package:depi_final_project/presentation/screens/favorites/favoritesScreen.dart';
import 'package:depi_final_project/presentation/screens/onboarding/onboardingscreen.dart';
import 'package:depi_final_project/presentation/screens/order/order_page.dart';
import 'package:depi_final_project/presentation/screens/register/forgotPassword.dart';
import 'package:depi_final_project/presentation/screens/register/signIn.dart';
import 'package:depi_final_project/presentation/screens/register/signUp.dart';
import 'package:depi_final_project/presentation/screens/splashscreen/splashscreen.dart';
import 'package:depi_final_project/presentation/view_all_pages/new_view_all_page.dart';
import 'package:depi_final_project/presentation/view_all_pages/sales_view_all_page.dart';
import 'package:depi_final_project/presentation/widgets/productdetails.dart';
import 'dart:ui' show PointerDeviceKind;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

bool isFirstTime = true;
bool loginOrNot = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDemoMode) {
    // Demo build: no Firebase at all, everything is served from memory.
    Repo.store = DemoStoreRepository();
    Repo.auth = DemoAuthRepository();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Repo.store = FirestoreStoreRepository();
    Repo.auth = FirebaseAuthRepository();
  }

  //to handle on boarding screens
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isFirstTime = prefs.getBool('isFirstTime') ?? true; //default is true
  loginOrNot = prefs.getBool('loginOrNot') ?? true;
  await ThemeController.instance.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CatalogCubit()),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: ScreenUtilInit(
          designSize: const Size(412, 915),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeController.instance,
                builder: (context, mode, _) {
                  return MaterialApp(
                      title: 'Fashionshop',
                      scrollBehavior: const AppScrollBehavior(),
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      themeMode: mode,
                      initialRoute: 'splashScreen',
                      routes: {
                        'splashScreen': (context) => const SplashScreen(),
                        'signIn': (context) => const SigninScreen(),
                        'signUp': (context) => const SignupScreen(),
                        'homepage': (context) => const Homepage(),
                        'new_women': (context) => const NewWomen(),
                        'clothes_women': (context) => const ClothesWomen(),
                        'shoes_women': (context) => const ShoesWomen(),
                        'accesories_women': (context) =>
                            const AccessoriesWomen(),
                        'new_men': (context) => const MensNew(),
                        'clothes_men': (context) => const MensClothes(),
                        'shoes_men': (context) => const MensShoes(),
                        'accesories_men': (context) => const MensAccesories(),
                        'new_kids': (context) => const KidsNew(),
                        'clothes_kids': (context) => const KidsClothes(),
                        'shoes_kids': (context) => const KidsShoes(),
                        'accesories_kids': (context) => const KidsAccesories(),
                        'details_screen': (context) => ProductDetailsPage(
                              product: ModalRoute.of(context)!
                                  .settings
                                  .arguments as Product,
                            ),
                        'favorites_screen': (context) => const FavoriteScreen(),
                        'onBoarding': (context) => const Onboardingscreen(),
                        'rating_reviews': (context) => RatingAndReviewPage(
                              product: ModalRoute.of(context)!
                                  .settings
                                  .arguments as Product,
                            ),
                        'profilePage': (context) => const ProfilePage(),
                        'sales_view_all': (context) =>
                            const SalesViewAllPage(),
                        'new_view_all': (context) => const NewViewAllPage(),
                        'forgot_password': (context) =>
                            const ForgotpasswordScreen(),
                        'updateUserInformation': (context) =>
                            const UpdateUserInformationPage(),
                        'aboutUS': (context) => const AboutUS(),
                        'search': (context) => const SearchScreen(),
                        'orders': (context) => const MyOrdersPage(),
                        'owner_dashboard': (context) =>
                            const OwnerDashboardPage(),
                      });
                });
          }),
    );
  }
}

/// Lets lists and carousels be dragged with a mouse too (web / desktop).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
