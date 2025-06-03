import 'package:flutter/material.dart';
import 'dart:math' as math;

class SalesChartCanvas extends StatelessWidget {
  final double height;
  final List<double> salesData;
  final List<String> labels;

  const SalesChartCanvas({
    super.key,
    required this.height,
    this.salesData = const [],
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Generate sample data if none provided
    final data = salesData.isEmpty ? _generateSampleData() : salesData;
    final chartLabels = labels.isEmpty ? _generateSampleLabels() : labels;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Title
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ventas del Último Mes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Chart Canvas
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: SalesChartPainter(
                  data: data,
                  labels: chartLabels,
                  primaryColor: Colors.blue[600]!,
                  backgroundColor: Colors.blue[50]!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateSampleData() {
    final random = math.Random();
    return List.generate(7, (index) => 20000 + random.nextDouble() * 30000);
  }

  List<String> _generateSampleLabels() {
    return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  }
}

class SalesChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color primaryColor;
  final Color backgroundColor;

  SalesChartPainter({
    required this.data,
    required this.labels,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate chart dimensions
    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Find min and max values
    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final valueRange = maxValue - minValue;

    // Draw grid lines
    const gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = padding + (chartHeight / gridLines) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );

      // Draw value labels
      final value = maxValue - (valueRange / gridLines) * i;
      textPainter.text = TextSpan(
        text: '\$${(value / 1000).toStringAsFixed(0)}k',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (chartWidth / (data.length - 1)) * i;
      final normalizedValue = (data[i] - minValue) / valueRange;
      final y = padding + chartHeight * (1 - normalizedValue);
      points.add(Offset(x, y));
    }

    // Draw fill area
    final fillPath = Path();
    if (points.isNotEmpty) {
      fillPath.moveTo(points.first.dx, size.height - padding);
      fillPath.lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      
      fillPath.lineTo(points.last.dx, size.height - padding);
      fillPath.close();
      
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 5, pointBorderPaint);
      canvas.drawCircle(point, 3, pointPaint);
    }

    // Draw x-axis labels
    for (int i = 0; i < labels.length && i < points.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          size.height - padding + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
