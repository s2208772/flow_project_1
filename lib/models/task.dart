class Task {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime finishDate;
  final String notes;
  final String taskOwner;
  final String projectId;
  final DateTime? actualStartDate;
  final DateTime? actualFinishDate;

  Task({
    required this.id,
    required this.name,
    required this.startDate,
    required this.finishDate,
    required this.notes,
    required this.taskOwner,
    required this.projectId,
    this.actualStartDate,
    this.actualFinishDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      finishDate: json['finishDate'] != null ? DateTime.parse(json['finishDate']) : DateTime.now(),
      notes: json['notes'] ?? '',
      taskOwner: json['taskOwner'] ?? '',
      projectId: json['projectId'] ?? '',
      actualStartDate: json['actualStartDate'] != null ? DateTime.parse(json['actualStartDate']) : null,
      actualFinishDate: json['actualFinishDate'] != null ? DateTime.parse(json['actualFinishDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'finishDate': finishDate.toIso8601String(),
      'notes': notes,
      'taskOwner': taskOwner,
      'projectId': projectId,
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualFinishDate': actualFinishDate?.toIso8601String(),
    };
  }
}
