import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:mob_edu/widgets/text_field.dart';
import 'verification_otp.dart';
import 'dart:convert';
import 'package:mob_edu/config.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});
  State<Reset> createState() => _resetscene();
}

class _resetscene extends State<Reset> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(246, 251, 250, 1)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.arrow_left, color: Colors.green),
                ),
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(2, 8, 7, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: "email",
              hintText: "Enter your email",
              controller: _emailController,
              icon: Icons.email,
            ),
            const SizedBox(height: 24),
            SizedBox(
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
                    final url = Uri.parse('$baseUrl/send-reset-otp');
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'email': email}),
                    );

                    print('Reset OTP Status Code: ${response.statusCode}');
                    print('Reset OTP Response Body: ${response.body}');

                    if (response.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpVerificationPage(
                            Name: "",
                            Surname: "",
                            email: email,
                            isReset: true,
                          ),
                        ),
                      );
                    } else {
                      final errorData = jsonDecode(response.body);
                      final errorMessage =
                          errorData['error'] ?? 'Failed to send OTP';

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorMessage)));
                    }
                  } catch (e) {
                    print('Reset OTP Error: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text(
                  "Send Me a New Password",
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
