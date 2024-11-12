class Task {
  int? id;
  String name;
  bool isCompleted;

  Task({this.id, required this.name, this.isCompleted = false});

  // Convertir un Task en un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Convertir un Map de SQLite en un Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
