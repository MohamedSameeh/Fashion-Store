import 'package:intl/intl.dart';

String money(num v) => '\$${v.toStringAsFixed(2)}';

String moneyCompact(num v) => v >= 1000
    ? '\$${(v / 1000).toStringAsFixed(1)}k'
    : '\$${v.toStringAsFixed(0)}';

String shortDate(DateTime d) => DateFormat('MMM d, yyyy').format(d);
String dayMonth(DateTime d) => DateFormat('MMM d').format(d);
String dateTimeLabel(DateTime d) => DateFormat('MMM d, h:mm a').format(d);
