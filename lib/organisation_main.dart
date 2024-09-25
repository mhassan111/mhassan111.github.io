import 'package:flutter/material.dart';

void main() {
  runApp(OrgLocationsApp());
}

class OrgLocationsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add Organizations with Locations'),
        ),
        body: OrgLocationsForm(),
      ),
    );
  }
}

class OrgLocationsForm extends StatefulWidget {
  @override
  _OrgLocationsFormState createState() => _OrgLocationsFormState();
}

class _OrgLocationsFormState extends State<OrgLocationsForm> {
  // List to store organizations and their locations
  List<OrganizationTest> _organizations = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Button to add a new organization
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _organizations.add(OrganizationTest(name: '', locations: []));
                });
              },
              child: Text('Add Organization'),
            ),
            SizedBox(height: 16),

            // List of organization forms
            ..._organizations.asMap().entries.map((entry) {
              int orgIndex = entry.key;
              OrganizationTest org = entry.value;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Text field for organization name
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Organization Name'),
                        onChanged: (value) {
                          setState(() {
                            org.name = value;
                          });
                        },
                        initialValue: org.name,
                      ),
                      SizedBox(height: 16),

                      // List of location text fields
                      ...org.locations.asMap().entries.map((locEntry) {
                        int locIndex = locEntry.key;
                        String location = locEntry.value;

                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Location'),
                                onChanged: (value) {
                                  setState(() {
                                    org.locations[locIndex] = value;
                                  });
                                },
                                initialValue: location,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  org.locations.removeAt(locIndex);
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),

                      // Button to add new location to organization
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              org.locations.add('');
                            });
                          },
                          child: Text('Add Location'),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Remove organization button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _organizations.removeAt(orgIndex);
                            });
                          },
                          child: Text('Remove Organization'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 24),

            // Submit button to process all organizations
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform submission logic, for now, just print the values
                  _organizations.forEach((org) {
                    print('Organization: ${org.name}');
                    print('Locations: ${org.locations}');
                  });
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Organization model to store name and locations
class OrganizationTest {
  String name;
  List<String> locations;

  OrganizationTest({required this.name, required this.locations});
}
