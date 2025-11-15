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
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -400,
        bottom: 400,
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
