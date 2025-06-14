class Task {
  final int id;
  final String judul;
  final String? deskripsi;
  final String? kategori;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool selesai;

  Task({
    required this.id,
    required this.judul,
    this.deskripsi,
    this.kategori,
    required this.deadline,
    required this.createdAt,
    this.completedAt,
    required this.selesai,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      selesai: json['status'] == 'selesai',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': selesai ? 'selesai' : 'berjalan',
    };
  }
}
