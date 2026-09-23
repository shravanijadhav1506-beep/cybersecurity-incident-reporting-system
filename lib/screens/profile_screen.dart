import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = UserSession.currentUser;
    final user = UserService.users.firstWhere(
          (user) => user["email"] == userEmail,
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                UserSession.currentUserName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(userEmail),
                ),
              ),
              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Mobile Number"),
                  subtitle: Text(user["mobile"] ?? ""),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    UserSession.currentUser = "";
                    UserSession.currentUserName = "";

                    Navigator.popUntil(
                      context,
                          (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}