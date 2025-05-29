import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class SalesChart extends StatelessWidget {
  final List<({DateTime date, double amount})> data;
  
  const SalesChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Encontrar el valor máximo para escalar el gráfico
    double maxValue = data.fold(0.0, (max, item) => math.max(max, item.amount));
    
    // Formato para fechas
    final dateFormat = DateFormat('MMM d');
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // Calcular ancho de cada barra (con espacio entre ellas)
        final availableWidth = width - 40;  // márgenes
        final barSpace = availableWidth / data.length;
        final barWidth = barSpace * 0.6;
        
        return Stack(
          children: [
            // Líneas horizontales de referencia
            ...List.generate(5, (index) {
              final y = height - (height * (index / 4)) - 30;
              return Positioned(
                left: 0,
                top: y,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
              );
            }),
            
            // Chart data
            CustomPaint(
              size: Size(width, height),
              painter: LineChartPainter(data: data, maxValue: maxValue),
            ),
            
            // X-Axis labels (fechas)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < data.length; i += data.length ~/ 5)
                    if (i < data.length)
                      Text(
                        dateFormat.format(data[i].date),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<({DateTime date, double amount})> data;
  final double maxValue;
  
  LineChartPainter({required this.data, required this.maxValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height - 30; // Espacio para las etiquetas del eje X
    final width = size.width;
    
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.3),
          Colors.blue.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * width;
      final y = height - ((data[i].amount / maxValue) * height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Completar el path de relleno
    if (data.isNotEmpty) {
      fillPath.lineTo(width, height);
      fillPath.lineTo(0, height);
      fillPath.close();
    }
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Dibujar puntos en los datos
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
      
    final pointStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * width;
      final y = height - ((data[i].amount / maxValue) * height);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 4, pointStrokePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
