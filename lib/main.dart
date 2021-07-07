import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqltest/database/databaseConfig.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Sql Example', theme: ThemeData(primarySwatch: Colors.blue), home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List usersData = [];
  bool noData = false;
  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: noData
          ? Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('connect to internet'), MaterialButton(onPressed: getDataFromApi, child: Text('Refresh'), color: Colors.grey)],
              ),
            )
          : usersData == null || usersData.length == 0
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(child: Text(usersData[index]['id'].toString())),
                    title: Text("${usersData[index]['name'].toString()}  -- ${usersData[index]['username'].toString()} "),
                    subtitle: Text(usersData[index]['email'].toString()),
                  ),
                  itemCount: usersData.length,
                ),
    );
  }

  getDataFromApi() async {
    DataBaseHelper data = DataBaseHelper();
    data.createDb();
    late http.Response response;
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
        if (response.statusCode == 200) await data.putDataInDataBase(jsonDecode(response.body));
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("connect to internet for new data")));
    } finally {
      var data1 = await data.getDataFromDataBase();
      if (data1.length == 0) {
        setState(() => noData = true);
      } else {
        setState(() {
          usersData = data1;
          noData = false;
        });
      }
    }
  }
}
