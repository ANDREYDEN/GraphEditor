class Edge {
  int w;
  Node A, B;
  boolean visible;

  Edge(int _w, Node _A, Node _B) {
    w = _w;
    A = _A;
    B = _B;
    visible = true;
  }

  void show() {
    if (w != 0) {
      fill(255);
      text(w, abs(A.pos.x - B.pos.x), abs(A.pos.y - A.pos.y));
    }
    stroke(edge_col);
    strokeWeight(str_weight_edge);
    if (visible)
      line(A.pos.x, A.pos.y, B.pos.x, B.pos.y);
  }
}