import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todark/app/data/models.dart';
import 'package:todark/app/controller/todo_controller.dart';
import 'package:todark/app/widgets/input_card.dart';
import 'package:todark/app/widgets/custom_date_picker_bottom_sheet.dart';
import 'package:todark/app/widgets/text_form.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todark/main.dart';

class TodosAction extends StatefulWidget {
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.category,
    this.task,
    this.todo,
  });
  final String text;
  final Tasks? task;
  final Todos? todo;
  final bool edit;
  final bool category;

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction> {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Tasks? selectedTask;
  final FocusNode focusNode = FocusNode();
  int priority = 3;
  double _currentValue = 1.0;
  TextEditingController durationController = TextEditingController();
  bool _isFeatureEnabled = false;
  String _selectedCategory = 'Work';
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  DueType _selectedDueType = DueType.dueBy;
  String _dueDateText = 'Set Due Date';

  final List<DropdownMenuItem<String>> _dropdownItems = [
    const DropdownMenuItem(
      value: 'Work',
      child: Text('Work'),
    ),
    const DropdownMenuItem(
      value: 'Personal',
      child: Text('Personal'),
    ),
    const DropdownMenuItem(
      value: 'Other',
      child: Text('Other'),
    ),
  ];

  Future<void> _pickDate() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CustomDatePickerBottomSheet(
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2101),
          initialTime: _selectedTime,
          initialDueType: _selectedDueType,
          onDateTimeChanged: (date, time, dueType) {
            setState(() {
              _selectedDate = date;
              _selectedTime = time;
              _selectedDueType = dueType;
              _updateDueDateText();
            });
          },
        );
      },
    );
  }

  void _updateDueDateText() {
    if (_selectedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      String? formattedTime;
      if (_selectedTime != null) {
        final now = DateTime.now();
        final DateTime formattedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        formattedTime = DateFormat.Hm().format(formattedDateTime);
      }

      String formattedTimePart =
          formattedTime != null ? ' at $formattedTime' : '';

      switch (_selectedDueType) {
        case DueType.dueBy:
          _dueDateText = 'Due by $formattedDate$formattedTimePart';
          break;
        case DueType.dueOn:
          _dueDateText = 'Due on $formattedDate$formattedTimePart';
          break;
        case DueType.dueEveryDay:
          _dueDateText = 'Due every day$formattedTimePart';
          break;
        case DueType.dueEveryWeek:
          _dueDateText =
              'Due every ${DateFormat('EEEE').format(_selectedDate!)}$formattedTimePart';
          break;
        case DueType.dueEveryMonth:
          final dayOfMonth = DateFormat('d').format(_selectedDate!);
          _dueDateText = 'Due every $dayOfMonth of the month$formattedTimePart';
          break;
        default:
          _dueDateText = 'Set Due Date';
      }

      todoController.timeTodoEdit.text = _dueDateText;
    } else {
      _dueDateText = 'Set Due Date';
    }
  }

  @override
  void initState() {
    if (widget.edit) {
      selectedTask = todoController.tasks
          .firstWhereOrNull((task) => task.id == widget.todo!.taskId);
      todoController.textTodoConroller.text = selectedTask?.title ?? '';
      todoController.titleTodoEdit =
          TextEditingController(text: widget.todo!.name);
      todoController.descTodoEdit =
          TextEditingController(text: widget.todo!.description);
      todoController.timeTodoEdit = TextEditingController(
          text: widget.todo!.todoCompletedTime != null
              ? timeformat == '12'
                  ? DateFormat.yMMMEd(locale.languageCode)
                      .add_jm()
                      .format(widget.todo!.todoCompletedTime!)
                  : DateFormat.yMMMEd(locale.languageCode)
                      .add_Hm()
                      .format(widget.todo!.todoCompletedTime!)
              : '');
      priority = widget.todo!.priority;
      _currentValue = widget.todo!.duration;
      _selectedDate = widget.todo!.todoCompletedTime;
      _selectedDueType = widget.todo!.dueType;
      _updateDueDateText();
    }
    durationController.text = _currentValue.toStringAsFixed(1);
    super.initState();
  }

  @override
  void dispose() {
    todoController.textTodoConroller.clear();
    todoController.titleTodoEdit.clear();
    todoController.descTodoEdit.clear();
    todoController.timeTodoEdit.clear();
    super.dispose();
  }

  Future<List<Tasks>> getTaskAll(String pattern) async {
    List<Tasks> getTask = await todoController.getTasks();
    return getTask.where((element) {
      final title = element.title.toLowerCase();
      final query = pattern.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains('  ')) {
      value.text = value.text.replaceAll('  ', ' ');
    }
  }

  void _increment() {
    setState(() {
      _currentValue += 0.5;
      durationController.text = _currentValue.toStringAsFixed(1);
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue >= 1) {
        _currentValue -= 0.5;
        durationController.text = _currentValue.toStringAsFixed(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (todoController.titleTodoEdit.text.length >= 40 ||
                            todoController.descTodoEdit.text.length >= 40) {
                          await showAdaptiveDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog.adaptive(
                                title: Text(
                                  'clearText'.tr,
                                  style: context.textTheme.titleLarge,
                                ),
                                content: Text('clearTextWarning'.tr,
                                    style: context.textTheme.titleMedium),
                                actions: [
                                  TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text('cancel'.tr,
                                          style: context
                                              .theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  color: Colors.blueAccent))),
                                  TextButton(
                                      onPressed: () {
                                        todoController.titleTodoEdit.clear();
                                        todoController.descTodoEdit.clear();
                                        todoController.timeTodoEdit.clear();
                                        todoController.textTodoConroller
                                            .clear();
                                        Get.back(result: true);
                                        Get.back();
                                      },
                                      child: Text('delete'.tr,
                                          style: context
                                              .theme.textTheme.titleMedium
                                              ?.copyWith(color: Colors.red))),
                                ],
                              );
                            },
                          );
                        } else {
                          todoController.titleTodoEdit.clear();
                          todoController.descTodoEdit.clear();
                          todoController.timeTodoEdit.clear();
                          todoController.textTodoConroller.clear();
                          Get.back();
                        }
                      },
                      icon: const Icon(
                        Iconsax.close_square,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.text,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.edit
                            ? IconButton(
                                onPressed: () {
                                  todoController.updateTodoFix(widget.todo!);
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Iconsax.attach_square,
                                  size: 20,
                                ),
                              )
                            : const Offstage(),
                        IconButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              textTrim(todoController.titleTodoEdit);
                              textTrim(todoController.descTodoEdit);
                              widget.edit
                                  ? todoController.updateTodo(
                                      widget.todo!,
                                      selectedTask!,
                                      todoController.titleTodoEdit.text,
                                      todoController.descTodoEdit.text,
                                      todoController.timeTodoEdit.text,
                                      priority,
                                    )
                                  : widget.category
                                      ? todoController.addTodo(
                                          selectedTask!,
                                          todoController.titleTodoEdit.text,
                                          todoController.descTodoEdit.text,
                                          todoController.timeTodoEdit.text,
                                          priority,
                                        )
                                      : todoController.addTodo(
                                          widget.task!,
                                          todoController.titleTodoEdit.text,
                                          todoController.descTodoEdit.text,
                                          todoController.timeTodoEdit.text,
                                          priority,
                                        );
                              todoController.textTodoConroller.clear();
                              todoController.titleTodoEdit.clear();
                              todoController.descTodoEdit.clear();
                              todoController.timeTodoEdit.clear();
                              Get.back();
                            }
                          },
                          icon: const Icon(
                            Iconsax.tick_square,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                controller: todoController.titleTodoEdit,
                labelText: 'name'.tr,
                type: TextInputType.multiline,
                icon: const Icon(Iconsax.edit_2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateName'.tr;
                  }
                  return null;
                },
                maxLine: null,
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                controller: todoController.descTodoEdit,
                labelText: 'description'.tr,
                type: TextInputType.multiline,
                icon: const Icon(Iconsax.note_text),
                maxLine: null,
              ),
              widget.category
                  ? RawAutocomplete<Tasks>(
                      focusNode: focusNode,
                      textEditingController: todoController.textTodoConroller,
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        return MyTextForm(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          controller: todoController.textTodoConroller,
                          focusNode: focusNode,
                          labelText: 'selectCategory'.tr,
                          type: TextInputType.text,
                          icon: const Icon(Iconsax.folder_2),
                          iconButton: todoController
                                  .textTodoConroller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    todoController.textTodoConroller.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'selectCategory'.tr;
                            }
                            return null;
                          },
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Tasks>.empty();
                        }
                        return getTaskAll(textEditingValue.text);
                      },
                      onSelected: (Tasks selection) {
                        todoController.textTodoConroller.text = selection.title;
                        selectedTask = selection;
                        focusNode.unfocus();
                      },
                      displayStringForOption: (Tasks option) => option.title,
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<Tasks> onSelected,
                          Iterable<Tasks> options) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 4.0,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Tasks tasks = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(tasks),
                                    child: ListTile(
                                      title: Text(
                                        tasks.title,
                                        style: context.textTheme.labelLarge,
                                      ),
                                      trailing: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(tasks.taskColor),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                readOnly: true,
                controller: todoController.timeTodoEdit,
                labelText: 'timeComplete'.tr,
                type: TextInputType.datetime,
                icon: const Icon(Iconsax.clock),
                iconButton: todoController.timeTodoEdit.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onPressed: () {
                          todoController.timeTodoEdit.clear();
                          setState(() {
                            _dueDateText = 'Set Due Date';
                          });
                        },
                      )
                    : null,
                onTap: _pickDate,
              ),
              InputCard(
                icon: const Icon(Iconsax.slider_vertical),
                text: 'Priority',
                sliderInput: true,
                sliderValue: priority.toDouble(),
                minSliderValue: 1,
                maxSliderValue: 5,
                divisions: 4,
                onSliderChange: (value) {
                  setState(() {
                    priority = value.toInt();
                  });
                },
              ),
              InputCard(
                icon: const Icon(Iconsax.timer),
                text: 'Task Duration',
                numberInput: true,
                numberController: durationController,
                onNumberChange: (value) {
                  setState(() {
                    _currentValue = double.tryParse(value) ?? _currentValue;
                  });
                },
                onIncrement: _increment,
                onDecrement: _decrement,
              ),
              InputCard(
                icon: const Icon(Iconsax.toggle_on),
                text: 'Enable Feature',
                switchInput: true,
                switchValue: _isFeatureEnabled,
                onSwitchChange: (value) {
                  setState(() {
                    _isFeatureEnabled = value;
                  });
                },
              ),
              InputCard(
                icon: const Icon(Iconsax.folder),
                text: 'Category',
                dropdownInput: true,
                dropdownValue: _selectedCategory,
                dropdownItems: _dropdownItems,
                onDropdownChange: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
