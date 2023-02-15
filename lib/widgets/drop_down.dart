import '../constants/constants.dart';
import 'package:flutter/material.dart';

class ModelSDropDownWidget extends StatefulWidget {
  const ModelSDropDownWidget({super.key});

  @override
  State<ModelSDropDownWidget> createState() => _ModelSDropDownWidgetState();
}

class _ModelSDropDownWidgetState extends State<ModelSDropDownWidget> {
  String currentModel = "Model1";

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      dropdownColor: scaffoldBackgroundColor,
      iconEnabledColor: Colors.white,
      items: getModelsItem,
      value: currentModel,
      onChanged: (value) {
        setState(() {
          currentModel = value.toString();
        });
      },
    );
  }
}
