import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WarehouseMapCanvas extends ConsumerStatefulWidget {
  final String warehouseId;
  final bool isInteractive;
  final double? height;

  const WarehouseMapCanvas({
    super.key,
    required this.warehouseId,
    this.isInteractive = true,
    this.height,
  });

  @override
  ConsumerState<WarehouseMapCanvas> createState() => _WarehouseMapCanvasState();
}

class _WarehouseMapCanvasState extends ConsumerState<WarehouseMapCanvas> {
  Offset? _selectedZone;
  double _scale = 1.0;
  final TransformationController _transformationController = TransformationController();

  // Mock warehouse zones data
  final List<WarehouseZone> _zones = [
    WarehouseZone(
      id: 'A1',
      name: 'Zone A1',
      rect: const Rect.fromLTWH(20, 20, 80, 60),
      occupancy: 0.85,
      category: 'Electronics',
      color: Colors.blue,
    ),
    WarehouseZone(
      id: 'A2',
      name: 'Zone A2',
      rect: const Rect.fromLTWH(120, 20, 80, 60),
      occupancy: 0.65,
      category: 'Clothing',
      color: Colors.green,
    ),
    WarehouseZone(
      id: 'B1',
      name: 'Zone B1',
      rect: const Rect.fromLTWH(20, 100, 80, 60),
      occupancy: 0.95,
      category: 'Food',
      color: Colors.orange,
    ),
    WarehouseZone(
      id: 'B2',
      name: 'Zone B2',
      rect: const Rect.fromLTWH(120, 100, 80, 60),
      occupancy: 0.45,
      category: 'Books',
      color: Colors.purple,
    ),
    WarehouseZone(
      id: 'C1',
      name: 'Zone C1',
      rect: const Rect.fromLTWH(20, 180, 80, 60),
      occupancy: 0.75,
      category: 'Tools',
      color: Colors.red,
    ),
    WarehouseZone(
      id: 'C2',
      name: 'Zone C2',
      rect: const Rect.fromLTWH(120, 180, 60, 60),
      occupancy: 0.30,
      category: 'Furniture',
      color: Colors.brown,
    ),
  ];

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Color _getZoneColor(WarehouseZone zone) {
    if (zone.occupancy >= 0.9) {
      return Colors.red.withOpacity(0.7);
    } else if (zone.occupancy >= 0.7) {
      return Colors.orange.withOpacity(0.7);
    } else if (zone.occupancy >= 0.5) {
      return Colors.yellow.withOpacity(0.7);
    } else {
      return Colors.green.withOpacity(0.7);
    }
  }

  void _onZoneTap(WarehouseZone zone, Offset position) {
    if (!widget.isInteractive) return;

    setState(() {
      _selectedZone = position;
    });

    _showZoneDetails(zone);
  }

  void _showZoneDetails(WarehouseZone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zone ${zone.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category:', zone.category),
            const SizedBox(height: 8),
            _buildDetailRow('Occupancy:', '${(zone.occupancy * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            _buildDetailRow('Status:', _getStatusText(zone.occupancy)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: zone.occupancy,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getZoneColor(zone)),
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
              // Navigate to zone details or inventory
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${zone.name} inventory...')),
              );
            },
            child: const Text('View Inventory'),
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

  String _getStatusText(double occupancy) {
    if (occupancy >= 0.9) return 'Critical';
    if (occupancy >= 0.7) return 'High';
    if (occupancy >= 0.5) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height ?? 400,
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
                Icon(Icons.map_outlined, color: theme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Warehouse Layout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (widget.isInteractive) ...[
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      setState(() {
                        _scale = (_scale / 1.2).clamp(0.5, 3.0);
                        _transformationController.value = Matrix4.identity()..scale(_scale);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      setState(() {
                        _scale = (_scale * 1.2).clamp(0.5, 3.0);
                        _transformationController.value = Matrix4.identity()..scale(_scale);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // Map Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.isInteractive
                  ? InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: _buildCanvas(),
                    )
                  : _buildCanvas(),
            ),
          ),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: WarehouseMapPainter(
          zones: _zones,
          selectedZone: _selectedZone,
          onZoneTap: _onZoneTap,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Occupancy Levels:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem('Critical (>90%)', Colors.red),
            _buildLegendItem('High (70-90%)', Colors.orange),
            _buildLegendItem('Medium (50-70%)', Colors.yellow),
            _buildLegendItem('Low (<50%)', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class WarehouseZone {
  final String id;
  final String name;
  final Rect rect;
  final double occupancy;
  final String category;
  final Color color;

  const WarehouseZone({
    required this.id,
    required this.name,
    required this.rect,
    required this.occupancy,
    required this.category,
    required this.color,
  });
}

class WarehouseMapPainter extends CustomPainter {
  final List<WarehouseZone> zones;
  final Offset? selectedZone;
  final Function(WarehouseZone, Offset) onZoneTap;

  WarehouseMapPainter({
    required this.zones,
    this.selectedZone,
    required this.onZoneTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw warehouse outline
    final warehousePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.grey[600]!;
    
    canvas.drawRect(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      warehousePaint,
    );

    // Scale zones to fit canvas
    final scaleX = (size.width - 40) / 240;
    final scaleY = (size.height - 40) / 260;

    for (final zone in zones) {
      final scaledRect = Rect.fromLTWH(
        20 + zone.rect.left * scaleX,
        20 + zone.rect.top * scaleY,
        zone.rect.width * scaleX,
        zone.rect.height * scaleY,
      );

      // Zone color based on occupancy
      Color zoneColor;
      if (zone.occupancy >= 0.9) {
        zoneColor = Colors.red.withOpacity(0.7);
      } else if (zone.occupancy >= 0.7) {
        zoneColor = Colors.orange.withOpacity(0.7);
      } else if (zone.occupancy >= 0.5) {
        zoneColor = Colors.yellow.withOpacity(0.7);
      } else {
        zoneColor = Colors.green.withOpacity(0.7);
      }

      paint.color = zoneColor;
      borderPaint.color = zoneColor.withOpacity(1.0);

      // Draw zone
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)),
        borderPaint,
      );

      // Draw zone label
      textPainter.text = TextSpan(
        text: zone.id,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          scaledRect.center.dx - textPainter.width / 2,
          scaledRect.center.dy - textPainter.height / 2 - 8,
        ),
      );

      // Draw occupancy percentage
      textPainter.text = TextSpan(
        text: '${(zone.occupancy * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          scaledRect.center.dx - textPainter.width / 2,
          scaledRect.center.dy - textPainter.height / 2 + 4,
        ),
      );
    }

    // Draw entrance/exit
    final entrancePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 15, size.height - 20, 30, 10),
      entrancePaint,
    );
    
    textPainter.text = const TextSpan(
      text: 'ENTRANCE',
      style: TextStyle(
        color: Colors.blue,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height - 35,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
