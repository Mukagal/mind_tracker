import 'package:flutter/material.dart';
import 'new_designs/login.dart';
import 'new_designs/register.dart';
import 'package:mob_edu/widgets/gradient_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(246, 251, 250, 1)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 423,
                    height: 423,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  Container(
                    width: 310,
                    height: 311,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  Container(
                    width: 241,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                  Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                    child: Text(
                      "ED",
                      style: TextStyle(
                        color: Color.fromRGBO(242, 201, 76, 1),
                        fontSize: 38,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                "Empower ED",
                style: TextStyle(
                  color: Color.fromRGBO(2, 8, 7, 1),
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -100,
        bottom: 500,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(width: 327, height: 261, "assets/logo.png"),
              const SizedBox(height: 20),
              Text(
                "Welcome To Mind Tracker",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: Color.fromRGBO(9, 39, 36, 1),
                ),
              ),
              const SizedBox(width: 150),
              const SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6BB8AC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Already have an account",
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
