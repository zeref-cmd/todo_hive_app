import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String project;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String time;

  @HiveField(4)
  String assignee;

  @HiveField(5)
  String category;

  @HiveField(6)
  String details;

  @HiveField(7)
  bool isDone;

  Task({
    required this.title,
    required this.date,
    this.project = 'General',
    this.time = '',
    this.assignee = '',
    this.category = '',
    this.details = '',
    this.isDone = false,
  });

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !isDone && date.isBefore(today);
  }

  /// Detached copy (used for the "Undo" after a swipe-delete).
  Task copy() => Task(
        title: title,
        date: date,
        project: project,
        time: time,
        assignee: assignee,
        category: category,
        details: details,
        isDone: isDone,
      );
}
