import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dateColor = task.isOverdue ? AppColors.red : AppColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: neoBox(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    task.project,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event_outlined, size: 15, color: dateColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          task.time.isEmpty
                              ? formatDate(task.date)
                              : '${formatDate(task.date)} • ${task.time}',
                          overflow: TextOverflow.ellipsis,
                          style:
                              GoogleFonts.poppins(fontSize: 11, color: dateColor),
                        ),
                      ),
                    ],
                  ),
                  if (task.category.isNotEmpty || task.assignee.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (task.category.isNotEmpty)
                          _pill(task.category, AppColors.chip),
                        if (task.assignee.isNotEmpty)
                          _pill('@${task.assignee}', AppColors.coral,
                              textColor: Colors.white),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? AppColors.teal : Colors.white,
                  border: Border.all(
                    color: task.isDone ? AppColors.ink : AppColors.coral,
                    width: task.isDone ? 1.5 : 4,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 22, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, {Color textColor = AppColors.ink}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}
