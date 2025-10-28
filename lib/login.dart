import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'register.dart';
import 'reset.dart';
import 'homepage.dart';

class Loginscene extends StatefulWidget {
  const Loginscene({super.key});
  @override
  State<Loginscene> createState() => Loginscenestate();
}

class Loginscenestate extends State<Loginscene> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(246, 251, 250, 1)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hello, Welcome back to My Courses",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(105, 123, 122, 1),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(
                  Icons.email,
                  color: Color.fromRGBO(206, 212, 211, 1),
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(242, 201, 76, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _PasswordController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color.fromRGBO(206, 212, 211, 1),
                ),
                suffixIcon: Icon(
                  Icons.keyboard_hide,
                  color: Color.fromRGBO(206, 212, 211, 1),
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(242, 201, 76, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Reset()),
                  );
                },
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: Color.fromRGBO(105, 123, 122, 1),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(242, 201, 76, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/login'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'email': _emailController.text.trim(),
                      'password': _PasswordController.text.trim(),
                    }),
                  );

                  final result = jsonDecode(response.body);

                  if (result['success'] == true) {
                    print('✅ Login successful!');
                    print('Welcome, ${result['user']['name']}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  } else {
                    print('❌ Login failed: ${result['message']}');
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color.fromRGBO(105, 123, 122, 1),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: Color.fromRGBO(242, 201, 76, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
