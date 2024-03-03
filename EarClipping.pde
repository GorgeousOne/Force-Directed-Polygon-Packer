
// Function to triangulate the polygon
ArrayList<Triangle> triangulate(PVector[] asdf) {
  ArrayList<PVector> points = new ArrayList<>(Arrays.asList(asdf));
  ArrayList<Triangle> triangles = new ArrayList<>();
  int n = points.size();

  // Loop until only one triangle remains
  while (n > 3) {
    // Find an ear
    int i = 0;
    
    while (!isEar(points, i)) {
      ++i;
    }
    // Remove the ear and add the triangle formed by the remaining points
    PVector p1 = points.get(i);
    PVector p2 = points.get((i + 1) % n);
    PVector p3 = points.get((i + 2) % n);
    triangles.add(new Triangle(p1, p2, p3));

    points.remove((i + 1) % n);
    --n;
  }
  // Add the last triangle
  triangles.add(new Triangle(points.get(0), points.get(1), points.get(2)));

  return triangles;
}

// Function to check if a vertex is an ear
boolean isEar(List<PVector> points, int i) {
  int n = points.size();
  PVector p1 = points.get(i);
  PVector p2 = points.get((i + 1) % n);
  PVector p3 = points.get((i + 2) % n);
  // Check if the angle is convex
  float angle = atan2(p2.y - p1.y, p2.x - p1.x) - atan2(p3.y - p2.y, p3.x - p2.x);

  if (angle > Math.PI) {
    return false;
  }
  // Check if any point is inside the triangle formed by the ear
  for (int j = 0; j < n; j++) {
    if (j == i || j == (i + 1) % n || j == (i + 2) % n) {
      continue;
    }
    PVector p = points.get(j);
    if (isInsideTriangle(p1, p2, p3, p)) {
      return false;
    }
  }
  return true;
}

// Function to check if a point is inside a triangle
// using barycentric coordinates which I'm never going to touch ;D
boolean isInsideTriangle(PVector p1, PVector p2, PVector p3, PVector p) {
  float det = (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);
  float alpha = ((p3.y - p1.y) * (p.x - p1.x) + (p3.x - p1.x) * (p.y - p1.y)) / det;
  float beta = ((p2.y - p1.y) * (p.x - p1.x) + (p2.x - p1.x) * (p.y - p1.y)) / det;
  return (alpha > 0 && alpha < 1 && beta > 0 && beta < 1);
}


// Class to represent a triangle
class Triangle {
  PVector p1;
  PVector p2;
  PVector p3;

  Triangle(PVector p1, PVector p2, PVector p3) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }

  // Function to calculate the area of the triangle
  public float getArea() {
      return 0.5 * abs(p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y));
  }

  // Function to calculate the center (centroid) of the triangle
  public PVector getCentroid() {
      // Calculate the centroid coordinates
      float centroidX = (p1.x + p2.x + p3.x) / 3;
      float centroidY = (p1.y + p2.y + p3.y) / 3;
      // Create and return the centroid point
      return new PVector(centroidX, centroidY);
  }

  // Draw the triangle
  void display() {
    beginShape();
    vertex(p1.x, p1.y);
    vertex(p2.x, p2.y);
    vertex(p3.x, p3.y);
    endShape(CLOSE);
  }
}
