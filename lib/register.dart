import 'package:flutter/material.dart';
import 'package:mob_edu/login.dart';
import 'main.dart';
import 'sender.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'registerdb.dart';

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
      body: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(246, 251, 250, 1)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            Text(
              "Name",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _NameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Name',
                prefixIcon: Icon(
                  Icons.phone,
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
              "Surname",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _SurnameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Surname',
                prefixIcon: Icon(
                  Icons.phone,
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
              decoration: InputDecoration(
                hintText: 'Email ',
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
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(206, 212, 211, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  final email = _emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email'),
                      ),
                    );
                    return;
                  }
                  final url = Uri.parse('http://localhost:3000/send-otp');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({'email': email}),
                  );

                  if (response.statusCode == 200) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerificationPage(
                          email: email,
                          Name: _NameController.text,
                          Surname: _SurnameController.text,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to send OTP')),
                    );
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
                      MaterialPageRoute(
                        builder: (context) => const Loginscene(),
                      ),
                    );
                  },
                  child: Text(
                    "Login",
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

class PassSet extends StatefulWidget {
  final String email;
  final String Name;
  final String Surname;

  const PassSet({
    super.key,
    required this.email,
    required this.Name,
    required this.Surname,
  });
  @override
  State<PassSet> createState() => _PassSetState();
}

class _PassSetState extends State<PassSet> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'New Password',
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
            const SizedBox(height: 20),
            Text(
              "Confirm Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _newpasswordController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: Icon(
                  Icons.lock,
                  color: Color.fromRGBO(206, 212, 211, 1),
                ),
                border: OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.keyboard_hide,
                  color: Color.fromRGBO(206, 212, 211, 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(242, 201, 76, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
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
                  final isRegistered = await RegisterService.registerUser(
                    name: widget.Name,
                    surname: widget.Surname,
                    email: widget.email,
                    password: _passwordController.text,
                    context: context,
                  );

                  if (isRegistered) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                },
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
