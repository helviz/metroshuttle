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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(
            label: Container(
              width: 150,
              child: Text('Child\'s Name'),
            ),
          ),
          DataColumn(
            label: Text('Arrived'),
          ),
          DataColumn(
            label: Text('Departed'),
          ),
          DataColumn(
            label: Container(
              width: 200,
              child: Text('Parent\'s Name'),
            ),
          ),
          DataColumn(
            label: Container(
              width: 150,
              child: Text('Phone Number'),
            ),
          ),
        ],
        rows: _children.map((child) {
          return DataRow(
            cells: [
              DataCell(Text(child.name)),
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
              DataCell(Text(child.parentName)),
              DataCell(Text(child.phoneNumber)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class Child {
  String name;
  String parentName;
  String phoneNumber;
  bool arrived;
  bool departed;

  Child({
    required this.name,
    required this.parentName,
    required this.phoneNumber,
    this.arrived = false,
    this.departed = false,
  });
}
