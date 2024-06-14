import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todark/app/data/models.dart' as app_models;
import 'package:todark/app/data/models.dart';
import 'package:todark/app/services/notification.dart';
import 'package:todark/main.dart';

class TodoController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  final tasks = <Tasks>[].obs;
  final todos = <Todos>[].obs;

  final selectedTask = <Tasks>[].obs;
  final isMultiSelectionTask = false.obs;

  final selectedTodo = <Todos>[].obs;
  final isMultiSelectionTodo = false.obs;

  RxBool isPop = true.obs;

  final duration = const Duration(milliseconds: 500);
  var now = DateTime.now();

  TextEditingController titleCategoryEdit = TextEditingController();
  TextEditingController descCategoryEdit = TextEditingController();

  TextEditingController textTodoConroller = TextEditingController();
  TextEditingController transferTodoConroller = TextEditingController();
  TextEditingController titleTodoEdit = TextEditingController();
  TextEditingController descTodoEdit = TextEditingController();
  TextEditingController timeTodoEdit = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    loadTodos();
  }

  Future<List<Tasks>> getTasks() async {
    if (currentUser == null) return [];
    var querySnapshot = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .where('archive', isEqualTo: false)
        .get();
    return querySnapshot.docs.map((doc) => Tasks.fromFirestore(doc)).toList();
  }

  Future<void> loadTasks() async {
    if (currentUser == null) return;
    var querySnapshot = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .get();
    tasks.assignAll(
        querySnapshot.docs.map((doc) => Tasks.fromFirestore(doc)).toList());
  }

  Future<void> loadTodos() async {
    if (currentUser == null) return;
    var querySnapshot = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .get();
    todos.assignAll(
        querySnapshot.docs.map((doc) => Todos.fromFirestore(doc)).toList());
  }

  // Tasks
  Future<void> addTask(String title, String desc, Color myColor) async {
    if (currentUser == null) return;
    var searchTask = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .where('title', isEqualTo: title)
        .get();

    final taskCreate = Tasks(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      description: desc,
      taskColor: myColor.value,
      userId: currentUser!.uid,
    );

    if (searchTask.docs.isEmpty) {
      tasks.add(taskCreate);
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(taskCreate.id.toString())
          .set(taskCreate.toFirestore());
      EasyLoading.showSuccess('createCategory'.tr, duration: duration);
    } else {
      EasyLoading.showError('duplicateCategory'.tr, duration: duration);
    }
  }

  Future<void> updateTask(
      Tasks task, String title, String desc, Color myColor) async {
    if (currentUser == null) return;
    task.title = title;
    task.description = desc;
    task.taskColor = myColor.value;
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('tasks')
        .doc(task.id.toString())
        .update(task.toFirestore());

    var newTask = task;
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = newTask;
    tasks.refresh();
    todos.refresh();

    EasyLoading.showSuccess('editCategory'.tr, duration: duration);
  }

  Future<void> deleteTask(List<Tasks> taskList) async {
    if (currentUser == null) return;
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      // Delete Notification
      var getTodo = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .where('taskId', isEqualTo: task.id)
          .get();

      for (var todo in getTodo.docs) {
        var todoData = Todos.fromFirestore(todo);
        if (todoData.todoCompletedTime != null) {
          if (todoData.todoCompletedTime!.isAfter(now)) {
            await flutterLocalNotificationsPlugin.cancel(todoData.id);
          }
        }
      }
      // Delete Todos
      todos.removeWhere((todo) => todo.taskId == task.id);
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .where('taskId', isEqualTo: task.id)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('todos')
              .doc(doc.id)
              .delete();
        }
      });

      // Delete Task
      tasks.remove(task);
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(task.id.toString())
          .delete();
      EasyLoading.showSuccess('categoryDelete'.tr, duration: duration);
    }
  }

  Future<void> archiveTask(List<Tasks> taskList) async {
    if (currentUser == null) return;
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      // Delete Notification
      var getTodo = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .where('taskId', isEqualTo: task.id)
          .get();

      for (var todo in getTodo.docs) {
        var todoData = Todos.fromFirestore(todo);
        if (todoData.todoCompletedTime != null) {
          if (todoData.todoCompletedTime!.isAfter(now)) {
            await flutterLocalNotificationsPlugin.cancel(todoData.id);
          }
        }
      }
      // Archive Task
      task.archive = true;
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(task.id.toString())
          .update(task.toFirestore());
      tasks.refresh();
      todos.refresh();
      EasyLoading.showSuccess('categoryArchive'.tr, duration: duration);
    }
  }

  Future<void> noArchiveTask(List<Tasks> taskList) async {
    if (currentUser == null) return;
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      // Create Notification
      var getTodo = await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .where('taskId', isEqualTo: task.id)
          .get();

      for (var todo in getTodo.docs) {
        var todoData = Todos.fromFirestore(todo);
        if (todoData.todoCompletedTime != null) {
          if (todoData.todoCompletedTime!.isAfter(now)) {
            NotificationShow().showNotification(
              todoData.id,
              todoData.name,
              todoData.description,
              todoData.todoCompletedTime,
            );
          }
        }
      }
      // No archive Task
      task.archive = false;
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .doc(task.id.toString())
          .update(task.toFirestore());
      tasks.refresh();
      todos.refresh();
      EasyLoading.showSuccess('noCategoryArchive'.tr, duration: duration);
    }
  }

  // Todos
  Future<void> addTodo(
      Tasks task, String title, String desc, String time) async {
    if (currentUser == null) return;
    DateTime? date;
    if (time.isNotEmpty) {
      date = timeformat == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    var getTodos = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .where('name', isEqualTo: title)
        .where('taskId', isEqualTo: task.id)
        .where('todoCompletedTime', isEqualTo: date)
        .get();

    final todosCreate = Todos(
      id: DateTime.now().millisecondsSinceEpoch,
      name: title,
      description: desc,
      todoCompletedTime: date,
      taskId: task.id,
      userId: currentUser!.uid,
    );

    if (getTodos.docs.isEmpty) {
      todos.add(todosCreate);
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .doc(todosCreate.id.toString())
          .set(todosCreate.toFirestore());
      if (date != null && now.isBefore(date)) {
        NotificationShow().showNotification(
          todosCreate.id,
          todosCreate.name,
          todosCreate.description,
          date,
        );
      }
      EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
    } else {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    if (currentUser == null) return;
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .doc(todo.id.toString())
        .update(todo.toFirestore());
    todos.refresh();
  }

  Future<void> updateTodoFix(Todos todo) async {
    if (currentUser == null) return;
    todo.fix = !todo.fix;
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .doc(todo.id.toString())
        .update(todo.toFirestore());

    var newTodo = todo;
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = newTodo;
    todos.refresh();
  }

  Future<void> updateTodo(
      Todos todo, Tasks task, String title, String desc, String time) async {
    if (currentUser == null) return;
    DateTime? date;
    if (time.isNotEmpty) {
      date = timeformat == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }

    todo.name = title;
    todo.description = desc;
    todo.todoCompletedTime = date;
    todo.taskId = task.id;

    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .doc(todo.id.toString())
        .update(todo.toFirestore());

    var newTodo = todo;
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = newTodo;
    todos.refresh();

    if (date != null && now.isBefore(date)) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow().showNotification(
        todo.id,
        todo.name,
        todo.description,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> transferTodos(List<Todos> todoList, Tasks task) async {
    if (currentUser == null) return;
    List<Todos> todoListCopy = List.from(todoList);

    for (var todo in todoListCopy) {
      todo.taskId = task.id;
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .doc(todo.id.toString())
          .update(todo.toFirestore());

      var newTodo = todo;
      int oldIdx = todos.indexOf(todo);
      todos[oldIdx] = newTodo;
    }

    todos.refresh();
    tasks.refresh();

    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    if (currentUser == null) return;
    List<Todos> todoListCopy = List.from(todoList);

    for (var todo in todoListCopy) {
      if (todo.todoCompletedTime != null) {
        if (todo.todoCompletedTime!.isAfter(now)) {
          await flutterLocalNotificationsPlugin.cancel(todo.id);
        }
      }
      todos.remove(todo);
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('todos')
          .doc(todo.id.toString())
          .delete();
      EasyLoading.showSuccess('todoDelete'.tr, duration: duration);
    }
  }

  int createdAllTodos() {
    return todos.where((todo) => todo.taskId != null).length;
  }

  int completedAllTodos() {
    return todos
        .where((todo) => todo.taskId != null && todo.done == true)
        .length;
  }

  int createdAllTodosTask(Tasks task) {
    return todos.where((todo) => todo.taskId == task.id).length;
  }

  int completedAllTodosTask(Tasks task) {
    return todos
        .where((todo) => todo.taskId == task.id && todo.done == true)
        .length;
  }

  int countTotalTodosCalendar(DateTime date) {
    return todos
        .where((todo) =>
            todo.done == false &&
            todo.todoCompletedTime != null &&
            todo.taskId != null &&
            DateTime(date.year, date.month, date.day, 0, -1)
                .isBefore(todo.todoCompletedTime!) &&
            DateTime(date.year, date.month, date.day, 23, 60)
                .isAfter(todo.todoCompletedTime!))
        .length;
  }

  void doMultiSelectionTask(Tasks tasks) {
    if (isMultiSelectionTask.isTrue) {
      isPop.value = false;
      if (selectedTask.contains(tasks)) {
        selectedTask.remove(tasks);
      } else {
        selectedTask.add(tasks);
      }

      if (selectedTask.isEmpty) {
        isMultiSelectionTask.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTaskClear() {
    selectedTask.clear();
    isMultiSelectionTask.value = false;
    isPop.value = true;
  }

  void doMultiSelectionTodo(Todos todos) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todos)) {
        selectedTodo.remove(todos);
      } else {
        selectedTodo.add(todos);
      }

      if (selectedTodo.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTodoClear() {
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }

  // Settings
  Future<void> updateSetting(String key, dynamic value) async {
    if (currentUser == null || settings == null) return;

    // Update the settings object
    switch (key) {
      case 'theme':
        settings!.theme = value;
        break;
      case 'amoledTheme':
        settings!.amoledTheme = value;
        break;
      case 'materialColor':
        settings!.materialColor = value;
        break;
      case 'isImage':
        settings!.isImage = value;
        break;
      case 'timeformat':
        settings!.timeformat = value;
        break;
      case 'firstDay':
        settings!.firstDay = value;
        break;
      case 'language':
        settings!.language = value;
        break;
      default:
        return;
    }

    // Save the updated settings to Firestore
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('settings')
        .doc('settings')
        .set(settings!.toFirestore());

    // Refresh the local settings
    updateLocalSettings();
  }

  Future<void> updateLocalSettings() async {
    User? user = currentUser;
    if (user == null) {
      return; // Handle the case where user is not logged in
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot settingsSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('settings')
        .get();

    if (settingsSnapshot.exists) {
      settings = app_models.Settings.fromFirestore(
          settingsSnapshot.data() as Map<String, dynamic>);
      update();
    }
  }
}
