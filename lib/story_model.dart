
// Edge class
class Edge {
  Node? child;
  String? metadata;

  Edge({this.child, this.metadata});

  // Factory method to create an Edge from JSON
  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      child: json['child'] != null ? Node.fromJson(json['child']) : null,
      metadata: json['metadata'],
    );
  }

  // Method to convert Edge to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (child != null) {
      data['child'] = child!.toJson();
    }
    data['metadata'] = metadata;
    return data;
  }
}

// Node class
class Node {
  String? id;
  String? description;
  List<Edge>? edges;

  Node({this.id, this.description, this.edges});

  // Factory method to create a Node from JSON
  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      description: json['description'],
      edges: json['edges'] != null
          ? List<Edge>.from(json['edges'].map((e) => Edge.fromJson(e)))
          : null,
    );
  }

  // Method to convert Node to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['description'] = description;
    if (edges != null) {
      data['edges'] = edges!.map((e) => e.toJson()).toList();
    }
    return data;
  }

  void traverse() {
    print(description);
    if (edges != null) {
      for (var edge in edges!) {
        print(edge.metadata);
        edge.child!.traverse();
      }
    }
  }
}


