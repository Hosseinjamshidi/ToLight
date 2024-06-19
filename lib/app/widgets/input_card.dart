import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputCard extends StatelessWidget {
  const InputCard({
    super.key,
    required this.icon,
    required this.text,
    this.sliderValue,
    this.onSliderChange,
    this.numberController,
    this.onNumberChange,
    this.onIncrement,
    this.onDecrement,
    this.switchValue,
    this.onSwitchChange,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChange,
    this.minSliderValue = 0,
    this.maxSliderValue = 100,
    this.divisions,
    this.numberInput = false,
    this.sliderInput = false,
    this.switchInput = false,
    this.dropdownInput = false,
  });

  final Widget icon;
  final String text;
  final double? sliderValue;
  final Function(double)? onSliderChange;
  final TextEditingController? numberController;
  final Function(String)? onNumberChange;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool? switchValue;
  final Function(bool)? onSwitchChange;
  final String? dropdownValue;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final Function(String?)? onDropdownChange;
  final double minSliderValue;
  final double maxSliderValue;
  final int? divisions;
  final bool numberInput;
  final bool sliderInput;
  final bool switchInput;
  final bool dropdownInput;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            leading: icon,
            title: Text(
              text,
              style: context.textTheme.labelLarge,
              overflow: TextOverflow.visible,
            ),
            trailing: numberInput
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: constraints.maxWidth * 0.15,
                        child: TextFormField(
                          controller: numberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                          ),
                          onChanged: onNumberChange,
                        ),
                      ),
                      IconButton(
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                : sliderInput
                    ? SizedBox(
                        width: constraints.maxWidth * 0.60,
                        child: Slider(
                          value: sliderValue ?? 0,
                          min: minSliderValue,
                          max: maxSliderValue,
                          divisions: divisions,
                          label: sliderValue?.toString(),
                          onChanged: onSliderChange,
                        ),
                      )
                    : switchInput
                        ? Switch(
                            value: switchValue ?? false,
                            onChanged: onSwitchChange,
                          )
                        : dropdownInput
                            ? DropdownButton<String>(
                                underline: Container(),
                                value: dropdownValue,
                                items: dropdownItems,
                                onChanged: onDropdownChange,
                              )
                            : Container(),
          );
        },
      ),
    );
  }
}
