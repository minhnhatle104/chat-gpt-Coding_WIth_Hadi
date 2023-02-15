import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../models/models_model.dart';

import '../constants/api_consts.dart';
import "package:http/http.dart" as http;

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      );
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse["error"] != null) {
        log("jsonResponse['error'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse["error"]["message"]);
      }
      // log("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp $value");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
