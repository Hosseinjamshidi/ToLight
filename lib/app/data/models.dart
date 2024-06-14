import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String uid;
  String email;
  String displayName;

  Users({
    required this.uid,
    required this.email,
    this.displayName = '',
  });

  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Users(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }
}

class Settings {
  int id;
  bool onboard;
  String? theme;
  String timeformat;
  bool materialColor;
  bool amoledTheme;
  bool? isImage;
  String? language;
  String firstDay;
  String userId;

  Settings({
    required this.id,
    this.onboard = false,
    this.theme = 'system',
    this.timeformat = '24',
    this.materialColor = true,
    this.amoledTheme = false,
    this.isImage = true,
    this.language,
    this.firstDay = 'monday',
    required this.userId,
  });

  factory Settings.fromFirestore(Map<String, dynamic> data) {
    return Settings(
      id: data['id'] ?? 0,
      onboard: data['onboard'] ?? false,
      theme: data['theme'] ?? 'system',
      timeformat: data['timeformat'] ?? '24',
      materialColor: data['materialColor'] ?? true,
      amoledTheme: data['amoledTheme'] ?? false,
      isImage: data['isImage'] ?? true,
      language: data['language'],
      firstDay: data['firstDay'] ?? 'monday',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'onboard': onboard,
      'theme': theme,
      'timeformat': timeformat,
      'materialColor': materialColor,
      'amoledTheme': amoledTheme,
      'isImage': isImage,
      'language': language,
      'firstDay': firstDay,
      'userId': userId,
    };
  }
}

class Tasks {
  int id;
  String title;
  String description;
  int taskColor;
  bool archive;
  int? index;
  String userId; // Add user ID to link to a specific user

  Tasks({
    required this.id,
    required this.title,
    this.description = '',
    this.archive = false,
    required this.taskColor,
    this.index,
    required this.userId, // Initialize with user ID
  });

  factory Tasks.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tasks(
      id: data['id'] is int ? data['id'] : int.parse(data['id'].toString()),
      title: data['title'],
      description: data['description'] ?? '',
      taskColor: data['taskColor'],
      archive: data['archive'] ?? false,
      index: data['index'],
      userId: data['userId'], // Extract user ID
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'taskColor': taskColor,
      'archive': archive,
      'index': index,
      'userId': userId, // Include user ID
    };
  }
}

class Todos {
  int id;
  String name;
  String description;
  DateTime? todoCompletedTime;
  bool done;
  bool fix;
  int priority;
  double duration;
  bool selected;
  DueType dueType;
  bool strict;
  List<int> dependencies;
  DateTime? startDate;
  Status status;
  DateTime? hour;
  bool skipped;
  int streak;
  DateTime? creationDate;
  int skipCount;
  double timeSpent;
  int daysPassed;
  int? taskId; // Store task ID instead of the entire task object
  String userId; // Add user ID to link to a specific user

  Todos({
    required this.id,
    required this.name,
    this.description = '',
    this.todoCompletedTime,
    this.done = false,
    this.fix = false,
    this.priority = 3,
    this.duration = 1.0,
    this.selected = false,
    this.dueType = DueType.doneBy,
    this.strict = false,
    this.dependencies = const [],
    this.startDate,
    this.status = Status.none,
    this.hour,
    this.skipped = false,
    this.streak = 0,
    this.creationDate,
    this.skipCount = 0,
    this.timeSpent = 0.0,
    this.daysPassed = 0,
    this.taskId, // Initialize with task ID
    required this.userId, // Initialize with user ID
  });

  factory Todos.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Todos(
      id: data['id'] is int ? data['id'] : int.parse(data['id'].toString()),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      todoCompletedTime: (data['todoCompletedTime'] as Timestamp?)?.toDate(),
      done: data['done'] ?? false,
      fix: data['fix'] ?? false,
      priority: data['priority'] is int
          ? data['priority']
          : int.parse(data['priority'].toString()),
      duration: (data['duration'] as num?)?.toDouble() ?? 1.0,
      selected: data['selected'] ?? false,
      dueType: DueType.values[(data['dueType'] is int
              ? data['dueType']
              : int.parse(data['dueType'].toString())) %
          DueType.values.length],
      strict: data['strict'] ?? false,
      dependencies: List<int>.from(data['dependencies'] ?? []),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      status: Status.values[(data['status'] is int
              ? data['status']
              : int.parse(data['status'].toString())) %
          Status.values.length],
      hour: (data['hour'] as Timestamp?)?.toDate(),
      skipped: data['skipped'] ?? false,
      streak: data['streak'] ?? 0,
      creationDate: (data['creationDate'] as Timestamp?)?.toDate(),
      skipCount: data['skipCount'] ?? 0,
      timeSpent: (data['timeSpent'] as num?)?.toDouble() ?? 0.0,
      daysPassed: data['daysPassed'] ?? 0,
      taskId: data['taskId'], // Extract task ID
      userId: data['userId'], // Extract user ID
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'todoCompletedTime': todoCompletedTime,
      'done': done,
      'fix': fix,
      'priority': priority,
      'duration': duration,
      'selected': selected,
      'dueType': dueType.index,
      'strict': strict,
      'dependencies': dependencies,
      'startDate': startDate,
      'status': status.index,
      'hour': hour,
      'skipped': skipped,
      'streak': streak,
      'creationDate': creationDate,
      'skipCount': skipCount,
      'timeSpent': timeSpent,
      'daysPassed': daysPassed,
      'taskId': taskId, // Include task ID
      'userId': userId, // Include user ID
    };
  }
}

enum DueType {
  doneAt,
  doneBy,
  doneBetween,
  doneEveryDay,
  doneEveryWeek,
  doneEveryMonth,
}

enum Status {
  none,
  completing,
  skipping,
  deleting,
  selecting,
}
