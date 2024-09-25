import 'dart:convert';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x51/models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.light(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Users> userList = [];
  late List<ExpandableColumn<dynamic>> headers;
  late List<ExpandableRow> rows;

  bool _isLoading = true;

  void setLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    userList = generateUsers(10);
    createDataSource();
    setLoading();
  }

  List<Users> generateUsers(int count) {
    var faker = Faker();
    List<Users> users = [];

    for (int i = 0; i < count; i++) {
      // Randomly assign gender
      String gender = faker.randomGenerator.element(['male', 'female']);

      users.add(Users(
        id: i + 1,
        firstName: faker.person.firstName(),
        lastName: faker.person.lastName(),
        maidenName: gender == 'female' ? faker.person.lastName() : '',
        age: faker.randomGenerator.integer(80, min: 18),
        // Random age between 18 and 80
        gender: gender,
        email: faker.internet.email(),
      ));
    }

    return users;
  }

  void createDataSource() {
    headers = [
      ExpandableColumn<int>(columnTitle: "ID", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "First name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Last name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Maiden name", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "Age", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 4),
    ];

    rows = userList.map<ExpandableRow>((e) {
      return ExpandableRow(cells: [
        ExpandableCell<int>(columnTitle: "ID", value: e.id),
        ExpandableCell<String>(columnTitle: "First name", value: e.firstName),
        ExpandableCell<String>(columnTitle: "Last name", value: e.lastName),
        ExpandableCell<String>(columnTitle: "Maiden name", value: e.maidenName),
        ExpandableCell<int>(columnTitle: "Age", value: e.age),
        ExpandableCell<String>(columnTitle: "Gender", value: e.gender),
        ExpandableCell<String>(columnTitle: "Email", value: e.email),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_isLoading
            ? LayoutBuilder(builder: (context, constraints) {
                int visibleCount = 3;
                if (constraints.maxWidth < 600) {
                  visibleCount = 3;
                } else if (constraints.maxWidth < 800) {
                  visibleCount = 4;
                } else if (constraints.maxWidth < 1000) {
                  visibleCount = 5;
                } else {
                  visibleCount = 7;
                }

                return ExpandableTheme(
                  data: ExpandableThemeData(
                    context,
                    contentPadding: const EdgeInsets.all(20),
                    expandedBorderColor: Colors.transparent,
                    paginationSize: 48,
                    headerHeight: 56,
                    headerColor: Colors.amber[400],
                    headerBorder: const BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    evenRowColor: Colors.red,
                    oddRowColor: Colors.amber[200],
                    rowBorder: const BorderSide(
                      color: Colors.black,
                      width: 0.3,
                    ),
                    rowColor: Colors.green,
                    headerTextMaxLines: 4,
                    headerSortIconColor: Colors.green,
                    paginationSelectedFillColor: Colors.blue,
                    paginationSelectedTextColor: Colors.white,
                  ),
                  child: ExpandableDataTable(
                    headers: headers,
                    rows: rows,
                    multipleExpansion: false,
                    isEditable: false,
                    onRowChanged: (newRow) {
                      print(newRow.cells[01].value);
                    },
                    onPageChanged: (page) {
                      print(page);
                    },
                    renderEditDialog: (row, onSuccess) =>
                        _buildEditDialog(row, onSuccess),
                    visibleColumnCount: visibleCount,
                  ),
                );
              })
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEditDialog(
      ExpandableRow row, Function(ExpandableRow) onSuccess) {
    return AlertDialog(
      title: SizedBox(
        height: 300,
        child: TextButton(
          child: const Text("Change name"),
          onPressed: () {
            row.cells[1].value = "x3";
            onSuccess(row);
          },
        ),
      ),
    );
  }
}

class Users {
  final int id;
  final String firstName;
  final String lastName;
  final String maidenName;
  final int age;
  final String gender;
  final String email;

  Users({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.maidenName,
    required this.age,
    required this.gender,
    required this.email,
  });

  // Optional: A factory constructor to create a User from a JSON map (useful if you're working with APIs)
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      maidenName: json['maidenName'],
      age: json['age'],
      gender: json['gender'],
      email: json['email'],
    );
  }

  // Optional: A method to convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'maidenName': maidenName,
      'age': age,
      'gender': gender,
      'email': email,
    };
  }
}
