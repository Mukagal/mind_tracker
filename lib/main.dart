import 'package:flutter/material.dart';
import 'login_reset.dart';
void main() {
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
      appBar: AppBar(
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1)
        ),
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
                              color: Color.fromRGBO(255, 255, 255, 1)
                          )
                      ),
                    ),
                    Container(
                      width: 310,
                      height: 311,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)
                          )
                      ),
                    ),
                    Container(
                      width: 241,
                      height: 240,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)
                          )
                      ),
                    ),
                    Container(
                      width:102,
                      height: 102,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)
                          )
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
            )
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1)
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(
                width: 327,
                height: 261,
                "assets/OnlineEducation.png"
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome To MyCourses",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: Color.fromRGBO(9, 39, 36, 1),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(width: 150),
              Text(
                "Enjoy the various best courses we have, choose the category according to your wishes.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(105, 123, 122, 1),
                  fontSize: 20,
                  fontStyle: FontStyle.normal,
                  fontFamily: "Poppins"
                ),
              ),
              const SizedBox(width: 150),
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
                    )
                  ),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUp(),
                        ),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Loginscene(),
                      ),
                    );
                  },
                  child: Text(
                    "Already have an account",
                    style: TextStyle(
                      color: Color.fromRGBO(242, 201, 76, 1),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget{
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const Color gray = Color.fromRGBO(206, 212, 211, 1);
    const Color yellow = Color.fromRGBO(242, 201, 76, 1);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1),
        ),
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
                        )
                    );
                  },
                  icon: const Icon(Icons.arrow_left, color: Color.fromRGBO(2, 8, 7, 1), size: 20),
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
              "Email",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email ',
                prefixIcon: Icon(Icons.email, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(206, 212, 211, 1)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Phone Number",
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
                hintText: 'Phone Number',
                prefixIcon: Icon(Icons.phone, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "New Password",
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
                hintText: 'New Password',
                prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(206, 212, 211, 1)),
                suffixIcon: Icon(Icons.keyboard_hide, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.keyboard_hide, color: Color.fromRGBO(206, 212, 211, 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
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
                    )
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                  );
                },
                child: Text(
                  "Create Account",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                  ),
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
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Loginscene()
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
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}