import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:farmers_activity_prediction/utils/constants.dart';

class APIService with ChangeNotifier {
  static Future<String> uploadPicture(File imageFile) async {
    Uri url = Uri.parse(uploadImage);
    String base64file = base64Encode(imageFile.readAsBytesSync());
    String fileName = imageFile.path.split("/").last;
    Map headerData = {};
    headerData['name'] = fileName;
    headerData['file'] = base64file;

    http.Response response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(headerData),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      return data["desc"];
    } else {
      return "Error";
    }
  }
}
