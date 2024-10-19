import 'package:flutter/material.dart';
import 'package:nsp_mobile/fortune_wheel.dart';
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
  final ApiClient apiClient = ApiClient(
      baseUrl: 'https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com');

  List<Node> visitedNodes = [];
  Node? currentNode;
  bool isLoading = false;
  bool storyEnded = false;
  bool isRolling = false;
  SpinResult spinResult = SpinResult.draw;

  Future<void> _startStory(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken =
        prefs.getString('token'); // Retrieve token using the key 'token'

    if (authToken != null) {
      setState(() {
        isLoading = true;
        visitedNodes.clear();
      });
      try {
        final response =
            await apiClient.get('/api/randomstory', jwtToken: authToken);

        final Node story = Node.fromJson(response["result"]);
        setState(() {
          currentNode = story;
          visitedNodes.add(story);
          isLoading = false;
        });
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
    // Determine the result of the dice roll
    Random random = Random();
    int roll = random.nextInt(3); // 0: fail, 1: okay, 2: succeed

    String result;
    Node? actionNode = edge.child;
    List<Edge>? actionResultEdges = actionNode?.edges;
    Edge? nextEdge;
    SpinResult newSpinResult;
    Node? outcomeNode;
    if (roll == 0) {
      result = 'The action failed.';
      nextEdge = actionResultEdges
          ?.firstWhere((edge) => edge.metadata?.contains('failed') == true);
      newSpinResult = SpinResult.lose;
      outcomeNode =
          Node(description: "You failed the action.", outcome: "failed");
    } else if (roll == 1) {
      result = 'The action was so-so.';
      nextEdge = actionResultEdges
          ?.firstWhere((edge) => edge.metadata?.contains('ok') == true);
      newSpinResult = SpinResult.draw;
      outcomeNode =
          Node(description: "You didn't sucees the action, but you did't fail either.", outcome: "ok");
    } else {
      result = 'The action succeeded!';
      nextEdge = actionResultEdges
          ?.firstWhere((edge) => edge.metadata?.contains('success') == true);
      newSpinResult = SpinResult.win;
      outcomeNode =
          Node(description: "You succeeded the action.", outcome: "success");
    }

    setState(() {
      isRolling = true;
      spinResult = newSpinResult;
    });
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      isRolling = false;
      visitedNodes.add(outcomeNode!);
    });
    _traverseEdge(nextEdge!);
  }

  void _traverseEdge(Edge edge) {
    setState(() {
      currentNode = edge.child;
      visitedNodes.add(edge.child!);
      if (edge.metadata?.contains('Action') == true) {
        _showDiceRollDialog(edge);
      }
      if (edge.metadata?.contains('Ending') == true) {
        setState(() {
          storyEnded = true;
        });
      }
      if (edge.metadata?.contains('Event') == true &&
          edge.child != null &&
          edge.child!.edges != null &&
          edge.child!.edges!.isNotEmpty &&
          edge.child!.edges!
              .every((edge) => edge.metadata?.contains('Ending') == true)) {
        setState(() {
          _traverseEdge(edge.child!.edges!
              .firstWhere((edge) => edge.metadata?.contains('Ending') == true));
        });
      }
    });
  }

  void _restartStory(BuildContext context) {
    setState(() {
      currentNode = null;
      visitedNodes.clear();
      storyEnded = false;
    });
    _startStory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adventure'),
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
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.grey.withOpacity(isRolling ? 0.5 : 0.0),
                              BlendMode.saturation,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Stack(
                                  children: [
                                    ListView.builder(
                                      padding: EdgeInsets.all(8.0),
                                      itemCount: visitedNodes.length,
                                      itemBuilder: (context, index) {
                                        final node = visitedNodes[index];
                                        return _buildStoryNode(node);
                                      },
                                    ),
                                    if (isRolling)
                                      Container(
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                  ],
                                )),
                                if (currentNode?.edges != null &&
                                    currentNode!.edges!.isNotEmpty &&
                                    currentNode!.edges!.every((edge) =>
                                        edge.metadata?.contains('Action') ==
                                        true))
                                  Wrap(
                                    spacing: 8.0,
                                    children: currentNode!.edges!.map((edge) {
                                      if (edge.child != null) {
                                        return _buildStoryNode(edge.child!,
                                            onTouched: () =>
                                                _traverseEdge(edge),
                                            color: edge.metadata!
                                                    .contains('caution')
                                                ? Color.fromARGB(
                                                    255, 82, 152, 185)
                                                : Color.fromARGB(
                                                    255, 197, 97, 97),
                                            showBottomLine: false);
                                      } else {
                                        return _buildStoryNode(
                                          Node(
                                              description:
                                                  'Missing child node'),
                                        );
                                      }
                                    }).toList(),
                                  ),
                                if (storyEnded)
                                  ElevatedButton(
                                      onPressed: () => _restartStory(context),
                                      child: Text('Story Ended, Restart Story'))
                              ],
                            ),
                          ),
                        ),
                        if (isRolling )
                          FortuneWheel(key: UniqueKey(),desiredResult: spinResult),
                        
                      ],
                    )),
    );
  }

  Widget _buildStoryNode(Node node,
      {VoidCallback? onTouched,
      Color? color,
      showBottomLine = true,
      String? outcomeDescription}) {
    return GestureDetector(
      onTap: onTouched,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color ??
              (onTouched == null ? Color(0xff030810) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8.0),
          border: showBottomLine
              ? Border(bottom: BorderSide(color: Colors.white))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(node.description ?? ''),
            if (outcomeDescription != null) Text(outcomeDescription!),
          ],
        ),
      ),
    );
  }
}
