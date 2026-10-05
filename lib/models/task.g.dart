// GENERATED CODE - equivalent to hive_generator output.
// Regenerate anytime with: dart run build_runner build --delete-conflicting-outputs

part of 'task.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      project: fields[1] as String,
      date: fields[2] as DateTime,
      time: fields[3] as String,
      assignee: fields[4] as String,
      category: fields[5] as String,
      details: fields[6] as String,
      isDone: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.project)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.assignee)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.details)
      ..writeByte(7)
      ..write(obj.isDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
