import 'package:depi_final_project/presentation/widgets/homepage_new_sale.dart';
import 'package:flutter/material.dart';

class Homepagescreen extends StatefulWidget {
  const Homepagescreen({super.key});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
            Stack(children: [
              Image.asset(
                'assets/images/7.webp',
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                margin: EdgeInsets.only(top: 130, left: 10),
                child: Text('Fashion\n Sale',
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              Container(
                width: 200,
                height: 50,
                margin: EdgeInsets.only(top: 280, left: 10),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(30)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('homepage');
                  },
                  child: Center(
                      child: Text(
                    'Check',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              )
            ]),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      'Sale',
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 170),
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      )),
                )
              ],
            ),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "Super summer sale",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal),
                )),
            HomepageNewSale(type: 'Sale'),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      'New',
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 170),
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      )),
                )
              ],
            ),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "You've never seen it before",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal),
                )),
            HomepageNewSale(type: "New")
          ]),
    );
  }
}