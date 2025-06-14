import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';
import 'login_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];
  String kategori = 'SEMUA';
  String searchQuery = '';
  bool isLoading = false;

  final List<String> kategoriList = [
    'SEMUA',
    'PRIBADI',
    'PEKERJAAN',
    'BELANJA'
  ];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    try {
      final fetchedTasks = await ApiService.getTasks(
        kategori: kategori,
        search: searchQuery,
      );
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat tugas: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> updateTaskStatus(Task task, bool value) async {
    try {
      final success = await ApiService.updateTaskStatus(task.id, value);
     try {
        await ApiService.updateTaskStatus(task.id, value!);
        fetchTasks(); // atau onRefresh() sesuai nama fungsi kamu
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ubah status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasks = [
      ...tasks.where((t) => !t.selesai),
      ...tasks.where((t) => t.selesai),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        children: [
          // Filter dan Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: kategori,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => kategori = value);
                      fetchTasks();
                    }
                  },
                  items: kategoriList
                      .map((k) => DropdownMenuItem(
                            value: k,
                            child: Text(k),
                          ))
                      .toList(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari tugas...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      setState(() => searchQuery = value);
                      fetchTasks();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchTasks,
                    child: ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final now = DateTime.now();
                        final deadline = task.deadline;
                        final isLate = !task.selesai && deadline.isBefore(now);
                        final dateFormat = DateFormat('dd MMM yyyy HH:mm');

                        return Card(
                          color: task.selesai ? Colors.grey[200] : Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: ListTile(
                            title: Text(
                              task.judul,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: task.selesai
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.deskripsi != null &&
                                    task.deskripsi!.isNotEmpty)
                                  Text(task.deskripsi!),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                        'Deadline: ${dateFormat.format(deadline)}',
                                        style: TextStyle(
                                          color: isLate ? Colors.red : null,
                                          fontWeight:
                                              isLate ? FontWeight.bold : null,
                                        )),
                                  ],
                                ),
                                Text(
                                    'Dibuat: ${dateFormat.format(task.createdAt)}'),
                                if (task.selesai && task.completedAt != null)
                                  Text(
                                      'Selesai: ${dateFormat.format(task.completedAt!)}'),
                                if (task.kategori != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Chip(
                                      label: Text(task.kategori!),
                                      backgroundColor: Colors.blue.shade50,
                                    ),
                                  ),
                              ],
                            ),
                            leading: Checkbox(
                              value: task.selesai,
                              onChanged: (value) {
                                if (value != null) {
                                  updateTaskStatus(task, value);
                                }
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskPage(task: task),
                                  ),
                                ).then((_) => fetchTasks());
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          fetchTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
