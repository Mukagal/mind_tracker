import 'package:flutter/material.dart';
import 'package:mob_edu/widgets/gradient_background.dart';
import 'package:mob_edu/models/day.dart';
import 'package:mob_edu/services/day_stats.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DayEntry? todayEntry;
  bool isLoading = true;
  final TextEditingController _diaryController = TextEditingController();
  final List<String> diaryItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayEntry() async {
    setState(() => isLoading = true);
    try {
      final entry = await ApiService.getEntryForDate(DateTime.now());
      setState(() {
        todayEntry = entry;
        if (entry?.diaryNote != null && entry!.diaryNote!.isNotEmpty) {
          diaryItems.clear();
          diaryItems.addAll(
            entry.diaryNote!
                .split('\n')
                .where((item) => item.trim().isNotEmpty),
          );
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading entry: $e');
    }
  }

  Future<void> _showAddItemDialog() async {
    _diaryController.clear();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to My Day'),
        content: TextField(
          controller: _diaryController,
          decoration: const InputDecoration(
            hintText: 'e.g., Meditation at 12 PM',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _diaryController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        diaryItems.add(result);
      });
      await _saveDiaryNote();
    }
  }

  void _removeItem(int index) {
    setState(() {
      diaryItems.removeAt(index);
    });
    _saveDiaryNote();
  }

  Future<void> _saveDiaryNote() async {
    try {
      final noteText = diaryItems.join('\n');
      await ApiService.updateDiaryNote(DateTime.now(), noteText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        top: -100,
        bottom: -100,
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _formattedDate(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Breathe.\nYou\'re doing\nbetter than\nyou think.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Shared daily insights',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final colors = [
                              const Color(0xFF008B8B),
                              const Color(0xFF20B2AA),
                              const Color(0xFF4169E1),
                            ];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: colors[index],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8E6DD).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'MY DAY',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _showAddItemDialog,
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.black87,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (diaryItems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'No items yet. Tap + to add.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ...diaryItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _removeItem(index),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[now.month - 1]} ${now.day}";
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
