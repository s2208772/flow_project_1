import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow_project_1/models/activity_log.dart';

//Code adapted from (Badar, 2024)
class ActivityLogStore {
  static final ActivityLogStore instance = ActivityLogStore._();
  ActivityLogStore._();

  final CollectionReference _activityCollection =
      FirebaseFirestore.instance.collection('activity_logs');

  final CollectionReference _visitsCollection =
      FirebaseFirestore.instance.collection('project_visits');

  /// Log an activity
  Future<void> logActivity({
    required String projectId,
    required String action,
    required String itemType,
    required String itemName,
    String? details,
    String userId = 'current_user',
  }) async {
    final activity = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      action: action,
      itemType: itemType,
      itemName: itemName,
      details: details,
      timestamp: DateTime.now(),
      userId: userId,
    );
    await _activityCollection.add(activity.toJson());
  }

  Future<List<ActivityLog>> getActivitiesSince(String projectId, DateTime since) async {
    try {
      final snapshot = await _activityCollection
          .where('projectId', isEqualTo: projectId)
          .get();
      final activities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityLog.fromJson(data);
      }).where((a) => a.timestamp.isAfter(since)).toList();
      
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    } catch (e) {
      log('Error getting activities: $e');
      return [];
    }
  }

  Future<List<ActivityLog>> getRecentActivities(String projectId, {int limit = 50}) async {
    try {
      final snapshot = await _activityCollection
          .where('projectId', isEqualTo: projectId)
          .get();
      final activities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityLog.fromJson(data);
      }).toList();
      
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } catch (e) {
      log('Error getting recent activities: $e');
      return [];
    }
  }

  /// Record when user last opened a project
  Future<void> recordVisit(String projectId, {String userId = 'current_user'}) async {
    final docId = '${projectId}_$userId';
    await _visitsCollection.doc(docId).set({
      'projectId': projectId,
      'userId': userId,
      'lastVisit': DateTime.now().toIso8601String(),
    });
  }

  /// Get the last time user opened a project
  Future<DateTime?> getLastVisit(String projectId, {String userId = 'current_user'}) async {
    final docId = '${projectId}_$userId';
    final doc = await _visitsCollection.doc(docId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['lastVisit'] != null) {
        return DateTime.parse(data['lastVisit']);
      }
    }
    return null;
  }

  Future<void> clearProjectActivities(String projectId) async {
    final snapshot = await _activityCollection
        .where('projectId', isEqualTo: projectId)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}

//End of adapted code

//References
// Badar, A. (2024, October 25). How to Maintain an Activity Log in Firebase Using FlutterFlow. Medium. https://medium.com/@abhishekbadar/how-to-maintain-an-activity-log-in-firebase-using-flutterflow-5b748548d2da
