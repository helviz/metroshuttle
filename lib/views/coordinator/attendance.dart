import 'package:flutter/material.dart';

class ChildArrivalTable extends StatefulWidget {
  @override
  _ChildArrivalTableState createState() => _ChildArrivalTableState();
}

class _ChildArrivalTableState extends State<ChildArrivalTable> {
  List<Child> _children = [
    Child(name: 'John Doe', parentName: 'Jane Doe', phoneNumber: '123-456-7890'),
    Child(name: 'Jane Smith', parentName: 'Bob Smith', phoneNumber: '098-765-4321'),
    Child(name: 'Bob Johnson', parentName: 'Mary Johnson', phoneNumber: '555-123-4567'),
  ];

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Child\'s Name')),
        DataColumn(label: Text('Parent\'s Name')),
        DataColumn(label: Text('Phone Number')),
        DataColumn(label: Text('Arrived')),
        DataColumn(label: Text('Departed')),
      ],
      rows: _children.map((child) {
        return DataRow(
          cells: [
            DataCell(Text(child.name)),
            DataCell(Text(child.parentName)),
            DataCell(Text(child.phoneNumber)),
            DataCell(
              Checkbox(
                value: child.arrived,
                onChanged: (value) {
                  setState(() {
                    child.arrived = value!;
                  });
                },
              ),
            ),
            DataCell(
              Checkbox(
                value: child.departed,
                onChanged: (value) {
                  setState(() {
                    child.departed = value!;
                  });
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class Child {
  String name;
  String parentName;
  String phoneNumber;
  bool arrived;
  bool departed;

  Child({required this.name, required this.parentName, required this.phoneNumber, this.arrived = false, this.departed = false});
}