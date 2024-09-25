import 'package:flutter/material.dart';
import 'package:nsp_mobile/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'story_model.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient apiClient = ApiClient(baseUrl: 'https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com');

  List<Node> visitedNodes = [];
  Node? currentNode;
  bool isLoading = false;

  Future<void> _startStory(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token'); // Retrieve token using the key 'token'

    if (authToken != null) {
      setState(() {
        isLoading = true;
        visitedNodes.clear();
      });
      try {
        final response = await apiClient.get('/api/randomstory', jwtToken: authToken);

        if (response != null) {
          final Node story = Node.fromJson(response["result"]);
          setState(() {
            currentNode = story;
            visitedNodes.add(story);
            isLoading = false;
          });
        } else {
          print('Failed to start story');
        }
      } catch (e) {
        if (e.toString().contains('Unauthorized')) {
          print('Unauthorized or token expired');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          print('Error during API call: $e');
        }
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Auth token not found');
    }
  }

  void _showDiceRollDialog(Edge edge) async {
    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rolling the Dice'),
          content: Text('Determining the outcome...'),
        );
      },
    );

    // Simulate a delay for the dice roll
    await Future.delayed(Duration(seconds: 2));

    // Dismiss the dialog
    Navigator.of(context).pop();

    // Determine the result of the dice roll
    Random random = Random();
    int roll = random.nextInt(3); // 0: fail, 1: okay, 2: succeed

    String result;
    Node? actionNode = edge.child;
    List<Edge>? actionResultEdges = actionNode?.edges;
    Node? nextNode;
    if (roll == 0) {
      result = 'The action failed.';
      nextNode = actionResultEdges?.firstWhere((edge) => edge.metadata?.contains('failed') == true).child;
      // Determine nextNode based on action failure
      // nextNode = edge.child; // Assign the appropriate node
    } else if (roll == 1) {
      result = 'The action was so-so.';
      nextNode = actionResultEdges?.firstWhere((edge) => edge.metadata?.contains('ok') == true).child;
      // Determine nextNode based on action okay
      // nextNode = edge.child; // Assign the appropriate node
    } else {
      result = 'The action succeeded!';
      nextNode = actionResultEdges?.firstWhere((edge) => edge.metadata?.contains('success') == true).child;
      // Determine nextNode based on action success
      // nextNode = edge.child; // Assign the appropriate node
    }

    // Show the result dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dice Roll Result'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.of(context).pop();
                if (nextNode == null) {
                  return;
                }
                setState(() {
                  currentNode = nextNode;
                  visitedNodes.add(nextNode!);
                });
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _traverseEdge(Edge edge) {
    setState(() {
      currentNode = edge.child;
      visitedNodes.add(edge.child!);
      if (edge.metadata?.contains('Action') == true) {
        _showDiceRollDialog(edge);
      }
    });
  }

  void _restartStory(BuildContext context) {
    setState(() {
      currentNode = null;
      visitedNodes.clear();
    });
    _startStory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _restartStory(context),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : currentNode == null
                ? ElevatedButton(
                    onPressed: () => _startStory(context),
                    child: Text('Start Story'),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: visitedNodes.length,
                          itemBuilder: (context, index) {
                            final node = visitedNodes[index];
                            return _buildStoryNode(node);
                          },
                        ),
                      ),
                      if (currentNode?.edges != null &&
                          currentNode!.edges!.isNotEmpty &&
                          currentNode!.edges!.every((edge) => edge.metadata?.contains('Action') == true))
                        Wrap(
                          spacing: 8.0,
                           children: currentNode!.edges!.map((edge) {
                            if (edge.child != null) {
                              return _buildStoryNode(edge.child!, onTouched: () => _traverseEdge(edge), color:edge.metadata!.contains('caution') ? Color.fromARGB(255, 82, 152, 185) : Color.fromARGB(255, 197, 97, 97));
                            } else {
                              return _buildStoryNode(
                                Node(description: 'Missing child node'),
                              );
                            }
                          }).toList(),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStoryNode(Node node, {VoidCallback? onTouched, Color? color}) {
    return GestureDetector(
      onTap: onTouched,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color ?? (onTouched != null ? Colors.lightBlue[50] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(node.description ?? ''),
          ],
        ),
      ),
    );
  }
}