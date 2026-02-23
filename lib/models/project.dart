class Project {
  final String name;
  final String owner;
  final String? type;
  final DateTime? targetDate;
  final String status;
  final String? userId;
  final List<String> members;

  Project({
    required this.name,
    required this.owner,
    this.type,
    this.targetDate,
    required this.status,
    this.userId,
    List<String>? members,
  }) : members = members ?? [];

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] as String,
        owner: json['owner'] as String,
        type: json['type'] as String?,
        targetDate:
            json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
        status: json['status'] as String,
        userId: json['userId'] as String?,
        members: json['members'] != null 
            ? List<String>.from(json['members']) 
            : [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'owner': owner,
        'type': type,
        'targetDate': targetDate?.toIso8601String(),
        'status': status,
        'userId': userId,
        'members': members,
      };

  List<String> get allTeamMembers {
    final all = <String>[owner, ...members];
    return all.toSet().toList(); // Remove duplicates
  }

  Project copyWith({
    String? status,
    List<String>? members,
  }) => Project(
        name: name,
        owner: owner,
        type: type,
        targetDate: targetDate,
        status: status ?? this.status,
        userId: userId,
        members: members ?? this.members,
      );
}
