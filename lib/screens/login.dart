import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register.dart';
import 'reset.dart';
import 'homepage.dart';
import 'package:mob_edu/widgets/text_field.dart';
import 'package:mob_edu/services/google_sign_in.dart';
import 'chatbot.dart';

class Loginscene extends StatefulWidget {
  const Loginscene({super.key});
  @override
  State<Loginscene> createState() => Loginscenestate();
}

class Loginscenestate extends State<Loginscene> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    final user = await GoogleSignInService.signInWithGoogle();
    setState(() => _loading = false);

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Welcome, ${user.displayName}!")));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(email: _emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google sign-in failed")));
    }
  }

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
              "Hello, Welcome back to your Mind",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(105, 123, 122, 1),
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: "Email",
              hintText: "Enter your email",
              controller: _emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Password",
              hintText: "Enter your password",
              controller: _PasswordController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
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

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);

                    if (data['success'] == true) {
                      print('✅ Login successful!');
                      print('Welcome, ${data['user']['name']}');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainPage(email: _emailController.text),
                        ),
                      );
                    } else {
                      print('❌ Login failed: ${data['message']}');
                    }
                  } else {
                    print('❌ Server error: ${response.statusCode}');
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shadowColor: Colors.grey.shade300,
                ),
                onPressed: _loading ? null : _handleGoogleSignIn,
                icon: Image.asset('assets/google_logo.png', height: 24),
                label: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.black, fontSize: 16),
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
