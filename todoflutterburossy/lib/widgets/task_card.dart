import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onUpdate;

  const TaskCard({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = task.selesai
        ? Colors.grey
        : task.deadline.isBefore(DateTime.now())
            ? Colors.red
            : Colors.green;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: task.selesai ? Colors.grey[200] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Judul dan Checkbox Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.judul,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.selesai ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Checkbox(
                  value: task.selesai,
                  onChanged: (value) async {
                    try {
                      await ApiService.updateTaskStatus(task.id, value!);
                      onUpdate();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal ubah status: $e')),
                      );
                    }
                  },
                ),
              ],
            ),

            /// Deskripsi (jika ada)
            if (task.deskripsi != null && task.deskripsi!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(task.deskripsi!),
              ),

            const SizedBox(height: 8),

            /// Kategori dan Status
            Row(
              children: [
                if (task.kategori != null)
                  Chip(
                    label: Text(task.kategori!),
                    backgroundColor: Colors.blue[50],
                  ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    task.selesai
                        ? 'Selesai'
                        : task.deadline.isBefore(DateTime.now())
                            ? 'Lewat Deadline'
                            : 'Berjalan',
                  ),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// Deadline & CreatedAt & CompletedAt
            Text(
              'Deadline: ${_formatDate(task.deadline)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Dibuat: ${_formatDate(task.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (task.completedAt != null)
              Text(
                'Selesai: ${_formatDate(task.completedAt!)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
