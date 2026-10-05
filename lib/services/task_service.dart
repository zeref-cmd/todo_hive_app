import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

/// All Hive CRUD operations live here.
class TaskService {
  static const String boxName = 'taskBox';

  static Box<Task> get box => Hive.box<Task>(boxName);

  // CREATE
  static Future<void> add(Task task) => box.add(task);

  // UPDATE
  static Future<void> update(Task task) => box.put(task.key, task);

  // DELETE
  static Future<void> delete(Task task) => box.delete(task.key);

  // READ is done in the UI via box.listenable() + ValueListenableBuilder.
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
