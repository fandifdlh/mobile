import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter fandi fadillah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FuturePage(),
    );
  }
}

class FuturePage extends StatefulWidget {
  const FuturePage({super.key});

  @override
  State<FuturePage> createState() => _FuturePageState();
}

class _FuturePageState extends State<FuturePage> {
  String result = '';

  // Method to get data from Google Books API
  Future<void> getData() async {
    const authority = 'www.googleapis.com';
    const path = '/books/v1/volumes/MpzyEAAAQBAJ'; // Example book ID
    Uri url = Uri.https(authority, path);
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          result = data['items'][0]['volumeInfo']['title'];  // Extracting title of the book
        });
      } else {
        setState(() {
          result = 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('back from the future'),
      ),
      body: Center(
        child: Column(children: [
          const Spacer(),
          ElevatedButton(
            child: const Text("GO!"),
            onPressed: () async {
              await getData();  // Call the getData function when button is pressed
            },
          ),
          const Spacer(),
          Text(result),
          const Spacer(),
          const CircularProgressIndicator(),
          const Spacer(),
        ]),
      ),
    );
  }
}
