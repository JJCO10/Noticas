import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite/models/task_model.dart';

class TaskController extends GetxController {
  late Database db; // Campo late para la base de datos
  var tasks = <Task>[].obs; // Lista observable de tareas
  var isDatabaseInitialized = false.obs; // Bandera para verificar si la base de datos está inicializada

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase(); // Inicializar la base de datos al iniciar el controlador
  }

  // Método para inicializar la base de datos
  Future<void> _initializeDatabase() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'tasks_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, isCompleted INTEGER)',
        );
      },
      version: 1,
    );
    isDatabaseInitialized.value = true; // Marcar la base de datos como inicializada
    _loadTasks(); // Cargar tareas después de inicializar la base de datos
  }

  // Método para cargar tareas desde la base de datos
  Future<void> _loadTasks() async {
    if (isDatabaseInitialized.value) {
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      tasks.value = List.generate(maps.length, (i) {
        return Task(
          id: maps[i]['id'],
          name: maps[i]['name'],
          isCompleted: maps[i]['isCompleted'] == 1,
        );
      });
    }
  }

  // Método para agregar una nueva tarea
  Future<void> addTask(String name) async {
    if (isDatabaseInitialized.value) {
      await db.insert(
        'tasks',
        {'name': name, 'isCompleted': 0},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _loadTasks(); // Recargar tareas después de agregar
    }
  }

  // Método para eliminar una tarea
  Future<void> deleteTask(int id) async {
    if (isDatabaseInitialized.value) {
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      _loadTasks(); // Recargar tareas después de eliminar
    }
  }

  // Método para alternar la finalización de una tarea
  Future<void> toggleTaskCompletion(Task task) async {
    if (isDatabaseInitialized.value) {
      task.isCompleted = !task.isCompleted;
      await db.update(
        'tasks',
        {'isCompleted': task.isCompleted ? 1 : 0},
        where: 'id = ?',
        whereArgs: [task.id],
      );
      _loadTasks(); // Recargar tareas después de actualizar
    }
  }
}
