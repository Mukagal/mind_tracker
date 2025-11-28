import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:mob_edu/new_designs/chatbot.dart';
import 'profile_page.dart';
import 'stats_page.dart';
import 'add_page.dart';
import 'package:mob_edu/services/user_service.dart';

class initpage extends StatefulWidget {
  final String email;

  const initpage({Key? key, required this.email}) : super(key: key);

  @override
  State<initpage> createState() => _initpageState();
}

class _initpageState extends State<initpage> {
  int _currentIndex = 0;
  bool isLoading = true;
  String? name;
  String? surname;
  int? id;
  String? errorMessage;
  late List<Widget> _pages;
  bool? ispremium;

  @override
  @override
  void initState() {
    super.initState();
    _pages = List.generate(
      5,
      (index) => const Center(child: CircularProgressIndicator()),
    );
    initApp();
  }

  Future<void> initApp() async {
    await _initializeUser();
  }

  Future<void> _initializeUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var localData = await UserService.loadUserData();

      if (localData != null && localData['email'] == widget.email) {
        name = localData['name'];
        surname = localData['surname'];
        id = localData['id'];
        ispremium = localData['is_premium'] == 1;
        print("🔥 Premium Loaded: $ispremium");

        _pages = [
          MainPage(id: id),
          StatsPage(userid: id),
          BackgroundMusicPage(),
          ChatPage(userId: id, userName: name),
          ProfilePage(
            id: id,
            name: name,
            surname: surname,
            email: widget.email,
            ispremium: ispremium,
          ),
        ];

        setState(() {
          isLoading = false;
        });

        print('✅ Loaded user from local file: $name $surname');
        return;
      }

      print('🔄 Fetching user from backend for email: ${widget.email}');
      var data = await UserService.fetchUserData(widget.email);

      if (data != null) {
        await UserService.saveUserData(data);

        name = data['name'];
        surname = data['surname'];
        id = data['id'];
        ispremium = data['is_premium'] == 1;

        _pages = [
          MainPage(id: id),
          StatsPage(userid: id),
          BackgroundMusicPage(),
          ChatPage(userId: id, userName: name),
          ProfilePage(
            id: id,
            name: name,
            surname: surname,
            email: widget.email,
            ispremium: ispremium,
          ),
        ];

        setState(() {
          isLoading = false;
        });

        print('✅ Fetched and saved user: $name $surname (ID: $id)');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'User not found for email: ${widget.email}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading user: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text(errorMessage!)));
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromRGBO(149, 202, 149, 1),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[700],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Music"),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
