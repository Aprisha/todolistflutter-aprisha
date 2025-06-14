import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  DateTime? _deadline;
  String? _kategori;
  bool _selesai = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.task.judul);
    _deskripsiController = TextEditingController(text: widget.task.deskripsi);
    _deadline = widget.task.deadline;
    _kategori = widget.task.kategori;
    _selesai = widget.task.selesai;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _deadline == null) return;

    try {
      await ApiService.updateTask(
        id: widget.task.id,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        kategori: _kategori,
        deadline: _deadline!,
        selesai: _selesai,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengedit tugas: $e')),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus tugas ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tugas')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 500 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(labelText: 'Judul'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      value: _kategori,
                      items: const [
                        DropdownMenuItem(
                            value: 'pribadi', child: Text('Pribadi')),
                        DropdownMenuItem(
                            value: 'pekerjaan', child: Text('Pekerjaan')),
                        DropdownMenuItem(
                            value: 'belanja', child: Text('Belanja')),
                      ],
                      onChanged: (val) => setState(() => _kategori = val),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_deadline == null
                          ? 'Pilih Deadline'
                          : 'Deadline: ${DateFormat.yMMMMd().add_jm().format(_deadline!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate: _deadline ?? DateTime.now(),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _deadline ?? DateTime.now()),
                          );
                          if (time != null) {
                            setState(() {
                              _deadline = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _selesai,
                      onChanged: (val) => setState(() => _selesai = val),
                      title: const Text('Tandai sebagai selesai'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _deleteTask,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Hapus Tugas'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
