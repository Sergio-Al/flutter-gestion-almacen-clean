import 'package:flutter/material.dart';
import 'dart:math' as math;

class InventoryTurnoverChart extends StatefulWidget {
  final List<TurnoverDataPoint> data;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showTargetLine;
  final double? targetTurnover;

  const InventoryTurnoverChart({
    Key? key,
    required this.data,
    this.title = 'Rotación de Inventario',
    this.primaryColor = Colors.orange,
    this.secondaryColor = Colors.deepOrange,
    this.showTargetLine = true,
    this.targetTurnover = 12.0,
  }) : super(key: key);

  @override
  State<InventoryTurnoverChart> createState() => _InventoryTurnoverChartState();
}

class _InventoryTurnoverChartState extends State<InventoryTurnoverChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
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
                _buildControls(context),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: TurnoverChartPainter(
                      data: widget.data,
                      animation: _animation,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                      showTargetLine: widget.showTargetLine,
                      targetTurnover: widget.targetTurnover,
                      selectedIndex: _selectedIndex,
                      theme: theme,
                      onBarTapped: _handleBarTap,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
            if (_selectedIndex != null) ...[
              const SizedBox(height: 12),
              _buildDetailsCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _selectedIndex = null),
          icon: const Icon(Icons.clear),
          tooltip: 'Limpiar selección',
          iconSize: 20,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Objetivo: ${widget.targetTurnover?.toStringAsFixed(1)}x',
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 16,
      children: [
        _LegendItem(
          color: widget.primaryColor,
          label: 'Rotación Actual',
          theme: theme,
        ),
        if (widget.showTargetLine)
          _LegendItem(
            color: Colors.red,
            label: 'Objetivo',
            theme: theme,
            isLine: true,
          ),
        _LegendItem(
          color: Colors.green,
          label: 'Sobre Objetivo',
          theme: theme,
        ),
        _LegendItem(
          color: Colors.grey,
          label: 'Bajo Objetivo',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    if (_selectedIndex == null || _selectedIndex! >= widget.data.length) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final dataPoint = widget.data[_selectedIndex!];
    final isAboveTarget = widget.targetTurnover != null && 
                         dataPoint.turnover > widget.targetTurnover!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dataPoint.category,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isAboveTarget ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAboveTarget ? 'Óptimo' : 'Mejorar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  label: 'Rotación',
                  value: '${dataPoint.turnover.toStringAsFixed(1)}x',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  label: 'Costo Ventas',
                  value: '\$${dataPoint.cogs.toStringAsFixed(0)}',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  label: 'Inventario Promedio',
                  value: '\$${dataPoint.avgInventory.toStringAsFixed(0)}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  label: 'Días en Stock',
                  value: '${(365 / dataPoint.turnover).round()} días',
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleBarTap(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;
  final bool isLine;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
    this.isLine = false,
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
            color: isLine ? Colors.transparent : color,
            border: isLine ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isLine
              ? CustomPaint(
                  painter: _LinePainter(color: color),
                )
              : null,
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

class _LinePainter extends CustomPainter {
  final Color color;

  _LinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TurnoverChartPainter extends CustomPainter {
  final List<TurnoverDataPoint> data;
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showTargetLine;
  final double? targetTurnover;
  final int? selectedIndex;
  final ThemeData theme;
  final Function(int) onBarTapped;

  TurnoverChartPainter({
    required this.data,
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.showTargetLine,
    required this.targetTurnover,
    required this.selectedIndex,
    required this.theme,
    required this.onBarTapped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = const EdgeInsets.fromLTRB(40, 20, 20, 60);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    final maxTurnover = math.max(
      data.map((e) => e.turnover).reduce(math.max),
      targetTurnover ?? 0,
    ) * 1.1;

    // Draw grid and axes
    _drawGrid(canvas, chartRect, maxTurnover);
    _drawAxes(canvas, chartRect, maxTurnover);

    // Draw target line
    if (showTargetLine && targetTurnover != null) {
      _drawTargetLine(canvas, chartRect, maxTurnover);
    }

    // Draw bars
    _drawBars(canvas, chartRect, maxTurnover);

    // Draw labels
    _drawLabels(canvas, chartRect, size);
  }

  void _drawGrid(Canvas canvas, Rect chartRect, double maxTurnover) {
    final paint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = chartRect.bottom - (chartRect.height * i / 5);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        paint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Rect chartRect, double maxTurnover) {
    final paint = Paint()
      ..color = theme.colorScheme.outline
      ..strokeWidth = 2;

    // Y-axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      paint,
    );

    // X-axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      paint,
    );

    // Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 5; i++) {
      final value = maxTurnover * i / 5;
      final y = chartRect.bottom - (chartRect.height * i / 5);
      
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chartRect.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawTargetLine(Canvas canvas, Rect chartRect, double maxTurnover) {
    final y = chartRect.bottom - (chartRect.height * targetTurnover! / maxTurnover);
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = chartRect.left;
    
    while (startX < chartRect.right) {
      path.moveTo(startX, y);
      path.lineTo(math.min(startX + dashWidth, chartRect.right), y);
      startX += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);

    // Target line label
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: 'Objetivo: ${targetTurnover!.toStringAsFixed(1)}x',
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.red,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(chartRect.right - textPainter.width - 8, y - textPainter.height - 4),
    );
  }

  void _drawBars(Canvas canvas, Rect chartRect, double maxTurnover) {
    final barWidth = chartRect.width / (data.length * 1.5);
    final spacing = barWidth * 0.5;

    for (int i = 0; i < data.length; i++) {
      final dataPoint = data[i];
      final isSelected = selectedIndex == i;
      final isAboveTarget = targetTurnover != null && dataPoint.turnover > targetTurnover!;
      
      final barHeight = (chartRect.height * dataPoint.turnover / maxTurnover) * animation.value;
      final x = chartRect.left + (i * (barWidth + spacing)) + spacing;
      final y = chartRect.bottom - barHeight;

      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);

      // Bar gradient
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isAboveTarget
              ? [Colors.green.shade400, Colors.green.shade600]
              : [primaryColor.withOpacity(0.8), primaryColor],
        ).createShader(barRect);

      // Selected bar effect
      if (isSelected) {
        final selectedPaint = Paint()
          ..color = theme.colorScheme.primary.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            barRect.inflate(2),
            const Radius.circular(4),
          ),
          selectedPaint,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        paint,
      );

      // Value label on top of bar
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: dataPoint.turnover.toStringAsFixed(1),
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          y - textPainter.height - 4,
        ),
      );
    }
  }

  void _drawLabels(Canvas canvas, Rect chartRect, Size size) {
    final barWidth = chartRect.width / (data.length * 1.5);
    final spacing = barWidth * 0.5;

    for (int i = 0; i < data.length; i++) {
      final x = chartRect.left + (i * (barWidth + spacing)) + spacing;
      
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: data[i].category,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
      textPainter.layout();

      // Rotate text if it doesn't fit
      canvas.save();
      final textX = x + barWidth / 2;
      final textY = chartRect.bottom + 8;
      
      if (textPainter.width > barWidth) {
        canvas.translate(textX, textY + textPainter.width);
        canvas.rotate(-math.pi / 2);
        textPainter.paint(canvas, Offset.zero);
      } else {
        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TurnoverChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.data != data;
  }

  @override
  bool hitTest(Offset position) => true;
}

class TurnoverDataPoint {
  final String category;
  final double turnover;
  final double cogs; // Cost of Goods Sold
  final double avgInventory;

  TurnoverDataPoint({
    required this.category,
    required this.turnover,
    required this.cogs,
    required this.avgInventory,
  });
}

// Sample data for testing
class TurnoverChartSampleData {
  static List<TurnoverDataPoint> getSample() {
    return [
      TurnoverDataPoint(
        category: 'Electrónicos',
        turnover: 15.2,
        cogs: 450000,
        avgInventory: 29600,
      ),
      TurnoverDataPoint(
        category: 'Ropa',
        turnover: 8.5,
        cogs: 280000,
        avgInventory: 32900,
      ),
      TurnoverDataPoint(
        category: 'Hogar',
        turnover: 6.3,
        cogs: 180000,
        avgInventory: 28600,
      ),
      TurnoverDataPoint(
        category: 'Deportes',
        turnover: 12.8,
        cogs: 320000,
        avgInventory: 25000,
      ),
      TurnoverDataPoint(
        category: 'Libros',
        turnover: 4.2,
        cogs: 95000,
        avgInventory: 22600,
      ),
      TurnoverDataPoint(
        category: 'Juguetes',
        turnover: 9.7,
        cogs: 240000,
        avgInventory: 24700,
      ),
    ];
  }
}
