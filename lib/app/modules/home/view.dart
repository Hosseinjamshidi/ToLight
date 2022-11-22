import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:dark_todo/app/data/schema.dart';
import 'package:dark_todo/app/modules/calendar/view.dart';
import 'package:dark_todo/app/widgets/select_button.dart';
import 'package:dark_todo/app/widgets/task_type_cu.dart';
import 'package:dark_todo/app/widgets/task_type_list.dart';
import 'package:dark_todo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleEdit = TextEditingController();
  TextEditingController descEdit = TextEditingController();
  late Color myColor;
  int toggleValue = 0;
  var tasks = <Tasks>[];
  bool isLoaded = false;
  int countTotalTasks = 0;
  int countTotalDoneTasks = 0;
  final tabIndex = 0.obs;

  @override
  void initState() {
    myColor = const Color(0xFF2196F3);
    getTask();
    super.initState();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
    getTask();
  }

  Future<int> getTotalTask() async {
    int res = 0;
    List<Tasks> getTask;
    final taskCollection = isar.tasks;
    getTask = await taskCollection.where().findAll();
    for (var i = 0; i < getTask.length; i++) {
      if (getTask[i].todos.isNotEmpty) {
        res += getTask[i].todos.length;
      }
    }
    return res;
  }

  Future<int> getTotalDoneTask() async {
    int res = 0;
    List<Tasks> getTask;
    final taskCollection = isar.tasks;
    getTask = await taskCollection.where().findAll();
    for (var i = 0; i < getTask.length; i++) {
      if (getTask[i].todos.isNotEmpty) {
        res += getTask[i]
            .todos
            .where((element) => element.done == true)
            .toList()
            .length;
      }
    }
    return res;
  }

  getTask() async {
    List<Tasks> getTask;
    final taskCollection = isar.tasks;
    toggleValue == 0
        ? getTask =
            await taskCollection.filter().archiveEqualTo(false).findAll()
        : getTask =
            await taskCollection.filter().archiveEqualTo(true).findAll();
    countTotalTasks = await getTotalTask();
    countTotalDoneTasks = await getTotalDoneTask();
    toggleValue;
    setState(() {
      tasks = getTask;
      isLoaded = true;
    });
  }

  archiveTask(task) async {
    await isar.writeTxn(() async {
      task.archive = true;
      await isar.tasks.put(task);
    });
    EasyLoading.showSuccess('taskArchive'.tr,
        duration: const Duration(milliseconds: 500));
    getTask();
  }

  noArchiveTask(task) async {
    await isar.writeTxn(() async {
      task.archive = false;
      await isar.tasks.put(task);
    });
    EasyLoading.showSuccess('noTaskArchive'.tr,
        duration: const Duration(milliseconds: 500));
    getTask();
  }

  deleteTask(task) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(task.id);
    });
    EasyLoading.showSuccess('categoryDelete'.tr,
        duration: const Duration(milliseconds: 500));
    getTask();
  }

  deleteTaskTodos(task) async {
    await isar.writeTxn(() async {
      await isar.todos.filter().task((q) => q.idEqualTo(task.id)).deleteAll();
    });
    getTask();
  }

  addTask() async {
    final taskCreate = Tasks(
      title: titleEdit.text,
      description: descEdit.text,
      taskColor: myColor.hashCode,
    );

    List<Tasks> searchTask;
    final taskCollection = isar.tasks;

    searchTask =
        await taskCollection.filter().titleEqualTo(titleEdit.text).findAll();

    if (searchTask.isEmpty) {
      await isar.writeTxn(() async {
        await isar.tasks.put(taskCreate);
      });
      EasyLoading.showSuccess('createCategory'.tr,
          duration: const Duration(milliseconds: 500));
    } else {
      EasyLoading.showError('duplicateCategory'.tr,
          duration: const Duration(milliseconds: 500));
    }
    getTask();
    titleEdit.clear();
    descEdit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 30,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/icons.png',
              scale: 13,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'ToDark',
              style: context.theme.textTheme.headline1,
            ),
          ],
        ),
      ),
      body: Obx(
        (() => LazyLoadIndexedStack(
              index: tabIndex.value,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        bottom: 30,
                        top: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                CircularStepProgressIndicator(
                                  totalSteps: countTotalTasks != 0
                                      ? countTotalTasks
                                      : 1,
                                  currentStep: countTotalDoneTasks,
                                  stepSize: 4,
                                  selectedColor: Colors.blueAccent,
                                  unselectedColor: Colors.white,
                                  padding: 0,
                                  selectedStepSize: 6,
                                  roundedCap: (_, __) => true,
                                  child: Center(
                                    child: Text(
                                      countTotalTasks != 0
                                          ? '${((countTotalDoneTasks / countTotalTasks) * 100).round()}%'
                                          : '0%',
                                      style: context.theme.textTheme.headline2,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    'taskCompleted'.tr,
                                    style: context.theme.textTheme.headline5,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              DateFormat.MMMMd('$tag').format(
                                DateTime.now(),
                              ),
                              style: context.theme.textTheme.headline6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: Get.size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30, top: 20, bottom: 5, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'categories'.tr,
                                        style: context.theme.textTheme.headline1
                                            ?.copyWith(
                                                color: context
                                                    .theme.backgroundColor),
                                      ),
                                      Text(
                                        '($countTotalDoneTasks/$countTotalTasks) ${'completed'.tr}',
                                        style:
                                            context.theme.textTheme.subtitle2,
                                      ),
                                    ],
                                  ),
                                  SelectButton(
                                    icons: [
                                      Icon(
                                        Iconsax.archive_minus,
                                        color: context
                                            .theme.scaffoldBackgroundColor,
                                      ),
                                      Icon(
                                        Iconsax.archive_tick,
                                        color: context
                                            .theme.scaffoldBackgroundColor,
                                      ),
                                    ],
                                    onToggleCallback: (value) {
                                      setState(() {
                                        toggleValue = value;
                                      });
                                      getTask();
                                    },
                                    backgroundColor:
                                        context.theme.scaffoldBackgroundColor,
                                  ),
                                ],
                              ),
                            ),
                            TaskTypeList(
                              back: getTask,
                              isLoaded: isLoaded,
                              tasks: tasks,
                              onDelete: deleteTask,
                              onArchive: archiveTask,
                              onNoArchive: noArchiveTask,
                              toggleValue: toggleValue,
                              onDeleteTodos: deleteTaskTodos,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                CalendarPage(key: UniqueKey()),
              ],
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            enableDrag: false,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (BuildContext context) {
              return TaskTypeCu(
                text: 'create'.tr,
                save: () {
                  addTask();
                },
                titleEdit: titleEdit,
                descEdit: descEdit,
                color: myColor,
                pickerColor: (Color color) => setState(() => myColor = color),
              );
            },
          );
        },
        backgroundColor: context.theme.primaryColor,
        child: const Icon(
          Iconsax.add,
          color: Colors.greenAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Theme(
          data: context.theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: CustomNavigationBar(
            backgroundColor: Colors.white,
            strokeColor: const Color(0x300c18fb),
            onTap: (int index) => changeTabIndex(index),
            currentIndex: tabIndex.value,
            iconSize: 24,
            elevation: 0,
            items: [
              CustomNavigationBarItem(icon: const Icon(Iconsax.task_square)),
              CustomNavigationBarItem(icon: const Icon(Iconsax.calendar_1)),
            ],
          ),
        ),
      ),
    );
  }
}
