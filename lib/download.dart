//* Example of how to download data from the internet

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Download extends StatefulWidget {
  const Download({super.key});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  String cifkey = "Loading";
  String name = "Loading";
  Future<void> _fetchData() async {
    final output = await http.post(
      Uri.parse("http://192.168.1.36:3000/api/members/address"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"municipality": "UBAY", "barangay": "GABI"}),
    );
    List<dynamic> data = jsonDecode(output.body);
    // ignore: avoid_print
    print(data[0]);
    setState(() {
      cifkey = data[0]["CIFKey"];
      name = data[0]["MemberName"];
    });
    // Fetch data from the internet
  }

  Future<void> _deleteData() async {
    setState(() {
      cifkey = "Loading";
      name = "Loading";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _fetchData();
                },
                child: Text("Add"),
              ),
              Padding(padding: EdgeInsets.all(10)),
              ElevatedButton(
                onPressed: () {
                  _deleteData();
                },
                child: Text("Delete"),
              ),
              Padding(padding: EdgeInsets.all(10)),
            ],
          ),
          Text("CIFKey: $cifkey"),
          Text("Name: $name"),
        ],
      ),
    );
  }
}
