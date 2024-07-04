import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todark/app/data/models.dart';

class CustomDatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final TimeOfDay? initialTime;
  final DueType initialDueType;
  final Function(DateTime, TimeOfDay?, DueType) onDateTimeChanged;

  const CustomDatePickerBottomSheet({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateTimeChanged,
    this.initialTime,
    this.initialDueType = DueType.dueBy,
  }) : super(key: key);

  @override
  _CustomDatePickerBottomSheetState createState() =>
      _CustomDatePickerBottomSheetState();
}

class _CustomDatePickerBottomSheetState
    extends State<CustomDatePickerBottomSheet> {
  late DateTime selectedDate;
  TimeOfDay? selectedTime;
  int selectedDueType = 0;
  int selectedDueEvery = 0; // State for the second set of choice buttons

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
    selectedDueType = widget.initialDueType.index;
    if (widget.initialDueType.index >= 2) {
      selectedDueEvery = 1;
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _closeDialog() {
    DueType dueType = DueType.values[selectedDueType];
    widget.onDateTimeChanged(selectedDate, selectedTime, dueType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Due Type',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  _buildChoiceButton(context, 'Due By', 0, selectedDueType,
                      (index) {
                    setState(() {
                      selectedDueType = index;
                      selectedDueEvery = 0;
                    });
                  }),
                  _buildChoiceButton(context, 'Due On', 1, selectedDueType,
                      (index) {
                    setState(() {
                      selectedDueType = index;
                      selectedDueEvery = 0;
                    });
                  }),
                  _buildChoiceButton(context, 'Due Every', 1, selectedDueEvery,
                      (index) {
                    setState(() {
                      selectedDueEvery = 1;
                      selectedDueType = 2;
                    });
                  }),
                ],
              ),
            ),
            const Divider(),
            if (selectedDueEvery == 1) ...[
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Due Every',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: [
                    _buildChoiceButton(context, 'Day', 2, selectedDueType,
                        (index) {
                      setState(() {
                        selectedDueType = index;
                      });
                    }),
                    _buildChoiceButton(context, 'Week', 3, selectedDueType,
                        (index) {
                      setState(() {
                        selectedDueType = index;
                      });
                    }),
                    _buildChoiceButton(context, 'Month', 4, selectedDueType,
                        (index) {
                      setState(() {
                        selectedDueType = index;
                      });
                    }),
                  ],
                ),
              ),
              const Divider(),
            ],
            Theme(
              data: theme.copyWith(
                datePickerTheme: DatePickerThemeData(
                  weekdayStyle: theme.textTheme.bodySmall,
                  dayStyle: theme.textTheme.bodySmall,
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
                selectableDayPredicate: (date) {
                  return !date.isBefore(
                      DateTime.now().subtract(const Duration(days: 1)));
                },
              ),
            ),
            const Divider(),
            InkWell(
              onTap: _pickTime,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Set time',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _closeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: theme.textTheme.labelMedium?.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, String text, int index,
      int selectedIndex, ValueChanged<int> onSelected) {
    return ChoiceChip(
      label: Text(text),
      selected: selectedIndex == index,
      onSelected: (bool selected) {
        onSelected(selected ? index : selectedIndex);
      },
      selectedColor: Theme.of(context).chipTheme.selectedColor,
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      labelStyle: Theme.of(context).textTheme.labelMedium,
      labelPadding: const EdgeInsets.all(0),
      showCheckmark: false, // Optionally, hide the checkmark
    );
  }
}
