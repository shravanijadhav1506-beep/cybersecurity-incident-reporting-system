import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/incident_model.dart';
import '../services/api_service.dart';
import 'report_details_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<IncidentModel> reports = [];
  bool isLoading = true;

  Future<void> loadAllReports() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/reports"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          reports = (data["reports"] as List)
              .map((report) => IncidentModel.fromJson(report))
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load incident reports."),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to connect to backend."),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Incident Reports"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : reports.isEmpty
            ? const Center(
          child: Text(
            "No incident reports available.",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        report: report,
                        isAdmin: true,
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
                    Text("Email: ${report.email}"),
                    Text("Date: ${report.date}"),
                    Chip(
                      label: Text(
                        "Severity: ${report.severity}",
                      ),
                      backgroundColor: report.severity == "Low"
                          ? Colors.green.shade100
                          : report.severity == "Medium"
                          ? Colors.yellow.shade100
                          : report.severity == "High"
                          ? Colors.orange.shade200
                          : Colors.red.shade200,
                    ),
                    const SizedBox(height: 5),
                    Chip(
                      label: Text(report.status),
                      backgroundColor: report.status == "Pending"
                          ? Colors.orange.shade200
                          : report.status == "Investigating"
                          ? Colors.blue.shade200
                          : Colors.green.shade200,
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