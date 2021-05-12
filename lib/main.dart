import 'package:crud/Student.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Records',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        backgroundColor: Colors.blueGrey
      ),
      darkTheme: ThemeData.dark(),
      //   (
      //   primarySwatch: Colors.purple,
      //   scaffoldBackgroundColor: Colors.black26,
      //   primaryColor: Colors.white70
      // ),
      home: MyHomePage(title: 'Student Record Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name;
  String email;
  int age;
  bool update = false;
  int updateIndex = 0;
  List<Student> students = [];

  Uri getUri(int id) {
    if (id != 0) {
      return Uri.http('192.168.2.10:8080', '/api/student/' + id.toString() + '/');
    } else {
      return Uri.http('192.168.2.10:8080', '/api/student/');
    }
  }

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudent().then((value) {
      setState(() {
        students = value;
      });
    });
  }

  Future<List<Student>> fetchStudent() async {
    var response = await http.get(getUri(0));
    List<dynamic> jsondata = jsonDecode(response.body);
    List<Student> temp = [];
    jsondata.forEach((student) {
      // print(student);
      temp.add(new Student.fromJson(student));
    });

    return temp;
  }

  void loadData(Student student){
    updateIndex = student.id;
    update = true;
    nameController.text = student.name;
    name = student.name;
    emailController.text = student.email;
    email = student.email;
    ageController.text = student.age.toString();
    age = student.age;
  }

  void deleteStudent(int sid) async {
    String studentId = sid.toString();
    var res = await http.delete(
      Uri.parse('http://192.168.2.10:8080/api/student/$studentId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print(res);

    fetchStudent().then((value) {
      setState(() {
        students = value;
      });
    });
  }

  void addStudent(int studentId) async {
    Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "age": age
    };

    print(data);

    if(update == true){
      update = false;
      updateIndex = 0;
      var res = await http.put(
        getUri(studentId),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        fetchStudent().then((value) {
          setState(() {
            students = value;
          });
        });
      } else {
        print("Error while updating student information");
      }
    }
    else {
      var res = await http.post(
        getUri(0),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 201) {
        fetchStudent().then((value) {
          setState(() {
            students = value;
          });
        });
      } else {
        print("Error while inserting new student");
      }
    }

    nameController.clear();
    emailController.clear();
    ageController.clear();
  }

  Widget createTable(List<Student> students) {
    List<TableRow> rows = [];

    rows.add(
        TableRow(decoration: BoxDecoration(color: Colors.black26), children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Name", textScaleFactor: 1),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Action", textScaleFactor: 1),
      ),
    ]));

    for (Student s in students) {
      rows.add(TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(s.name, textScaleFactor: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove_red_eye_rounded),
                    onPressed: () => {showAlertDialog(context, s)}),
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      loadData(s);
                    }),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: (){
                      print(s.name);
                      deleteStudent(s.id);}),
              ],
            ),
          ),
        ],
      ));
    }

    return Table(
        border: TableBorder.all(width: 2.0, color: Colors.red), children: rows);
  }

  showAlertDialog(BuildContext context, Student sob) {
    var content_val = "Email: ";
    content_val += sob.email;
    content_val += "\nAge: ";
    content_val += sob.age.toString();

    AlertDialog alert = AlertDialog(
      title: Text(sob.name + "'s Details"),
      content: Text(content_val),
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"))
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "Enter your name"),
                    onChanged: (text) {
                      name = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Enter your email"),
                    onChanged: (text) {
                      email = text;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: ageController,
                    decoration: InputDecoration(hintText: "Enter your age"),
                    onChanged: (text) {
                      age = int.parse(text);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      child: Text('Submit'),
                      onPressed: (){
                        if(update == true){
                          addStudent(updateIndex);
                        }
                        else{
                          addStudent(0);
                        }
                      },
                    ),
                    RaisedButton(
                      child: Text('Clear'),
                      onPressed: (){
                        update = false;
                        nameController.text = "";
                        emailController.text = "";
                        ageController.text = "";
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: createTable(students),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
