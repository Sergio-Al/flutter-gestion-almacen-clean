import 'package:uuid/uuid.dart';

class AppUtils {
  static const _uuid = Uuid();
  
  // Generate unique IDs
  static String generateId() => _uuid.v4();
  
  // Generate SKU
  static String generateSku(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$prefix-${timestamp.substring(timestamp.length - 6)}';
  }
  
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  // Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  // Check if stock is low
  static bool isLowStock(int currentStock, int reorderPoint) {
    return currentStock <= reorderPoint;
  }
  
  // Check if batch is expiring soon
  static bool isExpiringSoon(DateTime? expiryDate, {int daysThreshold = 30}) {
    if (expiryDate == null) return false;
    final threshold = DateTime.now().add(Duration(days: daysThreshold));
    return expiryDate.isBefore(threshold);
  }
}
