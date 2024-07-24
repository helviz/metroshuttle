import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metroshuttle/views/coordinator/attendance.dart';
import 'package:metroshuttle/views/decision_screen/decission_screen.dart';
import 'package:metroshuttle/views/my_profile.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  final String userId;

  const CoordinatorHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CoordinatorHomeScreenState createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChildArrivalTable(),
      // ProfilePage(), // Assuming you have a ProfilePage
    ];
  }

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
        title: Text('METRO SHUTTLE'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: CoordinatorSidePanel(logoutCallback: _logout, userId: widget.userId),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CoordinatorSidePanel extends StatefulWidget {
  final VoidCallback logoutCallback;
  final String userId;

  const CoordinatorSidePanel({Key? key, required this.logoutCallback, required this.userId}) : super(key: key);

  @override
  _CoordinatorSidePanelState createState() => _CoordinatorSidePanelState();
}

class _CoordinatorSidePanelState extends State<CoordinatorSidePanel> {
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
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _imageUrl = userDoc['imageUrl'];
            _userName = userDoc['name'];
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
              Get.to(() => ProfilePage());
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
