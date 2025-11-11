import 'package:flutter/material.dart';
import 'package:mob_edu/models/day.dart';
import 'package:mob_edu/services/day_stats.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedPeriod = 'Week';
  List<DayEntry> entries = [];
  bool isLoading = true;
  String dateRangeText = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);

    try {
      final dates = _getDateRange();
      final loadedEntries = await ApiService.getEntries(
        dates['start']!,
        dates['end']!,
      );

      setState(() {
        entries = loadedEntries;
        dateRangeText = _formatDateRange(dates['start']!, dates['end']!);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stats: $e')));
      }
    }
  }

  Map<String, DateTime> _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedPeriod) {
      case 'Week':
        return {
          'start': today.subtract(Duration(days: today.weekday - 1)),
          'end': today,
        };
      case '2 Week':
        return {
          'start': today.subtract(const Duration(days: 14)),
          'end': today,
        };
      case 'Month':
        return {'start': DateTime(now.year, now.month, 1), 'end': today};
      case 'All time':
        return {'start': DateTime(2020, 1, 1), 'end': today};
      default:
        return {
          'start': today.subtract(Duration(days: today.weekday - 1)),
          'end': today,
        };
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (start.month == end.month) {
      return '${start.day} - ${end.day} ${months[end.month - 1]}';
    } else {
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]}';
    }
  }

  Map<String, dynamic> _calculateMoodStats(String moodType) {
    int? getModValue(DayEntry entry) {
      switch (moodType) {
        case 'morning':
          return entry.morningMood;
        case 'day':
          return entry.dayMood;
        case 'evening':
          return entry.eveningMood;
        case 'night':
          return entry.nightMood;
        default:
          return null;
      }
    }

    final validMoods = entries
        .map((e) => getModValue(e))
        .where((m) => m != null)
        .cast<int>()
        .toList();

    if (validMoods.isEmpty) {
      return {
        'count': 0,
        'total': entries.length,
        'percentage': 0,
        'average': 0.0,
        'status': 'No data',
      };
    }

    final sum = validMoods.fold(0, (a, b) => a + b);
    final average = sum / validMoods.length;

    String status;
    if (average >= 8) {
      status = 'Excellent';
    } else if (average >= 6) {
      status = 'Good';
    } else if (average >= 4) {
      status = 'Normal';
    } else {
      status = 'Low';
    }

    return {
      'count': validMoods.length,
      'total': entries.length,
      'percentage': entries.isNotEmpty
          ? (validMoods.length / entries.length * 100).round()
          : 0,
      'average': average,
      'status': status,
    };
  }

  List<ChartDataPoint> _getChartData() {
    if (entries.isEmpty) return [];

    final sortedEntries = List<DayEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final dayEntry = entry.value;

      return ChartDataPoint(
        index: index,
        morningMood: dayEntry.morningMood?.toDouble(),
        dayMood: dayEntry.dayMood?.toDouble(),
        eveningMood: dayEntry.eveningMood?.toDouble(),
        nightMood: dayEntry.nightMood?.toDouble(),
        date: dayEntry.date,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final morningStats = _calculateMoodStats('morning');
    final dayStats = _calculateMoodStats('day');
    final eveningStats = _calculateMoodStats('evening');
    final nightStats = _calculateMoodStats('night');
    final chartData = _getChartData();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeriodTab(
                          title: 'Week',
                          isSelected: selectedPeriod == 'Week',
                          onTap: () {
                            setState(() => selectedPeriod = 'Week');
                            _loadStats();
                          },
                        ),
                        PeriodTab(
                          title: '2 Week',
                          isSelected: selectedPeriod == '2 Week',
                          onTap: () {
                            setState(() => selectedPeriod = '2 Week');
                            _loadStats();
                          },
                        ),
                        PeriodTab(
                          title: 'Month',
                          isSelected: selectedPeriod == 'Month',
                          onTap: () {
                            setState(() => selectedPeriod = 'Month');
                            _loadStats();
                          },
                        ),
                        PeriodTab(
                          title: 'All time',
                          isSelected: selectedPeriod == 'All time',
                          onTap: () {
                            setState(() => selectedPeriod = 'All time');
                            _loadStats();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateRangeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: chartData.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No mood data available for this period',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : CustomPaint(
                                        size: Size.infinite,
                                        painter: ChartPainter(chartData),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: 'Morning',
                                      subtitle: morningStats['status'],
                                      value:
                                          '${morningStats['count']}/${morningStats['total']}',
                                      percentage:
                                          '(${morningStats['percentage']}%)',
                                      color: Colors.pink,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StatCard(
                                      title: 'Day',
                                      subtitle: dayStats['status'],
                                      value:
                                          '${dayStats['count']}/${dayStats['total']}',
                                      percentage:
                                          '(${dayStats['percentage']}%)',
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: 'Evening',
                                      subtitle: eveningStats['status'],
                                      value:
                                          '${eveningStats['count']}/${eveningStats['total']}',
                                      percentage:
                                          '(${eveningStats['percentage']}%)',
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StatCard(
                                      title: 'Night',
                                      subtitle: nightStats['status'],
                                      value:
                                          '${nightStats['count']}/${nightStats['total']}',
                                      percentage:
                                          '(${nightStats['percentage']}%)',
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartDataPoint {
  final int index;
  final double? morningMood;
  final double? dayMood;
  final double? eveningMood;
  final double? nightMood;
  final DateTime date;

  ChartDataPoint({
    required this.index,
    this.morningMood,
    this.dayMood,
    this.eveningMood,
    this.nightMood,
    required this.date,
  });
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5FA89D) : Colors.transparent,
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
      padding: const EdgeInsets.all(12),
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
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()..style = PaintingStyle.fill;

    final double horizontalSpacing =
        size.width / (data.length > 1 ? data.length - 1 : 1);
    const double minMood = 1.0;
    const double maxMood = 10.0;

    double moodToY(double mood) {
      return size.height -
          ((mood - minMood) / (maxMood - minMood) * size.height);
    }

    double getX(int index) {
      return index * horizontalSpacing;
    }

    final moodTypes = [
      {'getter': (ChartDataPoint d) => d.morningMood, 'color': Colors.pink},
      {'getter': (ChartDataPoint d) => d.dayMood, 'color': Colors.orange},
      {'getter': (ChartDataPoint d) => d.eveningMood, 'color': Colors.blue},
      {'getter': (ChartDataPoint d) => d.nightMood, 'color': Colors.purple},
    ];

    for (var moodType in moodTypes) {
      final getter = moodType['getter'] as double? Function(ChartDataPoint);
      final color = moodType['color'] as Color;

      paint.color = color;
      pointPaint.color = color;

      final path = Path();
      bool pathStarted = false;

      for (int i = 0; i < data.length; i++) {
        final moodValue = getter(data[i]);

        if (moodValue != null) {
          final x = getX(i);
          final y = moodToY(moodValue);

          if (!pathStarted) {
            path.moveTo(x, y);
            pathStarted = true;
          } else {
            path.lineTo(x, y);
          }

          canvas.drawCircle(Offset(x, y), 4, pointPaint);
        }
      }

      if (pathStarted) {
        canvas.drawPath(path, paint);
      }
    }

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
