class Edge {
  int w;
  Node A, B;
  int direction;
  float ratio;
  boolean visited;

  Edge(int _w, Node _A, Node _B) {
    w = _w;
    A = _A;
    B = _B;
    direction = 0;
    ratio = 1;
    visited = false;
  }

  void move() {
    ratio += animation_velocity*direction;  
    if (ratio > 1) {
      ratio = 1;
      direction = 0;
    } else if (ratio < 0) {
      ratio = 0;
      direction = 0;
    }
  }

  void show() {
    if (w != 0) {
      fill(255);
      text(w, abs(A.pos.x - B.pos.x), abs(A.pos.y - A.pos.y));
    }
    stroke(edge_col);
    strokeWeight(str_weight_edge);
    PVector l = PVector.sub(B.pos, A.pos);
    l.mult(ratio);
    PVector end = PVector.add(A.pos, l);
    line(A.pos.x, A.pos.y, end.x, end.y);
  }
}
