import 'package:depi_final_project/presentation/screens/Bag/SuccessPage.dart';
import 'package:flutter/material.dart';

import 'BagPage.dart';
import 'ShippingAddressesPage.dart'; // Import the ShippingAddressesPage

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedDeliveryMethod = 0; // Track the selected delivery method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address
            Text('Shipping address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Jane Doe'),
                subtitle: Text('3 Newbridge Court\nChino Hills, CA 91709, United States'),
                trailing: TextButton(
                  onPressed: () {
                    // Navigate to ShippingAddressesPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShippingAddressesPage()),
                    );
                  },
                  child: Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Payment Method
            Text('Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Image.asset('assets/images/mastercard.png', width: 40),
                title: Text('**** **** **** 3947'),
                trailing: TextButton(
                  onPressed: () {
                    // Navigate to payment method change page (you can create a new page)
                  },
                  child: Text('Change', style: TextStyle(color: Colors.red)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Delivery Method
            Text('Delivery method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeliveryMethodButton(
                  image: 'assets/images/fedex.png',
                  title: 'FedEx',
                  days: '2-3 days',
                  isSelected: _selectedDeliveryMethod == 0,
                  onTap: () {
                    setState(() {
                      _selectedDeliveryMethod = 0;
                    });
                  },
                ),
                DeliveryMethodButton(
                  image: 'assets/images/usps.png',
                  title: 'USPS',
                  days: '2-3 days',
                  isSelected: _selectedDeliveryMethod == 1,
                  onTap: () {
                    setState(() {
                      _selectedDeliveryMethod = 1;
                    });
                  },
                ),
                DeliveryMethodButton(
                  image: 'assets/images/dhl.png',
                  title: 'DHL',
                  days: '2-3 days',
                  isSelected: _selectedDeliveryMethod == 2,
                  onTap: () {
                    setState(() {
                      _selectedDeliveryMethod = 2;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order:', style: TextStyle(fontSize: 16)),
                Text('112\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery:', style: TextStyle(fontSize: 16)),
                Text('15\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('127\$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigate to SuccessPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuccessPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Center(
                child: Text('SUBMIT ORDER', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Delivery Method Button widget
class DeliveryMethodButton extends StatelessWidget {
  final String image;
  final String title;
  final String days;
  final bool isSelected;
  final VoidCallback onTap;

  const DeliveryMethodButton({
    required this.image,
    required this.title,
    required this.days,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.red : Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.red.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          children: [
            Image.asset(image, width: 50), // Adjust the image width as needed
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 3),
            Text(days, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
