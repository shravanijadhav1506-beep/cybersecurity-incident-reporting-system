import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/incident_model.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import 'report_details_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<IncidentModel> userReports = [];

  Future<void> loadUserReports() async {
    final response = await http.get(
      Uri.parse(
        "${ApiService.baseUrl}/reports/user/${UserSession.currentUser}",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        userReports = (data["reports"] as List)
            .map((report) => IncidentModel.fromJson(report))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Reports"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: userReports.isEmpty
            ? const Center(
          child: Text(
            "No incident reports found.\nYour submitted reports will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        )
            : ListView.builder(
          itemCount: userReports.length,
          itemBuilder: (context, index) {
            final report = userReports[index];

            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        report: report,
                      ),
                    ),
                  );
                },
                leading: const Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                title: Text(
                  "${report.incidentId} - ${report.incidentType}",
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${report.fullName}"),
                    Text("Severity: ${report.severity}"),
                    Text("Date: ${report.date}"),
                    const SizedBox(height: 5),
                    Chip(
                      label: Text(report.status),
                      backgroundColor: report.status == "Resolved"
                          ? Colors.green.shade200
                          : report.status == "Investigating"
                          ? Colors.blue.shade200
                          : Colors.orange.shade200,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}