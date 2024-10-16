import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  double totalAmount = 0;

  void updateQuantity(DocumentSnapshot doc, int quantityChange) {
    int currentQuantity = doc['quantity'];
    int newQuantity = currentQuantity + quantityChange;

    if (newQuantity > 0) {
      FirebaseFirestore.instance.collection('cart').doc(doc.id).update({
        'quantity': newQuantity,
      }).then((value) => calculateTotalPrice());
    }
  }

  void deleteItem(DocumentSnapshot doc) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(doc.id)
        .delete()
        .then((value) => calculateTotalPrice());
  }

  void calculateTotalPrice() {
    FirebaseFirestore.instance
        .collection('cart')
        .where('userid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += doc['proprice'] * doc['quantity'];
      }
      setState(() {
        totalAmount = total;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
  }

  // Function to handle the checkout
  Future<void> handleCheckout(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final cartSnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('userid', isEqualTo: user.uid)
            .get();

        if (cartSnapshot.docs.isNotEmpty) {
          // Create the order items
          List<Map<String, dynamic>> orderItems = cartSnapshot.docs.map((doc) {
            return {
              'proname': doc['proname'],
              'proprice': doc['proprice'],
              'quantity': doc['quantity'],
              'proimage': doc['proimage'],
              'procolor': doc['procolor'],
              'prosize': doc['prosize'],
            };
          }).toList();

          // Ensure totalAmount is not null and has a valid value
          double totalAmount = 0;
          cartSnapshot.docs.forEach((doc) {
            totalAmount += doc['proprice'] * doc['quantity'];
          });

          // Create a new order with status
          await FirebaseFirestore.instance.collection('orders').add({
            'userid': user.uid,
            'orderItems': orderItems,
            'totalAmount': totalAmount,
            'orderDate': Timestamp.now(),
            'status': 'Processing', // Initial status when order is placed
          });

          // Clear the cart after placing the order
          for (var doc in cartSnapshot.docs) {
            await FirebaseFirestore.instance
                .collection('cart')
                .doc(doc.id)
                .delete();
          }

          // Reset totalAmount in UI
          setState(() {
            totalAmount = 0;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
        } else {
          // Handle empty cart
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your cart is empty!')),
          );
        }
      } catch (e) {
        // Handle any errors that occur during checkout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${e.toString()}')),
        );
      }
    } else {
      // Handle user not being logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to checkout.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'My Bag',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userid',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading cart'));
                } else if (snapshot.data!.docs.isEmpty) {
                  return _buildEmptyCart();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data!.docs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item['proimage'],
                                  width: 100,
                                  height: 120,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: 16),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['proname'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    SizedBox(height: 4),
                                    Text(
                                      'Color: ${item['procolor']} | Size: ${item['prosize']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$${item['proprice']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Quantity controls
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove, size: 20),
                                          onPressed: () {
                                            updateQuantity(item, -1);
                                          },
                                        ),
                                        Text(
                                          item['quantity'].toString(),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 20),
                                          onPressed: () {
                                            updateQuantity(item, 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Delete button
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deleteItem(item);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total amount:', style: TextStyle(fontSize: 18)),
                    Text('\$$totalAmount',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: totalAmount > 0 ? () => handleCheckout(context) : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: totalAmount > 0 ? Colors.red : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'CHECK OUT',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items to your bag to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
