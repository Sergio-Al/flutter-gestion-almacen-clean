import 'package:flutter/material.dart';

class RevenueChartCanvas extends StatefulWidget {
  final List<RevenueDataPoint> data;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showGrid;
  final bool showDots;

  const RevenueChartCanvas({
    Key? key,
    required this.data,
    this.title = 'Ingresos',
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.lightBlue,
    this.showGrid = true,
    this.showDots = true,
  }) : super(key: key);

  @override
  State<RevenueChartCanvas> createState() => _RevenueChartCanvasState();
}

class _RevenueChartCanvasState extends State<RevenueChartCanvas>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(context),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return MouseRegion(
                    onHover: _handleHover,
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: RevenueChartPainter(
                        data: widget.data,
                        animation: _animation,
                        primaryColor: widget.primaryColor,
                        secondaryColor: widget.secondaryColor,
                        showGrid: widget.showGrid,
                        showDots: widget.showDots,
                        hoveredIndex: _hoveredIndex,
                        theme: theme,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_hoveredIndex != null) ...[
              const SizedBox(height: 8),
              _buildTooltip(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        _LegendItem(
          color: widget.primaryColor,
          label: 'Ingresos',
          theme: theme,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: widget.secondaryColor.withOpacity(0.5),
          label: 'Tendencia',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTooltip(BuildContext context) {
    if (_hoveredIndex == null || _hoveredIndex! >= widget.data.length) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final dataPoint = widget.data[_hoveredIndex!];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dataPoint.label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${dataPoint.value.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleHover(PointerEvent event) {
    // Simple hover detection based on horizontal position
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);
    final chartWidth = renderBox.size.width - 32; // Account for padding
    final stepWidth = chartWidth / (widget.data.length - 1);
    final index = (localPosition.dx - 16) ~/ stepWidth;
    
    if (index >= 0 && index < widget.data.length) {
      setState(() => _hoveredIndex = index);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  final List<RevenueDataPoint> data;
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showGrid;
  final bool showDots;
  final int? hoveredIndex;
  final ThemeData theme;

  RevenueChartPainter({
    required this.data,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.showGrid,
    required this.showDots,
    required this.hoveredIndex,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    // Calculate chart bounds
    final padding = const EdgeInsets.all(20);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    // Find min and max values
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, chartRect, maxValue, minValue);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (chartRect.width * i / (data.length - 1));
      final normalizedValue = valueRange > 0 ? (data[i].value - minValue) / valueRange : 0.5;
      final y = chartRect.bottom - (chartRect.height * normalizedValue * animation.value);
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    if (points.length > 1) {
      _drawGradientFill(canvas, points, chartRect, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      paint.color = primaryColor;
      _drawLine(canvas, points, paint);
    }

    // Draw dots
    if (showDots) {
      _drawDots(canvas, points, dotPaint);
    }

    // Draw labels
    _drawLabels(canvas, chartRect, maxValue, minValue);
  }

  void _drawGrid(Canvas canvas, Rect chartRect, double maxValue, double minValue) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.bottom - (chartRect.height * i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (chartRect.width * i / (data.length - 1));
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }
  }

  void _drawGradientFill(Canvas canvas, List<Offset> points, Rect chartRect, Paint fillPaint) {
    final path = Path();
    path.moveTo(chartRect.left, chartRect.bottom);
    
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    
    path.lineTo(chartRect.right, chartRect.bottom);
    path.close();

    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withOpacity(0.3),
        primaryColor.withOpacity(0.1),
        primaryColor.withOpacity(0.0),
      ],
    ).createShader(chartRect);

    canvas.drawPath(path, fillPaint);
  }

  void _drawLine(Canvas canvas, List<Offset> points, Paint paint) {
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      // Create smooth curves between points
      if (i == 1) {
        path.lineTo(points[i].dx, points[i].dy);
      } else {
        final cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 3;
        final cp1y = points[i - 1].dy;
        final cp2x = points[i].dx - (points[i].dx - points[i - 1].dx) / 3;
        final cp2y = points[i].dy;
        
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDots(Canvas canvas, List<Offset> points, Paint dotPaint) {
    for (int i = 0; i < points.length; i++) {
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 6.0 : 4.0;
      
      // Outer circle
      dotPaint.color = primaryColor;
      canvas.drawCircle(points[i], radius, dotPaint);
      
      // Inner circle
      dotPaint.color = Colors.white;
      canvas.drawCircle(points[i], radius - 1.5, dotPaint);
    }
  }

  void _drawLabels(Canvas canvas, Rect chartRect, double maxValue, double minValue) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (maxValue - minValue) * i / 4;
      final y = chartRect.bottom - (chartRect.height * i / 4);
      
      textPainter.text = TextSpan(
        text: '\$${value.toStringAsFixed(0)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(RevenueChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.hoveredIndex != hoveredIndex ||
           oldDelegate.data != data;
  }
}

class RevenueDataPoint {
  final String label;
  final double value;
  final DateTime date;

  RevenueDataPoint({
    required this.label,
    required this.value,
    required this.date,
  });
}

// Sample data for testing
class RevenueChartSampleData {
  static List<RevenueDataPoint> getMonthlySample() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - 11 + index);
      final value = 10000 + (index * 2000) + (index % 3 * 5000);
      return RevenueDataPoint(
        label: _getMonthName(date.month),
        value: value.toDouble(),
        date: date,
      );
    });
  }

  static List<RevenueDataPoint> getWeeklySample() {
    final now = DateTime.now();
    return List.generate(8, (index) {
      final date = now.subtract(Duration(days: (7 - index) * 7));
      final value = 15000 + (index * 3000) + (index % 2 * 2000);
      return RevenueDataPoint(
        label: 'Sem ${index + 1}',
        value: value.toDouble(),
        date: date,
      );
    });
  }

  static String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}
