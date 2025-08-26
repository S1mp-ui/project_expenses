import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() async {
  print("===Login===");

  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  if (username == null || username.isEmpty) {
    print("please put your name");
    return;
  }

  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (password == null || password.isEmpty) {
    print("please put your password");
    return;
  }

  // ===== LOGIN =====
  var loginRes = await http.post(
    Uri.parse('http://localhost:3000/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({'username': username, 'password': password}),
  );

  print("Insert done");

  var loginData = jsonDecode(loginRes.body);

  int userId = loginData['user_id'];

  // ===== MENU =====
  while (true) {
    print("\n===Expenses Tracking App===");
    print(
      "1. Show All Expenses"
      "\n2. Today's Expenses"
      "\n3. Search Expenses"
      "\n4. Add new Expenses"
      "\n5. Delete an Expenses"
      "\n6. Exit",
    );

    stdout.write("Choose... ");
    String? choice = stdin.readLineSync()?.trim();
    if (choice == null || choice.isEmpty) {
      print("please choose a number");
      return;
    }

    //===Choice 1===

    if (choice == "1") {
      // ===== GET ALL EXPENSES =====
      var res = await http.get(
        Uri.parse('http://localhost:3000/expenses?user_id=$userId'),
      );

      List<dynamic> data = jsonDecode(res.body);

      print("===All Expenses===");
      for (int i = 0; i < data.length; i++) {
        var row = data[i];
        var d = DateTime.parse(row['date']).toLocal();

        String formattedDate =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
            "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}";

        print("${i + 1}. ${row["item"]} : ${row["paid"]}฿ : $formattedDate");
      }

      num total = 0;
      for (var item in data) {
        total += item['paid'];
      }
      print("Total: $total ฿");
    }
    //===Choice 2===
    else if (choice == "2") {
      var res = await http.get(
        Uri.parse('http://localhost:3000/expenses/today/$userId'),
      );
      List<dynamic> data = jsonDecode(res.body);
      print("===Today's Expenses===");
      for (int i = 0; i < data.length; i++) {
        var row = data[i];

        var d = DateTime.parse(row['date']).toLocal();
        String formattedDate =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
            "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}";

        print("${i + 1}. ${row["item"]} : ${row["paid"]}฿ : $formattedDate");
      }
      num total = 0;
      for (var item in data) {
        total += item['paid'];
      }
      print("Total: $total ฿");
    }
    ////===Choice 3=== Search Expenses ====
    else if (choice == "3") {
      stdout.write('\nEnter search term: ');
      String? search = stdin.readLineSync();
      if (search == null || search.isEmpty) {
        print('Invalid input.\n');
        continue;
      }

      var res = await http.get(
        Uri.parse('http://localhost:3000/expenses?user_id=$userId'),
      );
      List<dynamic> data = jsonDecode(res.body);

      String searchLower = search.toLowerCase();

      var results = data
          .where(
            (e) => e['item'].toString().toLowerCase().contains(searchLower),
          )
          .toList();

      if (results.isEmpty) {
        print('No matching expenses found.\n');
      } else {
        print('Search Results:');
        for (var e in results) {
          print('${e['item']}: ${e['paid']} ฿');
        }
        print('');
      }
    }
    //===Choice 4=== Add new Expenses ====
    //===Choice 5=== Delete an Expenses ====
    //===Choice 6===
    else if (choice == "6") {
      print("Good Bye");
      break;
    }
  }
}
