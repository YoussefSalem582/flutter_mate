import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/skill_assessment.dart';

class SkillRadarChart extends StatelessWidget {
  final SkillAssessment assessment;

  const SkillRadarChart({
    super.key,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Skills Distribution',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: RadarChartPainter(
                  categories: assessment.skills.keys.toList(),
                  values: assessment.skills.keys
                      .map((cat) => assessment.getCategoryPercentage(cat))
                      .toList(),
                ),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final categories = assessment.skills.keys.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: categories.map((category) {
        final index = categories.indexOf(category);
        final color = _getColorForIndex(index);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: AppTextStyles.caption,
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}

class RadarChartPainter extends CustomPainter {
  final List<String> categories;
  final List<double> values;

  RadarChartPainter({
    required this.categories,
    required this.values,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final angleStep = (2 * math.pi) / categories.length;

    // Draw background circles
    _drawBackgroundCircles(canvas, center, radius);

    // Draw axis lines
    _drawAxisLines(canvas, center, radius, angleStep);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius, angleStep);

    // Draw category labels
    _drawLabels(canvas, center, radius, angleStep);
  }

  void _drawBackgroundCircles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), paint);
    }
  }

  void _drawAxisLines(
      Canvas canvas, Offset center, double radius, double angleStep) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (var i = 0; i < categories.length; i++) {
      final angle = angleStep * i - math.pi / 2;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawDataPolygon(
      Canvas canvas, Offset center, double radius, double angleStep) {
    final path = Path();
    final paint = Paint()
      ..color = AppColors.info.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < values.length; i++) {
      final angle = angleStep * i - math.pi / 2;
      final value = values[i] / 100; // Normalize to 0-1
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.info,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawLabels(
      Canvas canvas, Offset center, double radius, double angleStep) {
    for (var i = 0; i < categories.length; i++) {
      final angle = angleStep * i - math.pi / 2;
      final labelRadius = radius + 30;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: categories[i],
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
