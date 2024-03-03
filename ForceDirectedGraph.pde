https://editor.p5js.org/JeromePaddick/sketches/bjA_UOPip

// Importing necessary libraries
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

// Defining variables
int noNodes = 20;

float gravityConstant = 0.5;
float repulsionConstant = 100000;
//idk basically a scale for gravity and repulsion together?
//was originially between 4 and 20
float nodeMass = 2;
boolean physics = true;

// Lists to store nodes and connections
ArrayList<Node> nodes = new ArrayList<Node>();

// Variables for user interaction
boolean clicked = false;
// speed of dragged node to follow mouse
float lerpValue = 0.2;
float startDisMultiplier = 1;
// Node that is being dragged by moizse
Node dragNode; 
// Magnitude of the interaction
float closeNodeMag;

// Setting up the canvas
void setup() {
  size(800, 800, P2D);
  smooth();
  //fill(0);
  noFill();
  
  // Creating nodes with random positions and sizes
  for (int i = 0; i < noNodes; i++) {
    float x = random(-startDisMultiplier * width, startDisMultiplier * width);
    float y = random(-startDisMultiplier * height, startDisMultiplier * height);
    Node node = new Node(new PVector(x, y), random(20, 50), nodeMass);
    //Node node = new Node(new PVector(random(1), random(1)), random(1, 5));
    nodes.add(node);
  }
  
  dragNode = nodes.get(0);
}

// Drawing function, responsible for rendering on the canvas
void draw() {
  translate(width / 2, height / 2);
  background(255);

  // Applying forces to nodes
  applyForces(nodes);
  
  // Handling user interaction (dragging a node)
  if (clicked == true) {
    PVector mousePos = new PVector(mouseX - width / 2, mouseY - height / 2);
    dragNode.pos.lerp(mousePos, lerpValue);
    if (lerpValue < 0.95) {
      lerpValue += 0.02;
    }
  }
  
  if (physics) {
  // Updating and drawing each node
    for (Node node : nodes) {
      node.update();
    }
  }
  for (Node node : nodes) {
    node.display();
  }
}

// Function triggered when touch (click) starts
void mousePressed() {
  clicked = true;
  PVector mousePos = new PVector(mouseX - width / 2, mouseY - height / 2);
  
  // Finding the closest node to the click position
  for (Node node : nodes) {
    if (mousePos.copy().sub(node.pos).mag() < mousePos.copy().sub(dragNode.pos).mag()) {
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
    node.linearMomentum.add(gravity);
  }
  //calcCenterRepulsion();
  calcVertexRepulsion();
}

void calcVertexRepulsion() {
  
  //iterate over all individual bodies
  for (int i = 0; i < nodes.size(); i++) {
    Node node1 = nodes.get(i);
    
    //calulate repulsion force to all other bodies
    for (int j = 0; j < nodes.size(); j++) {
      //no repulsion to itself
      if (i == j) {
        continue;  
      }
      Node node2 = nodes.get(j);
      
      //iterate over all vertices of a body
      for (PVector v1 : node1.transVerts) {
        PVector forceSum = new PVector();
        
        //iterate over all vertices of the other body
        for (PVector v2 : node2.transVerts) {
          PVector dist = v1.copy().sub(v2);
          //scale repulsion inverse square distance
          PVector force = dist.copy().normalize().div(dist.magSq());
          forceSum.add(force);
        }
        //forceSum.div(node1.transVerts.length);
        forceSum.mult(repulsionConstant);
        node1.addForce(v1, forceSum);
        
        //node1.linearMomentum.add(forceSum.mult(repulsionConstant));
      }
    }
    //println();
  } 
}
