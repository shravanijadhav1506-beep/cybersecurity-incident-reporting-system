import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/user_session.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool showPasswordRules = false;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [

              const Icon(
                Icons.person_add,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: mobileController,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone),
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
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
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

              const SizedBox(height: 20),

              TextField(
                controller: confirmPasswordController,
                obscureText: isConfirmPasswordHidden,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordHidden =
                        !isConfirmPasswordHidden;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async  {
                    String email = emailController.text.trim();
                    String mobile = mobileController.text.trim();

                    bool isEmail = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(email);

                    bool isMobile = RegExp(
                      r'^[0-9]{10}$',
                    ).hasMatch(mobile);

                    if (fullNameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        mobileController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields."),
                        ),
                      );
                    } else if (!isEmail) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid Email."),
                        ),
                      );
                    } else if (!isMobile) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid 10-digit Mobile Number."),
                        ),
                      );
                    } else if (!(hasMinLength &&
                        hasUppercase &&
                        hasLowercase &&
                        hasNumber &&
                        hasSpecialCharacter)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please create a strong password."),
                        ),
                      );
                    } else if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Passwords do not match."),
                        ),
                      );
                    } else {

                      final response = await http.post(
                        Uri.parse("${ApiService.baseUrl}/register"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "name": fullNameController.text.trim(),
                          "email": email,
                          "mobile": mobile,
                          "password": passwordController.text,
                        }),
                      );
                      if (response.statusCode == 201) {
                        UserSession.currentUser = email;
                        UserSession.currentUserName = fullNameController.text.trim();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Successful"),
                          ),
                        );
                      } else {
                        final responseData = jsonDecode(response.body);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(responseData["message"] ?? "Registration failed"),
                          ),
                        );

                        return;
                      }
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}