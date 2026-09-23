import 'package:flutter/material.dart';
import '../models/incident_model.dart';

class ReportDetailsScreen extends StatefulWidget {
  final IncidentModel report;
  final bool isAdmin;

  const ReportDetailsScreen({
    super.key,
    required this.report,
    this.isAdmin = false,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.report.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Incident ID"),
                subtitle: Text(widget.report.incidentId),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Full Name"),
                subtitle: Text(widget.report.fullName),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(widget.report.email),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Mobile Number"),
                subtitle: Text(widget.report.mobile),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.warning),
                title: const Text("Incident Type"),
                subtitle: Text(widget.report.incidentType),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(
                  Icons.priority_high,
                  color: widget.report.severity == "Low"
                      ? Colors.green
                      : widget.report.severity == "Medium"
                      ? Colors.amber
                      : widget.report.severity == "High"
                      ? Colors.orange
                      : Colors.red,
                ),
                title: const Text("Severity"),
                subtitle: Text(
                  widget.report.severity,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.report.severity == "Low"
                        ? Colors.green.shade800
                        : widget.report.severity == "Medium"
                        ? Colors.amber.shade800
                        : widget.report.severity == "High"
                        ? Colors.orange.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Date"),
                subtitle: Text(widget.report.date),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Time"),
                subtitle: Text(widget.report.time),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.description),
                title: const Text("Description"),
                subtitle: Text(widget.report.description),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(
                  Icons.circle,
                  color: currentStatus == "Pending"
                      ? Colors.orange
                      : currentStatus == "Investigating"
                      ? Colors.blue
                      : Colors.green,
                ),
                title: const Text("Status"),
                subtitle: Text(
                  currentStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: currentStatus == "Pending"
                        ? Colors.orange.shade800
                        : currentStatus == "Investigating"
                        ? Colors.blue.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
            ),

            if (widget.isAdmin) ...[
              const SizedBox(height: 20),

              const Text(
                "Update Report Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Pending",
                    child: Text("Pending"),
                  ),
                  DropdownMenuItem(
                    value: "Investigating",
                    child: Text("Investigating"),
                  ),
                  DropdownMenuItem(
                    value: "Resolved",
                    child: Text("Resolved"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentStatus = value;
                      widget.report.status = value;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}