import 'package:depi_final_project/presentation/screens/Shop/kids_screen.dart';
import 'package:depi_final_project/presentation/screens/Shop/mens_screen.dart';
import 'package:depi_final_project/presentation/screens/Shop/womens_screen.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> Screens = [WomensScreen(), MensScreen(), KidsScreen()];
  TabController? tabController;
  List items = ['New', 'Clothes', 'Shoes', 'Accesories'];
  List womenNavigators = [
    'new_women',
    'clothes_women',
    'shoes_women',
    'accesories_women'
  ];
  List mensNavigators = [
    'new_men',
    'clothes_men',
    'shoes_men',
    'accesories_men'
  ];
  List kidsNavigators = [
    'new_kids',
    'clothes_kids',
    'shoes_kids',
    'accesories_kids'
  ];
  List womenImages = [
    'assets/images/11.jpg',
    'assets/images/13.jpg',
    'assets/images/shoes_women.jpg',
    'assets/images/accessories_women.jpg',
  ];
  List menImages = [
    'assets/images/10.jpg',
    'assets/images/mens_clothes.jpg',
    'assets/images/mens_shoes.jpg',
    'assets/images/mens_accesories.jpg',
  ];
  List kidsImages = [
    'assets/images/kids_wear.jpg',
    'assets/images/kids_clothes.jpg',
    'assets/images/kids_shoes.jpg',
    'assets/images/kids_accesories.jpg',
  ];
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: Screens.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: SearchDelegator());
                },
                icon: Icon(Icons.search))
          ],
          title: Center(
              child: Text(
            'Categories',
            style: TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
          )),
          bottom: TabBar(
              indicatorColor: Colors.red,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              controller: tabController,
              tabs: [
                Tab(
                    child: Text(
                  'Women',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )),
                Tab(
                    child: Text(
                  'Men',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )),
                Tab(
                    child: Text(
                  'Kids',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )),
              ]),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            CustomWidget(
              images: womenImages,
              items: items,
              navigators: womenNavigators,
            ),
            CustomWidget(
              images: menImages,
              items: items,
              navigators: mensNavigators,
            ),
            CustomWidget(
              images: kidsImages,
              items: items,
              navigators: kidsNavigators,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomWidget extends StatelessWidget {
  CustomWidget(
      {super.key,
      required this.images,
      required this.items,
      required this.navigators});
  final List images, items, navigators;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
          ),
          width: 100,
          height: 110,
          child: Center(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Summer Sales',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
              Text(
                'Up to 50% off',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ],
          )),
        ),
        Container(
          width: double.infinity,
          height: 505,
          child: ListView.builder(
              shrinkWrap: false,
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushNamed('${navigators[index]}');
                        break;
                      case 1:
                        Navigator.of(context).pushNamed('${navigators[index]}');
                        break;
                      case 2:
                        Navigator.of(context).pushNamed('${navigators[index]}');
                        break;
                      case 3:
                        Navigator.of(context).pushNamed('${navigators[index]}');
                        break;
                    }
                  },
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            '${items[index]}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            child: Image.asset(
                              '${images[index]}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}

class SearchDelegator extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text('');
  }
}
