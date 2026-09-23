class IncidentModel {
  final String incidentId;
  final String fullName;
  final String email;
  final String mobile;
  final String incidentType;
  final String severity;
  String status;
  final String date;
  final String time;
  final String description;

  IncidentModel({
    required this.incidentId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.incidentType,
    required this.severity,
    required this.status,
    required this.date,
    required this.time,
    required this.description,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      incidentId: json["incident_id"],
      fullName: json["full_name"],
      email: json["email"],
      mobile: json["mobile"],
      incidentType: json["incident_type"],
      severity: json["severity"],
      status: json["status"],
      date: json["date"],
      time: json["time"],
      description: json["description"],
    );
  }
}


