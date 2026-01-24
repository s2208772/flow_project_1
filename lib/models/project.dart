class Project {
  final String name;
  final String owner;
  final String? type;
  final DateTime? targetDate;
  final String status;

  Project({
    required this.name,
    required this.owner,
    this.type,
    this.targetDate,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] as String,
        owner: json['owner'] as String,
        type: json['type'] as String?,
        targetDate:
            json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'owner': owner,
        'type': type,
        'targetDate': targetDate?.toIso8601String(),
        'status': status,
      };

  Project copyWith({String? status}) => Project(
        name: name,
        owner: owner,
        type: type,
        targetDate: targetDate,
        status: status ?? this.status,
      );
}
