import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rest_api_flutter/Model/postModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<postModel> postList = [];

  Future<List<postModel>> getPost() async {
    final response =
        await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (var i in data) {
        postList.add(postModel.fromJson(i as Map<String, dynamic>));
      }
      return postList;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Fetching Data",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: homescreen(getPost: getPost), // Pass the getPost function
      ),
    );
  }
}

class homescreen extends StatefulWidget {
  final Future<List<postModel>> Function() getPost; // Receive the function as a parameter
  const homescreen({super.key, required this.getPost});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: widget.getPost(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      width: size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Text("Loading"),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Prevents scroll conflicts with SingleChildScrollView
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var post = snapshot.data[index]; // Use snapshot data
                      return Container(
                        width: size.width * 0.8,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.all(
                            Radius.circular(30), // Rounded corners
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "UID: ${post.userId}", // Display ID from snapshot data
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "ID: ${post.id}", // Display ID from snapshot data
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Title: ${post.title}", // Display Title
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Body: ${post.body}", // Display Body
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text("No data found"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
