<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TaskController;
use Illuminate\Http\Request;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return response()->json([
        'status' => true,
        'data' => $request->user()
    ]);
});


// Welcome message
Route::get('/', function () {
    return response()->json([
        'message' => 'Welcome to the Todo API',
        'version' => '1.0'
    ]);
});

// Auth (public) routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/users', [AuthController::class, 'getAllUsers']); // Optional: untuk debugging user list

// Protected routes (hanya bisa diakses dengan token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Task routes
    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks', [TaskController::class, 'store']);
    Route::get('/tasks/{id}', [TaskController::class, 'show']);
    Route::put('/tasks/{id}', [TaskController::class, 'update']);
    Route::delete('/tasks/{id}', [TaskController::class, 'destroy']);
    Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);
    Route::put('/tasks/{id}/toggle', [TaskController::class, 'toggleSelesai'])->middleware('auth:sanctum');
    Route::put('/tasks/{id}/toggle', [TaskController::class, 'toggle']);

});
