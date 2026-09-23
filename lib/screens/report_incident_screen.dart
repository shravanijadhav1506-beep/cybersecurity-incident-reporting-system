import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident_model.dart';
import '../services/report_service.dart';
import '../services/user_session.dart';
import '../services/api_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}
class _ReportIncidentScreenState extends State<ReportIncidentScreen> {

final TextEditingController fullNameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController mobileController = TextEditingController();
final TextEditingController incidentTypeController = TextEditingController();
final TextEditingController dateController = TextEditingController();
final TextEditingController timeController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();

@override
void initState() {
  super.initState();
  emailController.text = UserSession.currentUser;
}

String? selectedIncidentType;
String incidentTypeInfo = "";

DateTime? selectedIncidentDate;

final List<String> incidentTypes = [
  "Phishing Email",
  "Malware",
  "Fake Website",
  "Social Media Scam",
  "Ransomware",
  "Unauthorized Access",
  "Data Breach",
  "Other",
];
final Map<String, String> incidentTypeDescriptions = {
  "Phishing Email":
  "Fake emails asking for passwords, OTPs or bank details.",
  "Malware":
  "Harmful software such as viruses, trojans or spyware.",
  "Fake Website":
  "A fake website pretending to be a trusted website.",
  "Social Media Scam":
  "Scams or fraud through social media platforms.",
  "Ransomware":
  "Malware that locks files and demands payment.",
  "Unauthorized Access":
  "Someone accesses an account or system without permission.",
  "Data Breach":
  "Private or sensitive information is exposed or stolen.",
  "Other":
  "Any cybersecurity incident not listed above.",
};

String? selectedSeverity;
String severityInfo = "";

final List<String> severityLevels = [
  "Low",
  "Medium",
  "High",
  "Critical",
];
final Map<String, String> severityDescriptions = {
  "Low": "Minor issue with little or no damage.",
  "Medium": "Moderate impact or limited information exposure.",
  "High": "Serious impact or important account/data affected.",
  "Critical": "Major attack, ransomware, or significant data breach.",
};

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Incident"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(

          children: [

            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedIncidentType,
              decoration: const InputDecoration(
                labelText: "Incident Type",
                border: OutlineInputBorder(),
              ),
              items: incidentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIncidentType = value;
                  incidentTypeController.text = value!;
                  incidentTypeInfo = incidentTypeDescriptions[value] ?? "";
                });
              },
            ),

            SizedBox(height: 20),

            if (incidentTypeInfo.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incidentTypeInfo,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Date of Incident",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  selectedIncidentDate = pickedDate;

                  dateController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedSeverity,
              decoration: const InputDecoration(
                labelText: "Severity Level",
                border: OutlineInputBorder(),
              ),
              items: severityLevels.map((level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSeverity = value;
                  severityInfo = severityDescriptions[value] ?? "";
                });
              },
            ),

            SizedBox(height: 20),

            if (severityInfo.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        severityInfo,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Time of Incident",
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                if (selectedIncidentDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select the incident date first."),
                    ),
                  );
                  return;
                }

                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  final now = DateTime.now();

                  if (selectedIncidentDate!.year == now.year &&
                      selectedIncidentDate!.month == now.month &&
                      selectedIncidentDate!.day == now.day) {

                    final selectedDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    if (selectedDateTime.isAfter(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "For today's incident, future time cannot be selected.",
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  timeController.text = pickedTime.format(context);
                }
              },
            ),

            SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: "Incident Description",
                hintText: "Briefly describe what happened.",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (fullNameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      mobileController.text.isEmpty ||
                      selectedIncidentType == null ||
                      selectedSeverity == null ||
                      dateController.text.isEmpty ||
                      timeController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all the fields."),
                      ),
                    );
                    return;
                  }
                  String fullName = fullNameController.text.trim();

                  bool validFullName = RegExp(
                    r'^[A-Z][a-z]+ [A-Z][a-z]+ [A-Z][a-z]+$',
                  ).hasMatch(fullName);

                  if (!validFullName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Enter First Name, Middle Name and Last Name with first letter capital.",
                        ),
                      ),
                    );
                    return;
                  }

                  String mobile = mobileController.text.trim();

                  bool validMobile = RegExp(
                    r'^[0-9]{10}$',
                  ).hasMatch(mobile);

                  if (!validMobile) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid 10-digit mobile number."),
                      ),
                    );
                    return;
                  }

                  String email = emailController.text.trim();

                  bool validEmail = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(email);

                  if (!validEmail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid email address."),
                      ),
                    );
                    return;
                  }

                  IncidentModel incident = IncidentModel(
                    incidentId: "INC${DateTime.now().millisecondsSinceEpoch}",
                    fullName: fullName,
                    email: UserSession.currentUser,
                    mobile: mobile,
                    incidentType: incidentTypeController.text,
                    severity: selectedSeverity ?? "",
                    date: dateController.text,
                    time: timeController.text,
                    status: "Pending",
                    description: descriptionController.text,
                  );

                  final response = await http.post(
                    Uri.parse("${ApiService.baseUrl}/reports"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "incident_id": incident.incidentId,
                      "full_name": incident.fullName,
                      "email": incident.email,
                      "mobile": incident.mobile,
                      "incident_type": incident.incidentType,
                      "date": incident.date,
                      "time": incident.time,
                      "description": incident.description,
                      "severity": incident.severity,
                    }),
                  );

                  if (response.statusCode != 201) {
                    final responseData = jsonDecode(response.body);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          responseData["message"] ?? "Failed to submit incident report.",
                        ),
                      ),
                    );

                    return;
                  }

                  ReportService.reports.add(incident);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Incident Report Submitted Successfully\nName: ${incident.fullName}",
                      ),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
        ),
    );
  }
}