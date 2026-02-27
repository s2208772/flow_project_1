class Task {
  final String id;
  final String name;
  final String notes;
  final String projectId;
  final bool isComplete;

  Task({
    required this.id,
    required this.name,
    required this.notes,
    required this.projectId,
    required this.isComplete,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      notes: json['notes'] ?? '',
      projectId: json['projectId'] ?? '',
      isComplete: json['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'projectId': projectId,
      'isComplete': isComplete,
    };
  }
}
