import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class UsersTableScreen extends StatefulWidget {
  const UsersTableScreen({super.key});

  @override
  _UsersTableScreenState createState() => _UsersTableScreenState();
}

class _UsersTableScreenState extends State<UsersTableScreen> {
  // Sample user data
  final List<UserModel> _users = [
    UserModel(
        uuid: '33',
        username: 'Alice Johnson',
        email: 'alice@example.com',
        password: "",
        isAdmin: true),
    UserModel(
        uuid: '33',
        username: 'Bob Brown',
        email: 'bob@example.com',
        password: "",
        isAdmin: true),
    UserModel(
        uuid: '33',
        username: 'Bob Brown',
        email: 'bob@example.com',
        password: "",
        isAdmin: true),
    UserModel(
        uuid: '33',
        username: 'Bob Brown',
        email: 'bob@example.com',
        password: "",
        isAdmin: true),
    UserModel(
        uuid: '33',
        username: 'Bob Brown',
        email: 'bob@example.com',
        password: "",
        isAdmin: true),
    UserModel(
        uuid: '33',
        username: 'Bob Brown',
        email: 'bob@example.com',
        password: "",
        isAdmin: true)
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.username)),
                DataCell(Text(user.email)),
                DataCell(Text('Admin')),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Add edit functionality here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Add delete functionality here
                        setState(() {
                          _users.remove(user);
                        });
                      },
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
