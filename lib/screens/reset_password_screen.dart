import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String userIdentifier;

  const ResetPasswordScreen({
    super.key,
    required this.userIdentifier,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool isNewPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool showPasswordRules = false;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;

  final TextEditingController newPasswordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.lock_reset,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Create New Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Create a strong password to secure your account.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: newPasswordController,
                obscureText: isNewPasswordHidden,
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
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isNewPasswordHidden = !isNewPasswordHidden;
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
                        color: hasSpecialCharacter
                            ? Colors.green
                            : Colors.red,
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
                  prefixIcon: const Icon(Icons.lock),
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
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    if (newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Please fill in all password fields."),
                        ),
                      );
                    } else if (!(hasMinLength &&
                        hasUppercase &&
                        hasLowercase &&
                        hasNumber &&
                        hasSpecialCharacter)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please create a strong password.",
                          ),
                        ),
                      );
                    } else if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Passwords do not match."),
                        ),
                      );
                    } else {
                      final userIndex = UserService.users.indexWhere(
                            (user) =>
                        user["email"] == widget.userIdentifier ||
                            user["mobile"] == widget.userIdentifier,
                      );

                      if (userIndex == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User account not found."),
                          ),
                        );
                        return;
                      }

                      UserService.users[userIndex]["password"] =
                          newPasswordController.text;

                      await UserService.saveUsers();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password reset successfully."),
                        ),
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}