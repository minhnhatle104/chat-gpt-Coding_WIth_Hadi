import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../models/chat_model.dart';
import '../models/models_model.dart';
import '../constants/api_consts.dart';
import "../secret/config.dart";

import "package:http/http.dart" as http;

class ApiService {
  // get model
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {
          'Authorization': 'Bearer ${Config.apiKey}',
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

  // Send Message
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    // log(modelId);
    try {
      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer ${Config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {"model": modelId, "prompt": message, "max_tokens": 100},
        ),
      );
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse["error"] != null) {
        log("jsonResponse['error'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse["error"]["message"]);
      }

      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse['choices']['text'] ${jsonResponse['choices'][0]['text']}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse['choices'][index]['text'],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
