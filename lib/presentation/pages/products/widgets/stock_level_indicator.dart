import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockLevelIndicator extends ConsumerWidget {
  final String productId;
  final int reorderPoint;
  final int? currentStock;

  const StockLevelIndicator({
    Key? key,
    required this.productId,
    required this.reorderPoint,
    this.currentStock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement actual stock retrieval from stock repository
    // For now, using mock data
    final stock = currentStock ?? _getMockStock();
    
    final stockLevel = _getStockLevel(stock, reorderPoint);
    final stockColor = _getStockColor(stockLevel);
    final stockIcon = _getStockIcon(stockLevel);
    final stockText = _getStockText(stockLevel, stock);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stockIcon,
            size: 16,
            color: stockColor,
          ),
          const SizedBox(width: 4),
          Text(
            stockText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: stockColor,
            ),
          ),
        ],
      ),
    );
  }

  StockLevel _getStockLevel(int stock, int reorderPoint) {
    if (stock == 0) {
      return StockLevel.outOfStock;
    } else if (stock <= reorderPoint) {
      return StockLevel.low;
    } else if (stock <= reorderPoint * 2) {
      return StockLevel.medium;
    } else {
      return StockLevel.high;
    }
  }

  Color _getStockColor(StockLevel level) {
    switch (level) {
      case StockLevel.outOfStock:
        return Colors.red;
      case StockLevel.low:
        return Colors.orange;
      case StockLevel.medium:
        return Colors.yellow[700]!;
      case StockLevel.high:
        return Colors.green;
    }
  }

  IconData _getStockIcon(StockLevel level) {
    switch (level) {
      case StockLevel.outOfStock:
        return Icons.error;
      case StockLevel.low:
        return Icons.warning;
      case StockLevel.medium:
        return Icons.info;
      case StockLevel.high:
        return Icons.check_circle;
    }
  }

  String _getStockText(StockLevel level, int stock) {
    switch (level) {
      case StockLevel.outOfStock:
        return 'Sin Stock';
      case StockLevel.low:
        return 'Bajo ($stock)';
      case StockLevel.medium:
        return 'Medio ($stock)';
      case StockLevel.high:
        return 'Alto ($stock)';
    }
  }

  // Mock stock data - replace with actual implementation
  int _getMockStock() {
    final hash = productId.hashCode.abs();
    return hash % 100; // Random stock between 0-99
  }
}

enum StockLevel {
  outOfStock,
  low,
  medium,
  high,
}
