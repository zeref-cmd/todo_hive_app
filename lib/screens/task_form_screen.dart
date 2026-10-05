import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';

/// One form used for both CREATE (task == null) and UPDATE (task != null).
/// Contains exactly 7 text inputs:
///   1 Title  2 Project  3 Date  4 Time  5 Assignee  6 Category  7 Details
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const _categories = [
    'Design',
    'Development',
    'Coding',
    'Meeting',
    'Office Time',
    'User Experience',
  ];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _project = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _assignee = TextEditingController();
  final _category = TextEditingController();
  final _details = TextEditingController();

  DateTime? _pickedDate;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _title.text = t.title;
      _project.text = t.project;
      _pickedDate = t.date;
      _date.text = formatDate(t.date);
      _time.text = t.time;
      _assignee.text = t.assignee;
      _category.text = t.category;
      _details.text = t.details;
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _project, _date, _time, _assignee, _category, _details]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _pickedDate = picked;
        _date.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() => _time.text = picked.format(context));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final project =
        _project.text.trim().isEmpty ? 'General' : _project.text.trim();
    final d = _pickedDate!;
    final date = DateTime(d.year, d.month, d.day);

    final existing = widget.task;
    if (existing == null) {
      // CREATE
      await TaskService.add(Task(
        title: _title.text.trim(),
        project: project,
        date: date,
        time: _time.text.trim(),
        assignee: _assignee.text.trim(),
        category: _category.text.trim(),
        details: _details.text.trim(),
      ));
    } else {
      // UPDATE
      existing
        ..title = _title.text.trim()
        ..project = project
        ..date = date
        ..time = _time.text.trim()
        ..assignee = _assignee.text.trim()
        ..category = _category.text.trim()
        ..details = _details.text.trim();
      await TaskService.update(existing);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style:
                GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(fontSize: 13);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.ink, width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(_isEdit ? 'Edit Task' : 'New Task',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w600)),

                // 1. Title (required)
                _label('Task Title'),
                TextFormField(
                  controller: _title,
                  style: style,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Enter task title'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Task title cannot be empty'
                      : null,
                ),

                // 2. Project
                _label('Project'),
                TextFormField(
                  controller: _project,
                  style: style,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Digital Product Design'),
                ),

                // 3. Date (required, picker)
                _label('Date'),
                TextFormField(
                  controller: _date,
                  style: style,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.arrow_drop_down_rounded, size: 30),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please select a date' : null,
                ),

                // 4. Time (picker)
                _label('Time'),
                TextFormField(
                  controller: _time,
                  style: style,
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: const InputDecoration(
                    hintText: 'Select time',
                    suffixIcon: Icon(Icons.access_time_rounded),
                  ),
                ),

                // 5. Assignee
                _label('Assignee'),
                TextFormField(
                  controller: _assignee,
                  style: style,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Assign to',
                    suffixIcon: Icon(Icons.search_rounded),
                  ),
                ),

                // 6. Category (+ quick-pick chips)
                _label('Category'),
                TextFormField(
                  controller: _category,
                  style: style,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Type or pick below'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final selected =
                        _category.text.trim().toLowerCase() == c.toLowerCase();
                    return GestureDetector(
                      onTap: () => setState(() => _category.text = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.coral : AppColors.chip,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // 7. Details (multiline)
                _label('Task Details'),
                TextFormField(
                  controller: _details,
                  style: style,
                  minLines: 4,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(hintText: 'Add your task details'),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    child: Text(_isEdit ? 'Save Changes' : 'Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
