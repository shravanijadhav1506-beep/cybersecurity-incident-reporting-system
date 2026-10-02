import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'reset_password_screen.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController emailController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.lock_reset,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              "Reset Your Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Enter your registered Email or Mobile Number.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email or Mobile Number",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  String input = emailController.text.trim();

                  bool isEmail = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(input);

                  bool isMobile = RegExp(
                    r'^[0-9]{10}$',
                  ).hasMatch(input);

                  if (input.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter your Email or Mobile Number.",
                        ),
                      ),
                    );
                    return;
                  }

                  if (!isEmail && !isMobile) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter a valid Email or 10-digit Mobile Number.",
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    final response = await http.post(
                      Uri.parse(
                        "${ApiService.baseUrl}/forgot-password",
                      ),
                      headers: {
                        "Content-Type": "application/json",
                      },
                      body: jsonEncode({
                        "identifier": input,
                      }),
                    );

                    final responseData =
                    jsonDecode(response.body);

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            responseData["message"] ??
                                "Account found. You can reset your password.",
                          ),
                        ),
                      );

                      Future.delayed(
                        const Duration(seconds: 1),
                            () {
                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResetPasswordScreen(
                                    userIdentifier: input,
                                  ),
                            ),
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            responseData["message"] ??
                                "No registered account found.",
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Unable to connect to the server. Please try again.",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Send Reset Link"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}