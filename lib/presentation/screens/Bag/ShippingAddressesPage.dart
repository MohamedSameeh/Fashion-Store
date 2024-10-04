import 'package:flutter/material.dart';

class ShippingAddressesPage extends StatefulWidget {
  @override
  _ShippingAddressesPageState createState() => _ShippingAddressesPageState();
}

class _ShippingAddressesPageState extends State<ShippingAddressesPage> {
  List<Address> addresses = [
    Address(name: 'Menna ELwan', address: '3 Newbridge Court\nChino Hills, CA 91709, United States', isSelected: true),
    Address(name: 'Menna Haleem', address: '3 Newbridge Court\nChino Hills, CA 91709, United States', isSelected: false),
    Address(name: 'John Doe', address: '51 Riverside\nChino Hills, CA 91709, United States', isSelected: false),
  ];

  void _addNewAddress() {
    // Show dialog or navigate to a new page to add address
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        String newAddress = '';
        return AlertDialog(
          title: Text('Add New Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  newAddress = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty && newAddress.isNotEmpty) {
                  setState(() {
                    addresses.add(Address(name: newName, address: newAddress, isSelected: false));
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editAddress(int index) {
    // Show dialog or navigate to a new page to edit address
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedName = addresses[index].name;
        String editedAddress = addresses[index].address;
        return AlertDialog(
          title: Text('Edit Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  editedName = value;
                },
                controller: TextEditingController(text: addresses[index].name),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) {
                  editedAddress = value;
                },
                controller: TextEditingController(text: addresses[index].address),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (editedName.isNotEmpty && editedAddress.isNotEmpty) {
                  setState(() {
                    addresses[index] = Address(name: editedName, address: editedAddress, isSelected: addresses[index].isSelected);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(bool? value, int index) {
    setState(() {
      addresses[index].isSelected = value!;
    });
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
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          'Shipping Addresses',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address List
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return AddressCard(
                    name: addresses[index].name,
                    address: addresses[index].address,
                    isSelected: addresses[index].isSelected,
                    onEdit: () => _editAddress(index),
                    onSelect: (value) => _toggleSelection(value, index),
                  );
                },
              ),
            ),
            FloatingActionButton(
              onPressed: _addNewAddress,
              child: Icon(Icons.add),
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class Address {
  String name;
  String address;
  bool isSelected;

  Address({required this.name, required this.address, required this.isSelected});
}

class AddressCard extends StatelessWidget {
  final String name;
  final String address;
  final bool isSelected;
  final Function() onEdit;
  final ValueChanged<bool?> onSelect;

  const AddressCard({
    required this.name,
    required this.address,
    required this.isSelected,
    required this.onEdit,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(address),
        trailing: TextButton(
          onPressed: onEdit,
          child: Text('Edit', style: TextStyle(color: Colors.red)),
        ),
        leading: Checkbox(
          value: isSelected,
          onChanged: onSelect,
        ),
      ),
    );
  }
}
