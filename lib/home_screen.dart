import 'package:flutter/material.dart';
import 'package:nsp_mobile/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'story_model.dart';

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

  void _traverseEdge(Edge edge) {
    setState(() {
      currentNode = edge.child;
      visitedNodes.add(edge.child!);
      if (edge.metadata?.contains('Action') == true) {
        // show a diallog that conveys that a "dice roll" is occuring, then show the result of wither action seccedding, failing or doing ok. From then choose the next node
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
                          currentNode!.edges!.first.metadata?.contains('Action') == true)
                        Wrap(
                          spacing: 8.0,
                          children: currentNode!.edges!.map((edge) {
                            return ElevatedButton(
                              onPressed: () => _traverseEdge(edge),
                              child: Text(edge.metadata ?? ''),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStoryNode(Node node) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(node.description ?? ''),
        ],
      ),
    );
  }
}