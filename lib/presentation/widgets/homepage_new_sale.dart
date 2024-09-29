import 'package:flutter/material.dart';

class HomepageNewSale extends StatefulWidget {
  HomepageNewSale({super.key, required this.type});
  final String type;

  @override
  State<HomepageNewSale> createState() => _HomepageNewSaleState();
}

class _HomepageNewSaleState extends State<HomepageNewSale> {
  List<String> images = [
    'assets/images/10.jpg',
    'assets/images/11.jpg',
    'assets/images/12.jpg',
    'assets/images/13.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: ListView.builder(
          itemCount: images.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('homepage');
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: 200,
                    height: 195,
                    child: Stack(
                      children: [
                        Image.asset(
                          '${images[index]}',
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                        ),
                        Container(
                            margin: EdgeInsets.all(9),
                            width: 70,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.red,
                            ),
                            child: Center(
                                child: Text(
                              widget.type,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ))),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            margin: EdgeInsets.only(left: 140, top: 150),
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.favorite_border)))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Small Description',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Product Name',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'price',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            );
          }),
    );
  }
}
