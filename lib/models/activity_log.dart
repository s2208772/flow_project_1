class ActivityLog {
  final String id;
  final String projectId;
  final String action;
  final String itemType; 
  final String itemName;
  final String? details; 
  final DateTime timestamp;
  final String userId;

  ActivityLog({
    required this.id,
    required this.projectId,
    required this.action,
    required this.itemType,
    required this.itemName,
    this.details,
    required this.timestamp,
    required this.userId,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      action: json['action'] ?? '',
      itemType: json['itemType'] ?? '',
      itemName: json['itemName'] ?? '',
      details: json['details'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'action': action,
      'itemType': itemType,
      'itemName': itemName,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  String get actionDisplay {
    switch (action) {
      case 'added':
        return 'Added';
      case 'edited':
        return 'Edited';
      case 'deleted':
        return 'Deleted';
      default:
        return action;
    }
  }

  String get itemTypeDisplay {
    switch (itemType) {
      case 'task':
        return 'Task';
      case 'risk':
        return 'Risk';
      default:
        return itemType;
    }
  }
}
