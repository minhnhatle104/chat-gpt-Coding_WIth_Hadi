import '../models/models_model.dart';

import '../services/api_services.dart';
import '../widgets/text_widget.dart';

import '../constants/constants.dart';
import 'package:flutter/material.dart';

class ModelSDropDownWidget extends StatefulWidget {
  const ModelSDropDownWidget({super.key});

  @override
  State<ModelSDropDownWidget> createState() => _ModelSDropDownWidgetState();
}

class _ModelSDropDownWidgetState extends State<ModelSDropDownWidget> {
  String currentModel = "text-davinci-003";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModelsModel>>(
      future: ApiService.getModels(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextWidget(
              label: snapshot.error.toString(),
            ),
          );
        }
        return snapshot.data == null || snapshot.data!.isEmpty
            ? const SizedBox.shrink()
            : FittedBox(
                child: DropdownButton(
                  dropdownColor: scaffoldBackgroundColor,
                  iconEnabledColor: Colors.white,
                  items: List<DropdownMenuItem<String>>.generate(
                    snapshot.data!.length,
                    (index) => DropdownMenuItem(
                      value: snapshot.data![index].id,
                      child: TextWidget(
                        label: snapshot.data![index].id,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  value: currentModel,
                  onChanged: (value) {
                    setState(() {
                      currentModel = value.toString();
                    });
                  },
                ),
              );
      },
    );
  }
}
