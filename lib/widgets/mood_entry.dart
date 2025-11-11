import 'package:flutter/material.dart';

class MoodEntryDialog extends StatefulWidget {
  final String timeOfDay;
  final int? initialValue;

  const MoodEntryDialog({Key? key, required this.timeOfDay, this.initialValue})
    : super(key: key);

  @override
  State<MoodEntryDialog> createState() => _MoodEntryDialogState();
}

class _MoodEntryDialogState extends State<MoodEntryDialog> {
  late int moodValue;

  @override
  void initState() {
    super.initState();
    moodValue = widget.initialValue ?? 5;
  }

  Color get timeColor {
    switch (widget.timeOfDay.toLowerCase()) {
      case 'morning':
        return Colors.pink;
      case 'day':
        return Colors.orange;
      case 'evening':
        return Colors.blue;
      case 'night':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get timeLabel {
    return widget.timeOfDay[0].toUpperCase() + widget.timeOfDay.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(73, 173, 213, 0.3),
              Color.fromRGBO(152, 203, 147, 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: timeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'How was your $timeLabel?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Rate from 1 (worst) to 10 (best)',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$moodValue',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: timeColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: timeColor,
                inactiveTrackColor: timeColor.withOpacity(0.3),
                thumbColor: timeColor,
                overlayColor: timeColor.withOpacity(0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: moodValue.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (val) => setState(() => moodValue = val.round()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '😢 Worst',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Best 😊',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, moodValue),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: timeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
