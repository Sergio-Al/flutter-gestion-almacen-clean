import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class StockDistributionChart extends ConsumerStatefulWidget {
  final String warehouseId;
  final double? height;
  final bool showLegend;
  final bool isInteractive;

  const StockDistributionChart({
    super.key,
    required this.warehouseId,
    this.height,
    this.showLegend = true,
    this.isInteractive = true,
  });

  @override
  ConsumerState<StockDistributionChart> createState() => _StockDistributionChartState();
}

class _StockDistributionChartState extends ConsumerState<StockDistributionChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;

  // Mock stock distribution data
  final List<StockCategory> _stockData = [
    StockCategory(
      name: 'Electronics',
      value: 2500,
      percentage: 35.0,
      color: Colors.blue,
      icon: Icons.devices,
    ),
    StockCategory(
      name: 'Clothing',
      value: 1800,
      percentage: 25.0,
      color: Colors.green,
      icon: Icons.checkroom,
    ),
    StockCategory(
      name: 'Food & Beverages',
      value: 1200,
      percentage: 17.0,
      color: Colors.orange,
      icon: Icons.restaurant,
    ),
    StockCategory(
      name: 'Books & Media',
      value: 900,
      percentage: 13.0,
      color: Colors.purple,
      icon: Icons.book,
    ),
    StockCategory(
      name: 'Tools & Hardware',
      value: 500,
      percentage: 7.0,
      color: Colors.red,
      icon: Icons.build,
    ),
    StockCategory(
      name: 'Others',
      value: 200,
      percentage: 3.0,
      color: Colors.grey,
      icon: Icons.category,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSegmentTap(int index) {
    if (!widget.isInteractive) return;

    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });

    if (_selectedIndex != null) {
      final category = _stockData[_selectedIndex!];
      _showCategoryDetails(category);
    }
  }

  void _showCategoryDetails(StockCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Total Items:', '${category.value.toStringAsFixed(0)} units'),
            const SizedBox(height: 8),
            _buildDetailRow('Percentage:', '${category.percentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            _buildDetailRow('Estimated Value:', '\$${(category.value * 15.5).toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: category.percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${category.name} inventory...')),
              );
            },
            child: const Text('View Items'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height ?? 350,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Stock Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${_stockData.fold(0, (sum, item) => sum + item.value.toInt())} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Chart and Legend
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: widget.showLegend ? 3 : 5,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return AspectRatio(
                          aspectRatio: 1,
                          child: CustomPaint(
                            painter: PieChartPainter(
                              data: _stockData,
                              animation: _animation.value,
                              selectedIndex: _selectedIndex,
                              onTap: _onSegmentTap,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Legend
                  if (widget.showLegend) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildLegend(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: _buildBottomStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _stockData.length,
            itemBuilder: (context, index) {
              final category = _stockData[index];
              final isSelected = _selectedIndex == index;
              
              return GestureDetector(
                onTap: () => _onSegmentTap(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: category.color) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${category.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStats() {
    final totalValue = _stockData.fold(0.0, (sum, item) => sum + item.value);
    final avgValue = totalValue / _stockData.length;
    final maxCategory = _stockData.reduce((a, b) => a.value > b.value ? a : b);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            '${avgValue.toStringAsFixed(0)} items',
            Icons.trending_flat,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Highest',
            maxCategory.name,
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Categories',
            '${_stockData.length}',
            Icons.category,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StockCategory {
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final IconData icon;

  const StockCategory({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class PieChartPainter extends CustomPainter {
  final List<StockCategory> data;
  final double animation;
  final int? selectedIndex;
  final Function(int) onTap;

  PieChartPainter({
    required this.data,
    required this.animation,
    this.selectedIndex,
    required this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < data.length; i++) {
      final category = data[i];
      final sweepAngle = (category.percentage / 100) * 2 * math.pi * animation;
      final isSelected = selectedIndex == i;
      
      // Calculate the radius for selected segment
      final segmentRadius = isSelected ? radius + 10 : radius;
      
      // Calculate center offset for selected segment
      final segmentCenter = isSelected
          ? Offset(
              center.dx + (math.cos(startAngle + sweepAngle / 2) * 5),
              center.dy + (math.sin(startAngle + sweepAngle / 2) * 5),
            )
          : center;

      paint.color = category.color;
      
      // Draw the segment
      canvas.drawArc(
        Rect.fromCircle(center: segmentCenter, radius: segmentRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw stroke
      canvas.drawArc(
        Rect.fromCircle(center: segmentCenter, radius: segmentRadius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      // Draw percentage label for larger segments
      if (category.percentage > 5 && animation > 0.8) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = segmentRadius * 0.7;
        final labelOffset = Offset(
          segmentCenter.dx + math.cos(labelAngle) * labelRadius,
          segmentCenter.dy + math.sin(labelAngle) * labelRadius,
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${category.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelOffset.dx - textPainter.width / 2,
            labelOffset.dy - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle
    if (animation > 0.5) {
      paint.color = Colors.white;
      canvas.drawCircle(center, radius * 0.3, paint);
      
      strokePaint.strokeWidth = 1;
      strokePaint.color = Colors.grey[300]!;
      canvas.drawCircle(center, radius * 0.3, strokePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
