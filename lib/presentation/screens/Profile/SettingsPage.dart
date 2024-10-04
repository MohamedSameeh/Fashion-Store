import 'package:depi_final_project/presentation/screens/register/forgotPassword.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSalesOn = true;
  bool isNewArrivalsOn = false;
  bool isDeliveryStatusOn = false;

  // Date of birth controller
  TextEditingController dateController = TextEditingController();

  // Initial selected date
  DateTime selectedDate = DateTime(1989, 12, 12);

  @override
  void initState() {
    super.initState();
    // Set the initial date of birth in the TextField
    dateController.text = formatDate(selectedDate);
  }

  // Function to show date picker and handle selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(), // Use light theme for the date picker
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = formatDate(selectedDate); // Format the date
      });
    }
  }

  // Custom function to format the date as MM/DD/YYYY
  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _selectDate(context); // Show the date picker when tapped
              },
              child: AbsorbPointer( // Prevent user from manually editing the date field
                child: TextField(
                  controller: dateController, // Controller for date field
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    // Navigate to forgotPassword.dart page using MaterialPageRoute
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotpasswordScreen(),
                      ),
                    );
                  },
                  child: Text('Change', style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '***********',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: Text('Sales'),
                    value: isSalesOn,
                    onChanged: (bool value) {
                      setState(() {
                        isSalesOn = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('New Arrivals'),
                    value: isNewArrivalsOn,
                    onChanged: (bool value) {
                      setState(() {
                        isNewArrivalsOn = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Delivery Status Changes'),
                    value: isDeliveryStatusOn,
                    onChanged: (bool value) {
                      setState(() {
                        isDeliveryStatusOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
