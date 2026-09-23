import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../services/user_session.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;
  bool showPasswordRules = false;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cybersecurity Incident Reporting"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.security,
                size: 100,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email or Mobile Number",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: isPasswordHidden,
                onChanged: (value) {
                  setState(() {
                    showPasswordRules = value.isNotEmpty;

                    hasMinLength = value.length >= 8;
                    hasUppercase = value.contains(RegExp(r'[A-Z]'));
                    hasLowercase = value.contains(RegExp(r'[a-z]'));
                    hasNumber = value.contains(RegExp(r'[0-9]'));
                    hasSpecialCharacter =
                        value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
                  });
                },

                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility : Icons
                          .visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              if (showPasswordRules)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "✓ At least 8 characters",
                      style: TextStyle(
                        color: hasMinLength ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "✓ At least 1 uppercase letter",
                      style: TextStyle(
                        color: hasUppercase ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "✓ At least 1 lowercase letter",
                      style: TextStyle(
                        color: hasLowercase ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "✓ At least 1 number",
                      style: TextStyle(
                        color: hasNumber ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "✓ At least 1 special character",
                      style: TextStyle(
                        color: hasSpecialCharacter ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please enter your Email or Mobile Number."),
                        ),
                      );
                    }else if (RegExp(r'^\d+$').hasMatch(emailController.text.trim()) &&
                        emailController.text.trim().length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid 10-digit mobile number."),
                        ),
                      );
                    } else if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter your Password."),
                        ),
                      );
                    } else if (!(
                        hasMinLength && hasUppercase &&
                            hasLowercase &&
                            hasNumber &&
                            hasSpecialCharacter)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password must contain at least 8 characters, an uppercase letter, a lowercase letter, a number, and a special character.",
                          ),
                        ),
                      );
                    } else {
                      final enteredEmail = emailController.text.trim();
                      final enteredPassword = passwordController.text;

                      final response = await http.post(
                        Uri.parse("${ApiService.baseUrl}/login"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "identifier": enteredEmail,
                          "password": enteredPassword,
                        }),
                      );

                      if (response.statusCode != 200) {
                        final responseData = jsonDecode(response.body);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              responseData["message"] ?? "Invalid email or password.",
                            ),
                          ),
                        );

                        return;
                      }

                      final responseData = jsonDecode(response.body);

                      UserSession.currentUser = responseData["email"] ?? enteredEmail;
                      UserSession.currentUserName = responseData["name"] ?? "";
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen(),
                    ),
                  );
                },
                child: const Text("Admin Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}