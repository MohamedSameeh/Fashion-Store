import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderCard({required this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderItems = List<Map<String, dynamic>>.from(order['orderItems']);
    final orderDate = (order['orderDate'] as Timestamp).toDate();
    final formattedDate =
        DateFormat('MMMM dd, yyyy – h:mm a').format(orderDate);

    Color statusColor;
    IconData statusIcon;

    switch (order['status']) {
      case 'Delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Shipped':
        statusColor = Colors.blueAccent;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'Processing':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: ExpandablePanel(
          header: ListTile(
            title: Text(
              'Order Total: \$${order['totalAmount'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              'Ordered on: $formattedDate',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 4),
                Text(
                  order['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          expanded: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                ...orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('x${item['quantity']}',
                            style: const TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            item['proname'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text('\$${item['proprice'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${order['totalAmount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Changed to red
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          theme: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: Colors.grey,
            expandIcon: Icons.keyboard_arrow_down,
            collapseIcon: Icons.keyboard_arrow_up,
          ),
          collapsed: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
