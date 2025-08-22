import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Leaderboard extends StatefulWidget {
  final double height;
  final double width;
  final String userId;
  final WebSocketChannel socket;
  final DatabaseService database;

  const Leaderboard({
    super.key,
    required this.height,
    required this.width,
    required this.database,
    required this.userId,
    required this.socket,
  });

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<Map<String, dynamic>> topPlayers = [];
  bool isLoading = true;

  void loadLeaderboardData() async {
    try {
      final allUsers = await widget.database.queryAll();
      final mutableUsers = List<Map<String, dynamic>>.from(allUsers);
      mutableUsers.sort((a, b) => (b['countUploadedPhotos'] ?? 0)
          .compareTo(a['countUploadedPhotos'] ?? 0));
      setState(() {
        if (mutableUsers.length == 1) {
          topPlayers = [];
          isLoading = true;
        } else {
          topPlayers = mutableUsers.take(10).toList();
          isLoading = false;
        }
      });
    } catch (error) {
      debugPrint("Error loading leaderboard data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.socket.sink
        .add(jsonEncode({"action": "getAllUsers", "userId": widget.userId}));
    loadLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    loadLeaderboardData();
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(), // Podium section
                Expanded(child: _buildLeaderboardList()), // Leaderboard list
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: widget.height * 0.45,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF37BE81), Color.fromARGB(255, 13, 66, 42)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topPlayers.length > 1)
                _buildPodiumPlayer(topPlayers[1], "2nd", Colors.grey, 80),
              if (topPlayers.isNotEmpty)
                _buildPodiumPlayer(topPlayers[0], "1st", Colors.amber, 120),
              if (topPlayers.length > 2)
                _buildPodiumPlayer(topPlayers[2], "3rd",
                    const Color.fromARGB(255, 138, 85, 16), 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlayer(
      Map<String, dynamic> player, String rank, Color color, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rank text
        Text(
          rank,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // Profile picture
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage:
              player['profilePic'] != null && player['profilePic'] != ''
                  ? NetworkImage(player['profilePic'])
                  : null,
          child: player['profilePic'] == null || player['profilePic'] == ''
              ? const Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          height: height,
          width: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        const SizedBox(height: 10),
        // Player name
        Text(
          player['username'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Points
        Text(
          '${player['countUploadedPhotos'] ?? 0} pts',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      itemCount: topPlayers.length - 3,
      itemBuilder: (context, index) {
        final player = topPlayers[index + 3];
        final rank = index + 4; // Rank starts from 4 for users below the podium
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank number
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '$rank${_getOrdinalSuffix(rank)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
              // User card with profile and details
              Expanded(
                child: Stack(
                  children: [
                    // Faded green background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF37BE81).withOpacity(1),
                              Colors.transparent
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // User content
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: player['profilePic'] != null &&
                                    player['profilePic'] != ''
                                ? NetworkImage(player['profilePic'])
                                : null,
                            child: player['profilePic'] == null ||
                                    player['profilePic'] == ''
                                ? const Icon(Icons.person,
                                    size: 30, color: Colors.grey)
                                : null,
                          ),
                        ),
                        title: Text(
                          player['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${player['countUploadedPhotos'] ?? 0} pts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getOrdinalSuffix(int rank) {
    if (rank % 10 == 1 && rank % 100 != 11) {
      return 'st';
    } else if (rank % 10 == 2 && rank % 100 != 12) {
      return 'nd';
    } else if (rank % 10 == 3 && rank % 100 != 13) {
      return 'rd';
    } else {
      return 'th';
    }
  }
}
