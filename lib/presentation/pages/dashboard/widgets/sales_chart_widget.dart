import 'package:flutter/material.dart';

class SalesChartWidget extends StatelessWidget {
  const SalesChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ventas de la Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green[600],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 172,
              child: _buildSimpleChart(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend('Lun', Colors.blue, 85),
                _buildChartLegend('Mar', Colors.green, 92),
                _buildChartLegend('Mié', Colors.orange, 78),
                _buildChartLegend('Jue', Colors.purple, 95),
                _buildChartLegend('Vie', Colors.red, 88),
                _buildChartLegend('Sáb', Colors.teal, 72),
                _buildChartLegend('Dom', Colors.indigo, 65),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    final List<double> data = [85, 92, 78, 95, 88, 72, 65];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height = (data[index] / 100) * 150; // Normalizar a altura máxima de 150
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${data[index].toInt()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChartLegend(String day, Color color, double value) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
