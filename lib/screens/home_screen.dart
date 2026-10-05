import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

enum TaskFilter { all, pending, done, overdue }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter _filter = TaskFilter.all;

  bool _matches(Task t) {
    switch (_filter) {
      case TaskFilter.all:
        return true;
      case TaskFilter.pending:
        return !t.isDone;
      case TaskFilter.done:
        return t.isDone;
      case TaskFilter.overdue:
        return t.isOverdue;
    }
  }

  String get _sectionTitle {
    switch (_filter) {
      case TaskFilter.all:
        return 'Recent Task';
      case TaskFilter.pending:
        return 'Pending Task';
      case TaskFilter.done:
        return 'Completed Task';
      case TaskFilter.overdue:
        return 'Overdue Task';
    }
  }

  void _openForm([Task? task]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _delete(Task task) async {
    final backup = task.copy();
    await TaskService.delete(task);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.coral,
            onPressed: () => TaskService.add(backup),
          ),
        ),
      );
  }

  Future<void> _toggle(Task task) async {
    task.isDone = !task.isDone;
    await TaskService.update(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // READ: the list rebuilds instantly on every create/update/delete.
        child: ValueListenableBuilder<Box<Task>>(
          valueListenable: TaskService.box.listenable(),
          builder: (context, box, _) {
            final all = box.values.toList()
              ..sort((a, b) {
                if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
                return a.date.compareTo(b.date);
              });
            final tasks = all.where(_matches).toList();

            final pending = all.where((t) => !t.isDone).length;
            final done = all.where((t) => t.isDone).length;
            final overdue = all.where((t) => t.isOverdue).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                _header(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total',
                        count: all.length,
                        color: AppColors.blue,
                        icon: Icons.sync_rounded,
                        onTap: () => setState(() => _filter = TaskFilter.all),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Pending',
                        count: pending,
                        color: AppColors.yellow,
                        icon: Icons.schedule_rounded,
                        onTap: () =>
                            setState(() => _filter = TaskFilter.pending),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Completed',
                        count: done,
                        color: AppColors.teal,
                        icon: Icons.task_alt_rounded,
                        onTap: () => setState(() => _filter = TaskFilter.done),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Overdue',
                        count: overdue,
                        color: AppColors.red,
                        icon: Icons.error_outline_rounded,
                        onTap: () =>
                            setState(() => _filter = TaskFilter.overdue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _sectionTitle,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                if (tasks.isEmpty)
                  _emptyState()
                else
                  ...tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      // DELETE: swipe to remove from the list and the Hive box.
                      child: Dismissible(
                        key: ValueKey(task.key),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _delete(task),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white, size: 28),
                        ),
                        child: TaskCard(
                          task: task,
                          onTap: () => _openForm(task),
                          onToggle: () => _toggle(task),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'All', TaskFilter.all),
            _navItem(Icons.calendar_today_rounded, 'Pending', TaskFilter.pending),
            const SizedBox(width: 56),
            _navItem(Icons.task_alt_rounded, 'Done', TaskFilter.done),
            _navItem(Icons.error_outline_rounded, 'Overdue', TaskFilter.overdue),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD9CF),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 1.5),
          ),
          child: const Icon(Icons.checklist_rounded,
              color: AppColors.coral, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi there 👋',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              Text('Your daily adventure starts now',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _filter = TaskFilter.all),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E9E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: neoBox(),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: AppColors.muted),
          const SizedBox(height: 10),
          Text('No tasks here yet',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          Text('Tap the + button to create one',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String tooltip, TaskFilter f) {
    final active = _filter == f;
    return IconButton(
      tooltip: tooltip,
      onPressed: () => setState(() => _filter = f),
      icon: Icon(
        icon,
        color: active ? AppColors.coral : const Color(0xFFF8B4A5),
      ),
    );
  }
}
