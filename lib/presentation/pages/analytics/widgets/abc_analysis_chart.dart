import 'package:flutter/material.dart';
import 'dart:math' as math;

class AbcAnalysisChart extends StatefulWidget {
  final List<AbcDataPoint> data;
  final String title;
  final bool showPercentages;
  final bool showValues;

  const AbcAnalysisChart({
    Key? key,
    required this.data,
    this.title = 'Análisis ABC',
    this.showPercentages = true,
    this.showValues = true,
  }) : super(key: key);

  @override
  State<AbcAnalysisChart> createState() => _AbcAnalysisChartState();
}

class _AbcAnalysisChartState extends State<AbcAnalysisChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  AbcCategory? _selectedCategory;

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
                _buildControls(context),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return GestureDetector(
                          onTapDown: _handleTap,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: AbcPieChartPainter(
                              data: widget.data,
                              animation: _animation,
                              selectedCategory: _selectedCategory,
                              theme: theme,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Statistics
                Expanded(
                  flex: 1,
                  child: _buildStatistics(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 16),
              _buildDetailsCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _selectedCategory = null),
          icon: const Icon(Icons.clear),
          tooltip: 'Limpiar selección',
          iconSize: 20,
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Exportar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final categoryA = widget.data.firstWhere((d) => d.category == AbcCategory.A);
    final categoryB = widget.data.firstWhere((d) => d.category == AbcCategory.B);
    final categoryC = widget.data.firstWhere((d) => d.category == AbcCategory.C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _StatisticItem(
          category: 'Categoría A',
          items: categoryA.itemCount,
          value: categoryA.value,
          percentage: categoryA.valuePercentage,
          color: AbcColors.categoryA,
          theme: theme,
        ),
        const SizedBox(height: 8),
        _StatisticItem(
          category: 'Categoría B',
          items: categoryB.itemCount,
          value: categoryB.value,
          percentage: categoryB.valuePercentage,
          color: AbcColors.categoryB,
          theme: theme,
        ),
        const SizedBox(height: 8),
        _StatisticItem(
          category: 'Categoría C',
          items: categoryC.itemCount,
          value: categoryC.value,
          percentage: categoryC.valuePercentage,
          color: AbcColors.categoryC,
          theme: theme,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Total Items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${categoryA.itemCount + categoryB.itemCount + categoryC.itemCount}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criterios ABC',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendItem(
              color: AbcColors.categoryA,
              label: 'A - Alto valor (70-80%)',
              description: 'Productos críticos',
              theme: theme,
            ),
            _LegendItem(
              color: AbcColors.categoryB,
              label: 'B - Valor medio (15-25%)',
              description: 'Productos importantes',
              theme: theme,
            ),
            _LegendItem(
              color: AbcColors.categoryC,
              label: 'C - Bajo valor (5-10%)',
              description: 'Productos básicos',
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    if (_selectedCategory == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final selectedData = widget.data.firstWhere((d) => d.category == _selectedCategory);
    final categoryName = _getCategoryName(_selectedCategory!);
    final categoryColor = _getCategoryColor(_selectedCategory!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedCategory!.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoryName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailMetric(
                  label: 'Cantidad de Items',
                  value: selectedData.itemCount.toString(),
                  theme: theme,
                ),
              ),
              Expanded(
                child: _DetailMetric(
                  label: 'Valor Total',
                  value: '\$${selectedData.value.toStringAsFixed(0)}',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailMetric(
                  label: '% del Valor Total',
                  value: '${selectedData.valuePercentage.toStringAsFixed(1)}%',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _DetailMetric(
                  label: '% de Items',
                  value: '${selectedData.itemPercentage.toStringAsFixed(1)}%',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getCategoryRecommendation(_selectedCategory!),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    // Simple tap detection for pie chart segments
    // In a real implementation, you'd calculate which segment was tapped
    final categories = [AbcCategory.A, AbcCategory.B, AbcCategory.C];
    final selectedIndex = (_selectedCategory?.index ?? -1) + 1;
    final newCategory = categories[selectedIndex % categories.length];
    
    setState(() {
      _selectedCategory = _selectedCategory == newCategory ? null : newCategory;
    });
  }

  String _getCategoryName(AbcCategory category) {
    switch (category) {
      case AbcCategory.A:
        return 'Categoría A - Alto Valor';
      case AbcCategory.B:
        return 'Categoría B - Valor Medio';
      case AbcCategory.C:
        return 'Categoría C - Bajo Valor';
    }
  }

  Color _getCategoryColor(AbcCategory category) {
    switch (category) {
      case AbcCategory.A:
        return AbcColors.categoryA;
      case AbcCategory.B:
        return AbcColors.categoryB;
      case AbcCategory.C:
        return AbcColors.categoryC;
    }
  }

  String _getCategoryRecommendation(AbcCategory category) {
    switch (category) {
      case AbcCategory.A:
        return 'Recomendación: Gestión intensiva, control diario, inventarios mínimos de seguridad.';
      case AbcCategory.B:
        return 'Recomendación: Gestión moderada, control semanal, inventarios intermedios.';
      case AbcCategory.C:
        return 'Recomendación: Gestión simple, control mensual, inventarios de oportunidad.';
    }
  }
}

class _StatisticItem extends StatelessWidget {
  final String category;
  final int items;
  final double value;
  final double percentage;
  final Color color;
  final ThemeData theme;

  const _StatisticItem({
    required this.category,
    required this.items,
    required this.value,
    required this.percentage,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$items items - ${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String description;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.description,
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
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailMetric({
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AbcPieChartPainter extends CustomPainter {
  final List<AbcDataPoint> data;
  final Animation<double> animation;
  final AbcCategory? selectedCategory;
  final ThemeData theme;

  AbcPieChartPainter({
    required this.data,
    required this.animation,
    required this.selectedCategory,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    final totalValue = data.fold(0.0, (sum, item) => sum + item.value);
    double startAngle = -math.pi / 2;

    for (final dataPoint in data) {
      final sweepAngle = (dataPoint.value / totalValue) * 2 * math.pi * animation.value;
      final isSelected = selectedCategory == dataPoint.category;
      final currentRadius = isSelected ? radius + 10 : radius;
      
      final paint = Paint()
        ..color = _getCategoryColor(dataPoint.category)
        ..style = PaintingStyle.fill;

      // Draw pie segment
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw segment border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw percentage label
      if (sweepAngle > 0.2) { // Only show label if segment is large enough
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = currentRadius * 0.7;
        final labelX = center.dx + labelRadius * math.cos(labelAngle);
        final labelY = center.dy + labelRadius * math.sin(labelAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${dataPoint.valuePercentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw center label
    final centerTextPainter = TextPainter(
      text: TextSpan(
        text: 'ABC\nAnálisis',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(
        center.dx - centerTextPainter.width / 2,
        center.dy - centerTextPainter.height / 2,
      ),
    );
  }

  Color _getCategoryColor(AbcCategory category) {
    switch (category) {
      case AbcCategory.A:
        return AbcColors.categoryA;
      case AbcCategory.B:
        return AbcColors.categoryB;
      case AbcCategory.C:
        return AbcColors.categoryC;
    }
  }

  @override
  bool shouldRepaint(AbcPieChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.selectedCategory != selectedCategory ||
           oldDelegate.data != data;
  }
}

enum AbcCategory { A, B, C }

class AbcColors {
  static const Color categoryA = Color(0xFF4CAF50); // Green
  static const Color categoryB = Color(0xFFFF9800); // Orange  
  static const Color categoryC = Color(0xFFFF5722); // Red
}

class AbcDataPoint {
  final AbcCategory category;
  final int itemCount;
  final double value;
  final double valuePercentage;
  final double itemPercentage;

  AbcDataPoint({
    required this.category,
    required this.itemCount,
    required this.value,
    required this.valuePercentage,
    required this.itemPercentage,
  });
}

// Sample data for testing
class AbcAnalysisSampleData {
  static List<AbcDataPoint> getSample() {
    return [
      AbcDataPoint(
        category: AbcCategory.A,
        itemCount: 45,
        value: 750000,
        valuePercentage: 78.5,
        itemPercentage: 15.0,
      ),
      AbcDataPoint(
        category: AbcCategory.B,
        itemCount: 85,
        value: 150000,
        valuePercentage: 15.7,
        itemPercentage: 28.3,
      ),
      AbcDataPoint(
        category: AbcCategory.C,
        itemCount: 170,
        value: 55000,
        valuePercentage: 5.8,
        itemPercentage: 56.7,
      ),
    ];
  }
}
