class Risk {
  final String id;
  final String description;
  final String impact;
  final String response;
  final String severity;
  final String owner;
  final String notes;
  final String projectId;

  Risk({
    required this.id,
    required this.description,
    required this.impact,
    required this.response,
    required this.severity,
    required this.owner,
    required this.notes,
    required this.projectId,
  });

  factory Risk.fromJson(Map<String, dynamic> json) {
    return Risk(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      impact: json['impact'] ?? '',
      response: json['response'] ?? '',
      severity: json['severity'] ?? '',
      owner: json['owner'] ?? '',
      notes: json['notes'] ?? '',
      projectId: json['projectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'impact': impact,
      'response': response,
      'severity': severity,
      'owner': owner,
      'notes': notes,
      'projectId': projectId,
    };
  }
}
