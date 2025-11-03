import 'package:flutter/material.dart';
import 'package:mob_edu/main.dart';
import 'chatbot.dart';
import 'package:mob_edu/services/user_service.dart';

class MainPage extends StatefulWidget {
  final String email;
  MainPage({super.key, required this.email});

  @override
  State<MainPage> createState() => _MainPageState();
}

final now = DateTime.now();
final dateText = "${_monthName(now.month)} ${now.day}";
String _monthName(int m) {
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
  return months[m - 1];
}

class _MainPageState extends State<MainPage> {
  bool isDarkMode = false;
  String? name;
  String? surname;
  int? id;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    var localData = await UserService.loadUserData();
    if (localData != null) {
      setState(() {
        name = localData['name'];
        surname = localData['surname'];
        id = localData['id'];
      });
      print('Loaded user from file ✅');
      return;
    }

    var data = await UserService.fetchUserData(widget.email);
    if (data != null) {
      await UserService.saveUserData(data);
      setState(() {
        name = data['name'];
        surname = data['surname'];
        id = data['id'];
      });
      print('Fetched user from backend and saved locally ✅');
    }
  }

  Future<void> _logout() async {
    await UserService.clearUserData();
    setState(() {
      name = null;
      surname = null;
      id = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : const Color.fromRGBO(246, 239, 234, 1);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, size: 20),
                      Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                dateText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Calm down,\nlife is not competitive",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 50,
                backgroundColor: isDarkMode
                    ? Colors.grey[800]
                    : Colors.white.withOpacity(0.7),
                child: Image.asset("assets/smile.png"),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _menuButton("MENTAL HEALTH", textColor),
                  _menuButton("STRESS MONITOR", textColor),
                ],
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "MY DAY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.show_chart, color: Colors.grey),
                ),
              ),
              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2A2A2A)
                      : const Color.fromRGBO(240, 230, 225, 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.home, size: 28),
                    Icon(Icons.bar_chart, size: 28),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF003333),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatPage(userId: id, userName: name),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat),
                    ),
                    Icon(Icons.more_horiz, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String text, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
