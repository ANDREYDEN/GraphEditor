class Field {
  PVector pos;
  int a;
  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  Edge[][] adj;
  Node active, dragged;
  boolean[] invNum;

  Field(int x, int y, int a) {
    this.pos = new PVector(x, y);
    this.a = a;
    nodes = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
    adj = new Edge[maxn][maxn];
    active = dragged = null;
    invNum = new boolean[maxn];
  }

  void createNode() {
    //find a free number
    int ind = 1;
    for (int i = 1; i < maxn; i++)
      if (!invNum[i]) {
        ind = i;
        break;
      }
    Node n = new Node(Node_rad, ind);
    invNum[ind] = true;
    nodes.add(n);
  }

  void changeEdge(Node u, Node v) {
    Edge copy = null;
    for (Edge e : edges)
      if (other(u, e) == v)
        copy = e;

    if (copy == null) {
      Edge e = new Edge(0, u, v);
      adj[v.num][u.num] = adj[u.num][v.num] = e;
      edges.add(e);
    } else {
      //if the same edge allready exists delete it
      adj[v.num][u.num] = adj[u.num][v.num] = null;
      edges.remove(copy);
    }
  }

  void clearEdgeVisiting() {
    for (Edge e : edges)
      e.visited = false;
  }

  void clearNodeUsage() {
    for (Node n : nodes)
      n.used = 0;
  }

  void relate() {
    for (Node n1 : nodes)
      for (Node n2 : nodes) 
        if (n1 != n2) {
          //for every 2 distinct nodes separate them
          boolean e = (adj[n1.num][n2.num] != null);
          PVector f = n1.relate(n2, e);
          n1.appForce(f);
          n2.appForce(f.mult(-1));
        }

    //separate every node from edges
    for (Node n : nodes) {
      //don't let nodes to escape the box
      if (n.pos.x < pos.x + n.r/2)
        n.pos.x = pos.x + n.r/2;
      if (n.pos.y < pos.y + n.r/2)
        n.pos.y = pos.y + n.r/2;
      if (n.pos.x > pos.x + a - n.r/2)
        n.pos.x = pos.x + a - n.r/2;
      if (n.pos.y > pos.y + a - n.r/2)
        n.pos.y = pos.y + a - n.r/2;
    }
  }

  void update() {
    noStroke();
    fill(field_col);
    rect(pos.x, pos.y, a, a);
    for (Edge e : edges) {
      e.move();
      e.show();
    }
    for (Node n : nodes) {
      n.show();
      n.move();
    }
    if (physics_enable)
      relate();
  }

  boolean bounds(int x, int y) {
    return (x > pos.x + Node_rad/2 && x < pos.x + a - Node_rad/2 &&
      y > pos.y + Node_rad/2 && y < pos.y + a - Node_rad/2);
  }

  void marginLogEdges() {
    int sz = L_margin/5;
    int cnt = 1;
    for (int i = 0; i < maxn; i++) 
      for (int j = i+1; j < maxn; j++) 
        if (adj[i][j] != null) {
        textSize(sz);
        text(i + " " + j, sz, (cnt++)*sz);
      }
  }

  Node checkOverlap() {
    for (Node n : nodes)
      if (dist(mouseX, mouseY, n.pos.x, n.pos.y) < Node_rad) {
        return n;
      }
    return null;
  }
}
