import 'package:flutter/material.dart';
import 'package:mob_edu/widgets/gradient_background.dart';
import 'package:mob_edu/widgets/text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'for_nav.dart';
import 'package:mob_edu/config.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();
  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -300,
        bottom: 600,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          label: "Email",
                          hintText: "Enter your email",
                          controller: _emailController,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          label: "Password",
                          hintText: "Enter your password",
                          controller: _PasswordController,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final response = await http.post(
                                Uri.parse('$baseUrl/login'),
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
                                      builder: (context) => initpage(
                                        email: _emailController.text,
                                      ),
                                    ),
                                  );
                                } else {
                                  print('❌ Login failed: ${data['message']}');
                                }
                              } else {
                                print('❌ Server error: ${response.statusCode}');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6BB8AC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black38)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.black38)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                              icon: Icons.g_mobiledata,
                              color: Color(0xFFDB4437),
                            ),
                            SizedBox(width: 20),
                            SocialLoginButton(
                              icon: Icons.apple,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SocialLoginButton({Key? key, required this.icon, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 30, color: color),
    );
  }
}
