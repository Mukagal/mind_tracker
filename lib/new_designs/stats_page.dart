import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(73, 173, 213, 1),
              Color.fromRGBO(152, 203, 147, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeriodTab(
                          title: 'Week',
                          isSelected: selectedPeriod == 'Week',
                          onTap: () => setState(() => selectedPeriod = 'Week'),
                        ),
                        PeriodTab(
                          title: '2 Week',
                          isSelected: selectedPeriod == '2 Week',
                          onTap: () =>
                              setState(() => selectedPeriod = '2 Week'),
                        ),
                        PeriodTab(
                          title: 'Month',
                          isSelected: selectedPeriod == 'Month',
                          onTap: () => setState(() => selectedPeriod = 'Month'),
                        ),
                        PeriodTab(
                          title: 'All time',
                          isSelected: selectedPeriod == 'All time',
                          onTap: () =>
                              setState(() => selectedPeriod = 'All time'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1 Nov - 7 Nov',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: ChartPainter(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Morning',
                                subtitle: 'Normal',
                                value: '3/7',
                                percentage: '(43%)',
                                color: Colors.pink,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Day',
                                subtitle: 'Normal',
                                value: '7/7',
                                percentage: '(100%)',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Evening',
                                subtitle: 'Good',
                                value: '4/7',
                                percentage: '(57%)',
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Night',
                                subtitle: 'Normal',
                                value: '7/7',
                                percentage: '(100%)',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PeriodTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PeriodTab({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF5FA89D) : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String percentage;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.percentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.black54)),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw red line
    paint.color = Colors.red;
    final redPath = Path();
    redPath.moveTo(0, size.height * 0.6);
    redPath.lineTo(size.width * 0.2, size.height * 0.4);
    redPath.lineTo(size.width * 0.4, size.height * 0.7);
    redPath.lineTo(size.width * 0.6, size.height * 0.5);
    redPath.lineTo(size.width * 0.8, size.height * 0.6);
    redPath.lineTo(size.width, size.height * 0.5);
    canvas.drawPath(redPath, paint);

    // Draw blue line
    paint.color = Colors.blue;
    final bluePath = Path();
    bluePath.moveTo(0, size.height * 0.3);
    bluePath.lineTo(size.width * 0.2, size.height * 0.5);
    bluePath.lineTo(size.width * 0.4, size.height * 0.2);
    bluePath.lineTo(size.width * 0.6, size.height * 0.6);
    bluePath.lineTo(size.width * 0.8, size.height * 0.3);
    bluePath.lineTo(size.width, size.height * 0.4);
    canvas.drawPath(bluePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
