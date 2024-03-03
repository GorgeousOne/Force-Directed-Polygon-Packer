//https://editor.p5js.org/JeromePaddick/sketches/bjA_UOPip

// Importing necessary libraries
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

// Defining variables
int noNodes = 50;

float gravityConstant = 0.001;
float repulsionConstant = 100;
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
float startDisMultiplier = 0.5;
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
  background(255);
  String debug = "g:" + nf(gravityConstant, 0, 4) + "  repulse:" + nf(repulsionConstant, 0, 0) + "  mass:" + nf(nodeMass, 0, 1);
  text(debug, 10, 10);
  translate(width / 2, height / 2);

  applyForces();

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

void mouseWheel(MouseEvent event) {
  if (clicked) {
    dragNode.rotation += 0.125 * PI * event.getCount();
  }
}
// Function to apply forces to nodes based on physics simulation
void applyForces() {
  calcGravity();
  calcVertexRepulsion();
}


void calcGravity() {
  // Attract all nodes to the 0, 0 with a gravity force
  for (Node node : nodes) {
    PVector gravity = node.pos.copy().mult(-1).mult(gravityConstant);
    node.linearMomentum.add(gravity);
  }
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
      for (PVector vert : node1.transVerts) {
        PVector closestPoint = getClosestShapePoint(vert, node2.transVerts);
        PVector dist = vert.copy().sub(closestPoint);
        //scale repulsion inverse square distance
        PVector force = dist.copy().normalize().div(dist.magSq());
        
        if (getDistSq(vert, node2.pos) < getDistSq(closestPoint, node2.pos)) {
          force.mult(-1);
        }
        //forceSum.div(node1.transVerts.length);
        force.mult(repulsionConstant);
        node1.addForce(vert, force);
      }
    }
  }
}

PVector getClosestShapePoint(PVector p, PVector[] vertices) {
  float minDistSq = 9999999;
  PVector closestPoint = null;
  int n = vertices.length;

  for (int i = 0; i < n; ++i) {
    PVector closePoint = getClosestLinePoint(p, vertices[i], vertices[(i + 1) % n]);
    float distSq = getDistSq(p, closePoint);

    if (distSq < minDistSq) {
      closestPoint = closePoint;
      minDistSq = distSq;
    }
  }
  return closestPoint;
}

float getDistSq(PVector p1, PVector p2) {
  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;
  return dx * dx + dy * dy;
}
/**
 * Returns the nearest point on a line segment to a point p
 */
PVector getClosestLinePoint(PVector p, PVector lineStart, PVector lineEnd) {
  PVector lineLength = lineEnd.copy().sub(lineStart);
  PVector dist = p.copy().sub(lineStart);
  float interpolationVal = constrain(lineLength.dot(dist) / lineLength.magSq(), 0, 1);
  return lineStart.copy().add(lineLength.mult(interpolationVal));
}
