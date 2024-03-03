// Node class representing each point in the simulation
class Node {
  PVector pos;
  float rotation;
  
  //force to move a node unrelated to mass yet
  PVector linearMomentum;
  float angularMomentum;
  
  //mass to calculate inertia - how much force is needed to get this node moving
  float mass;
  float inertia;
  PVector[] verts;
  PVector[] transVerts;
  
  //List<Triangle> tris;
  
  Node(PVector pos, float size, float mass) {
    this.pos = pos;
    this.linearMomentum = new PVector(0, 0);
    this.mass = mass;

    this.verts = new PVector[4];
    this.transVerts = new PVector[4];

    for (int i = 0; i < 4; i++) {
      float angle = HALF_PI * i + QUARTER_PI;
      float vx = size * cos(angle);
      float vy = size * sin(angle);
      verts[i] = new PVector(vx, vy);
    }
    PVector centroid = calcCentroid(triangulate(verts));
    
    for (int i = 0; i < 4; i++) {
      verts[i].sub(centroid);
      transVerts[i] = verts[i].copy();
      inertia += verts[i].magSq();
    }
    inertia *= mass / verts.length;
  }
  
  PVector calcCentroid(List<Triangle> triangles) {
    PVector centroid = new PVector();
    float totalArea = 0;
    
    for (Triangle tri : triangles) {
      float area = tri.getArea();
      centroid.add(tri.getCentroid().mult(area));
      totalArea += area;
    }
    centroid.div(totalArea);
    return centroid;
  }
    
  void addForce(PVector point, PVector force) {
    //dont do stupid forces
    if (Double.isNaN(force.x) || Double.isNaN(force.y)) {
      println("meh");
      return;
    }
    PVector dist = point.copy().sub(pos);    
    linearMomentum.add(force.copy().div(mass));
    angularMomentum += dist.cross(force).z / inertia;
  }

  // Updating node position based on applied force
  void update() {
    linearMomentum.limit(10);
    
    if (!Double.isNaN(linearMomentum.x) && !Double.isNaN(linearMomentum.y)) {
      pos.add(linearMomentum);
    }
    //rotation += angularMomentum / mass;
    rotation += angularMomentum;
    //stop nodes from leaving square box
    pos.set(constrain(pos.x, -maxx - random(1), maxx + random(1)), constrain(pos.y, -maxx - random(1), maxx + random(1)));
    
    //re-calculate transformed vertices
    for (int i = 0; i < verts.length; ++i) {
      transVerts[i].set(verts[i].copy().rotate(rotation).add(pos));
    }
    
    float damping = 0.75;
    linearMomentum.mult(damping);
    angularMomentum *= damping;
    //linearMomentum.set(0, 0);
    //angularMomentum = 0;
  }

  // Drawing the node on the canvas
  void display() {    
    pushStyle();
    noFill();    
    beginShape();
    
    for (PVector v : transVerts) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    
    fill(0);
    //draw center of mass
    ellipse(pos.x, pos.y, 5, 5);
    popStyle();
  }
}

float maxx = 400;
