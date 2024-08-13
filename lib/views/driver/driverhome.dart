import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metroshuttle/views/decision_screen/decission_screen.dart';
import 'package:metroshuttle/views/driver/DriverMapPage.dart';
import 'package:metroshuttle/views/driver/RequestsPage.dart';
import 'package:metroshuttle/views/driver/Taskpage.dart';
import 'package:metroshuttle/views/driver/profile_setup.dart';
import 'package:metroshuttle/views/my_profile.dart';
import 'package:metroshuttle/views/payment.dart';

class DriverHomeScreen extends StatefulWidget {
  final String userId;

  const DriverHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    RequestsPage(),
    DriverMapPage(),
    TasksPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => DecisionScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text("METRO SHUTTLE"),
      ),
      drawer: DriverSidePanel(logoutCallback: _logout, userId: widget.userId),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DriverSidePanel extends StatefulWidget {
  final VoidCallback logoutCallback;
  final String userId;

  const DriverSidePanel(
      {Key? key, required this.logoutCallback, required this.userId})
      : super(key: key);

  @override
  _DriverSidePanelState createState() => _DriverSidePanelState();
}

class _DriverSidePanelState extends State<DriverSidePanel> {
  String? _imageUrl;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _imageUrl = userDoc['imageUrl'];
            _userName = userDoc['driverName'];
          });
        } else {
          setState(() {
            _imageUrl = null;
            _userName = "User";
          });
        }
      } catch (e) {
        setState(() {
          _imageUrl = null;
          _userName = "User";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : AssetImage('assets/person.png') as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(
                  _userName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Get.to(() => DriverProfileSetup(userId: widget.userId));
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payment'),
            onTap: () {
              Get.to(() => PaymentScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigate to Settings Page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: widget.logoutCallback,
          ),
        ],
      ),
    );
  }
}
