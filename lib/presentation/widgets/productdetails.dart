import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String selectedSize = 'M';
  String selectedColor = 'Black';

  List<String> recommendedProducts = [
    'assets/images/8.jpeg',
    'assets/images/10.jpg',
    'assets/images/11.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Short dress'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image and Details
            Stack(
              children: [
                Image.asset('assets/images/12.jpg', height: 350, fit: BoxFit.cover),
                Positioned(
                  right: 20,
                  top: 320,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Short dress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          SizedBox(width: 100,),
                            Text('\$19.99',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: selectedSize,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSize = newValue!;
                          });
                        },
                        items: <String>['S', 'M', 'L', 'XL']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      DropdownButton<String>(
                        value: selectedColor,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedColor = newValue!;
                          });
                        },
                        items: <String>['Black', 'White', 'Red']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Short dress in soft cotton jersey with decorative buttons down the front and a wide frill-trimmed edge.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      ),
                      onPressed: () {
                        // Add to cart action
                      },
                      child: Text('ADD TO CART', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You can also like this',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedProducts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Container(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        recommendedProducts[index],
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (index == 0)
                                      Positioned(
                                        top: 5,
                                        left: 5,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          color: Colors.redAccent,
                                          child: Text(
                                            '-20%',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      right: 5,
                                      bottom: 0,
                                      child: IconButton(icon:Icon(Icons.favorite_border),
                                          color: Colors.white,
                                          onPressed: (){},),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Product Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '\$15.99',
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
