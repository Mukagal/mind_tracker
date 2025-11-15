import 'package:flutter/material.dart';

class AppState {
  static final ValueNotifier<DateTime> selectedDate = ValueNotifier(
    DateTime.now(),
  );
}
