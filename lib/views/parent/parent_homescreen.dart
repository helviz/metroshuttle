import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metroshuttle/views/decision_screen/decission_screen.dart';
import 'package:metroshuttle/views/my_profile.dart';
import 'package:metroshuttle/views/parent/ParentsRequestsPage.dart';
import 'package:metroshuttle/views/parent/notification_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  final String userId;

  const ParentHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ParentsRequestPage(),
      NotificationScreen(),
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
      drawer: ParentSidePanel(logoutCallback: _logout, userId: widget.userId),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ParentSidePanel extends StatefulWidget {
  final VoidCallback logoutCallback;
  final String userId;

  const ParentSidePanel({Key? key, required this.logoutCallback, required this.userId}) : super(key: key);

  @override
  _ParentSidePanelState createState() => _ParentSidePanelState();
}

class _ParentSidePanelState extends State<ParentSidePanel> {
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
          print('User Name: $_userName');
          print('Image URL: $_imageUrl');
        } else {
          setState(() {
            _imageUrl = null;
            _userName = "User";
          });
          print('User document does not exist');
        }
      } catch (e) {
        print("Error fetching user data: $e");
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
