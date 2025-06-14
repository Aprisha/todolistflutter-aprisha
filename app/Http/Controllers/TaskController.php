<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Task;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
    public function toggle($id)
    {
        $user = auth()->user();
        $task = Task::where('user_id', $user->id)->findOrFail($id);

        $task->selesai = !$task->selesai;
        $task->selesai_at = $task->selesai ? now() : null;
        $task->save();

        return response()->json(['message' => 'Status tugas diperbarui', 'task' => $task]);
    }


    public function index(Request $request)
    {
        // Update status otomatis jika lewat deadline
        Task::where('user_id', Auth::id())
            ->where('status', 'berjalan')
            ->where('deadline', '<', now())
            ->update(['status' => 'lewat deadline']);

        $query = Task::where('user_id', Auth::id());

        // Filter berdasarkan kategori
        if ($request->has('kategori') && $request->kategori !== 'SEMUA') {
            $query->where('kategori', $request->kategori);
        }

        // Pencarian judul
        if ($request->has('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        // Urutkan berdasarkan status dan deadline
        $query->orderByRaw("
            CASE
                WHEN status = 'berjalan' THEN 1
                WHEN status = 'lewat deadline' THEN 2
                WHEN status = 'selesai' THEN 3
                ELSE 4
            END
        ")->orderBy('deadline', 'asc');

        $tasks = $query->get();

        return response()->json([
            'message' => 'Berhasil mengambil daftar tugas',
            'data' => $tasks
        ]);
    }

    public function store(Request $request)
    {
        $fields = $request->validate([
            'judul' => 'required|string',
            'deskripsi' => 'nullable|string',
            'kategori' => 'nullable|in:pribadi,pekerjaan,belanja',
            'deadline' => 'required|date|after_or_equal:today',
        ]);

        $task = Task::create([
            'user_id' => Auth::id(),
            'judul' => $fields['judul'],
            'deskripsi' => $fields['deskripsi'] ?? null,
            'kategori' => $fields['kategori'] ?? null,
            'deadline' => $fields['deadline'],
            'status' => 'berjalan',
            'created_at' => now(),
        ]);

        return response()->json([
            'message' => 'Tugas berhasil ditambahkan',
            'data' => $task
        ], 201);
    }

    public function show($id)
    {
        $task = Task::where('user_id', Auth::id())->findOrFail($id);
        return response()->json([
            'message' => 'Detail tugas berhasil diambil',
            'data' => $task
        ]);
    }

    public function update(Request $request, $id)
    {
        $task = Task::where('user_id', Auth::id())->findOrFail($id);

        $fields = $request->validate([
            'judul' => 'required|string',
            'deskripsi' => 'nullable|string',
            'kategori' => 'nullable|in:pribadi,pekerjaan,belanja',
            'deadline' => 'required|date|after_or_equal:today',
            'status' => 'required|in:berjalan,selesai,lewat deadline',
        ]);

        $task->update($fields);

        // Set tanggal selesai bila status berubah menjadi selesai
        if ($fields['status'] === 'selesai' && !$task->tanggal_selesai) {
            $task->tanggal_selesai = now();
            $task->save();
        }

        return response()->json([
            'message' => 'Tugas berhasil diperbarui',
            'data' => $task
        ]);
    }

    public function destroy($id)
    {
        $task = Task::where('user_id', Auth::id())->findOrFail($id);
        $task->delete();

        return response()->json(['message' => 'Tugas berhasil dihapus']);
    }
}
