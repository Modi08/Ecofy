import 'dart:convert';
import 'dart:developer' as developer;
import 'package:ecofy/services/general/localstorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectToWebsocket(String paramsApiUrl) {
  developer.log("Connected to WebSocket", name: 'WebSocket');
  final socket = WebSocketChannel.connect(Uri.parse(paramsApiUrl));
  return socket;
}

void listendMsg(
    WebSocketChannel socket, DatabaseService database, String userId) {
  socket.stream.listen(
    (data) {
      try {
        final parsedData = jsonDecode(data);
        developer.log("Message received", name: 'WebSocket', error: parsedData);

        if (parsedData.containsKey("data")) {
          final res = parsedData["data"];
          processMsg(res["statusCode"], res, socket, database, userId);
        } else {
          developer.log("Message does not contain 'data'",
              name: 'WebSocket', error: parsedData);
        }
      } catch (e) {
        developer.log("Error parsing WebSocket message",
            name: 'WebSocket', error: e);
      }
    },
    onError: (error) {
      developer.log("WebSocket error", name: 'WebSocket', error: error);
    },
    onDone: () {
      developer.log("WebSocket connection closed", name: 'WebSocket');
    },
  );
}

void processMsg(int statusCode, Map<String, dynamic> data,
    WebSocketChannel socket, DatabaseService database, String userId) {
  developer.log("Processing message", name: 'WebSocket', error: statusCode);
  print(statusCode);
  switch (statusCode) {
    case 100: // No Return Value
      break;
    case 200: // No Relevant Return Value
      developer.log("Success", name: 'WebSocket', error: data["msg"]);
      break;
    case 201:
      List<Map<String, dynamic>> allUsers = jsonDecode(data["allUsers"])
          .whereType<Map<String, dynamic>>()
          .toList();

      // Clear outdated data
      database.clearAllExecpt(
          userId); // Add a method in DatabaseService to clear all data

      for (int index = 0; index < allUsers.length; index++) {
        database.replace(allUsers[index]);
      }
      break;
    default:
      developer.log("Unhandled statusCode",
          name: 'WebSocket', error: {"statusCode": statusCode, "data": data});
      break;
  }
}
