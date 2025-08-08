import 'package:ecofy/components/circular_loader.dart';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:ecofy/services/general/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../pages/own_profile_screen.dart';
import '../../pages/leaderboard.dart';
import '../../pages/all_users_screen.dart'; // New screen

class MainNavigation extends StatefulWidget {
  final DatabaseService database; // database Reference
  final String userId;
  final double width;
  final double height;

  const MainNavigation(
      {super.key,
      required this.database,
      required this.userId,
      required this.width,
      required this.height}); // Add required parameter

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  WebSocketChannel? socket;
  late Map<String, dynamic> userData;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    if (socket != null) {
      switch (index) {
        case 0:
          return OwnProfileScreen(
            database: widget.database,
            userId: widget.userId,
            socket: socket!,
            userData: userData,
            refreshData: _loadUserData,
            width: widget.width,
            height: widget.height,
          );
        case 1:
          return Leaderboard(
            width: widget.width,
            height: widget.height,
            database: widget.database, // Pass the database reference here
            userId: widget.userId,
            socket: socket!,
          );
        case 2:
          return socket != null
              ? AllUsersScreen(
                  width: widget.width,
                  height: widget.height,
                  socket: socket!,
                  userId: widget.userId,
                  database: widget.database,
                )
              : const Circularloader();
        default:
          return const Center(child: Text('Page not found'));
      }
    } else {
      return const Center(
          child: SizedBox(child: CircularProgressIndicator.adaptive()));
    }
  }

  void _loadUserData() {
    widget.database.queryById(widget.userId).then((data) {
      //No needed for If statement as the page will only switch once data is saved
      setState(() {
        //print('$data, ${widget.userId}');
        userData = {...data!};
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    socket!.sink.close();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    dotenv.load().then((data) {
      String? websocketURL = dotenv.env["websocketURL"];

      String socketUrl = "$websocketURL?userId=${widget.userId}";
      setState(() {
        socket = connectToWebsocket(socketUrl);
      });
      listendMsg(socket!, widget.database, widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'All Users',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
