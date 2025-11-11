import 'package:flutter/material.dart';
import 'package:mob_edu/new_designs/login.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mob_edu/widgets/text_field.dart';
import 'package:mob_edu/widgets/gradient_background.dart';
import 'verification_otp.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _SurnameController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _NameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _NameFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _NameController.dispose();
    _emailFocus.dispose();
    _NameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -200,
        bottom: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_left,
                    color: Color.fromRGBO(2, 8, 7, 1),
                    size: 20,
                  ),
                ),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(2, 8, 7, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Enjoy the various best courses we have, choose the category according to your wishes.",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(105, 123, 122, 1),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: "Name",
              hintText: "Your name",
              controller: _NameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Surname",
              hintText: "Your Surname",
              controller: _SurnameController,
              icon: Icons.person,
            ),

            const SizedBox(height: 20),
            CustomTextField(
              label: "Email",
              hintText: "Enter your email",
              controller: _emailController,
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6BB8AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email'),
                      ),
                    );
                    return;
                  }

                  try {
                    final url = Uri.parse(
                      'https://mind-tracker.onrender.com/send-otp',
                    );
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({'email': email}),
                    );

                    print('Status Code: ${response.statusCode}');
                    print('Response Body: ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpVerificationPage(
                            email: email,
                            Name: _NameController.text,
                            Surname: _SurnameController.text,
                            isReset: false,
                          ),
                        ),
                      );
                    } else {
                      final errorData = json.decode(response.body);
                      final errorMessage =
                          errorData['error'] ?? 'Failed to send OTP';

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMessage)));
                    }
                  } catch (e) {
                    print('Error: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: Text(
                  "Create Account",
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account",
                  style: TextStyle(
                    color: Color.fromRGBO(105, 123, 122, 1),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
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
