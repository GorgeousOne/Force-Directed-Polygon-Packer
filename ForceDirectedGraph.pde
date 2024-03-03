https://editor.p5js.org/JeromePaddick/sketches/bjA_UOPip

// Importing necessary libraries
import java.util.HashSet;
import java.util.Set;

// Defining variables
int noNodes = 100;
int noConn = 50;

float gravityConstant = 1.1;
float repulsionConstant = 1000;
boolean physics = true;

// Lists to store nodes and connections
ArrayList<Node> nodes = new ArrayList<Node>();
// a connection being 
ArrayList<int[]> nodeCon = new ArrayList<int[]>();

// Variables for user interaction
boolean clicked = false;
// speed of dragged node to follow mouse
float lerpValue = 0.2;
float startDisMultiplier = 10;
// Node that is being dragged by moizse
Node dragNode; 
// Magnitude of the interaction
float closeNodeMag;

// Setting up the canvas
void setup() {
  size(800, 800);
  fill(0);
  
  // Creating nodes with random positions and sizes
  for (int i = 0; i < noNodes; i++) {
    float x = random(-startDisMultiplier * width, startDisMultiplier * width);
    float y = random(-startDisMultiplier * height, startDisMultiplier * height);
    Node node = new Node(new PVector(x, y), random(1, 5));
    //Node node = new Node(new PVector(random(1), random(1)), random(1, 5));
    nodes.add(node);
  }
  
  dragNode = nodes.get(0);
  
  // Create random connections between nodes
  for (int n = 0; n < noConn; n++) {
    nodeCon.add(new int[] {
      round(random(noNodes - 1)),
      round(random(noNodes - 1))
    });
  }
  nodeCon.add(new int[] {0, 1, 200});

  // Make set of all connected nodes
  Set<Integer> connected = new HashSet<Integer>();
  for (int[] conn : nodeCon) {
    connected.add(conn[0]);
    connected.add(conn[1]);
  }

  // Connect any node not connected to any other node yet
  for (int n = 0; n < noNodes; n++) {
    if (!connected.contains(n)) {
      nodeCon.add(new int[] {
        n,
        round(random(noNodes - 1))
      });
    }
  }
}

// Drawing function, responsible for rendering on the canvas
void draw() {
  translate(width / 2, height / 2);
  background(255);
  
  // Drawing connections between nodes
  for (int[] con : nodeCon) {
    Node node1 = nodes.get(con[0]);
    Node node2 = nodes.get(con[1]);
    line(node1.pos.x, node1.pos.y, node2.pos.x, node2.pos.y);
  }
  
  // Applying forces to nodes
  applyForces(nodes);
  
  // Updating and drawing each node
  for (Node node : nodes) {
    //... first draw then update, otherwise dragging is affected by forces
    node.draw();
    if (physics) {
      node.update();
    }
  }
  
  // Handling user interaction (dragging a node)
  if (clicked == true) {
    PVector mousePos = new PVector(mouseX - width / 2, mouseY - height / 2);
    dragNode.pos.lerp(mousePos, lerpValue);
    if (lerpValue < 0.95) {
      lerpValue += 0.02;
    }
  }
}

// Function triggered when touch (click) starts
void mousePressed() {
  clicked = true;
  PVector mousePos = new PVector(mouseX - width / 2, mouseY - height / 2);
  
  // Finding the closest node to the click position
  for (Node node : nodes) {
    if (mousePos.copy().sub(node.pos).mag() - dragNode.mass / (2 * PI) < mousePos.copy().sub(dragNode.pos).mag() - dragNode.mass / (2 * PI)) {
      dragNode = node;
    }
  }
}

// Function triggered when touch (click) ends
void mouseReleased() {
  clicked = false;
  lerpValue = 0.2;
}

// Function to apply forces to nodes based on physics simulation
void applyForces(ArrayList<Node> nodes) {
  // Attract all nodes to the 0, 0 with a gravity force 
  for (Node node : nodes) {
    PVector gravity = node.pos.copy().mult(-1).mult(gravityConstant);
    node.force = gravity;
  }
  
  // attract all nodes to 0, 0 but less strength towards diagonals, to create a square arrangement
  // ended up creating funny currents
  //for (Node node : nodes) {
  //  float squareVal = node.pos.mag() / (abs(node.pos.x) + abs(node.pos.y));
  //  PVector gravity = node.pos.copy().mult(-1).mult(gravityConstant * squareVal);    
  //  node.force = gravity;
  //}
  

  // Applying repulsive forces between nodes
  for (int i = 0; i < nodes.size(); i++) {
    PVector pos = nodes.get(i).pos;
    for (int j = i + 1; j < nodes.size(); j++) {
      // get distance between all nodes
      PVector dir = nodes.get(j).pos.copy().sub(pos);
      //scale repulsion by distance so that it decreases quadratically
      PVector force = dir.div(dir.magSq());
      //scale repulsion by a constant to control desired spacing
      force.mult(repulsionConstant);
      nodes.get(i).force.add(force.copy().mult(-1));
      nodes.get(j).force.add(force);
    }
  }

  // Applying forces to maintain connection distances
  for (int[] con : nodeCon) {
    Node node1 = nodes.get(con[0]);
    Node node2 = nodes.get(con[1]);
    //get distance between connected nodes
    PVector dist = node1.pos.copy().sub(node2.pos);
    //increase force to move nodes together... without any control over distance
    node1.force.sub(dist);
    node2.force.add(dist);
  }
}

// Node class representing each point in the simulation
class Node {
  PVector pos;
  //force to move a node unrelated to mass yet
  PVector force;
  //mass that influences how much force i needed to get this node moving
  float mass;

  Node(PVector pos, float size) {
    this.pos = pos;
    this.force = new PVector(0, 0);
    this.mass = (2 * PI * size) / 1.5;
  }

  // Updating node position based on applied force
  void update() {
    PVector force = this.force.copy();
    PVector vel = force.copy().div(mass);
    pos.add(vel);
  }

  // Drawing the node on the canvas
  void draw() {
    ellipse(pos.x, pos.y, mass, mass);
  }
}
