class Field {
  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  Node active;
  boolean[] freeNum;

  Field() {
    nodes = new ArrayList<Node>();
    edges = new ArrayList<Edge>();
    active = null;
    freeNum = new boolean[maxn];
  }

  void create() {
    int ind = 1;
    for (int i = 1; i < maxn; i++)
      if (!freeNum[i]) {
        ind = i;
        break;
      }
    Node n = new Node(Node_rad, ind);
    freeNum[ind] = true;
    nodes.add(n);
    if (active != null)
      active.act = false;
    active = n;
    n.act = true;
  }

  void clearNodeUsage() {
    for (Node n : nodes)
      n.used = false;
  }

  void visEdges() {
    for (Edge e : edges)
      e.visible = true;
  }

  void relate() {
    for (Node n1 : nodes)
      for (Node n2 : nodes) {
        float dist = PVector.dist(n1.pos, n2.pos);
        if (n1 != n2 && dist < crit_relation) {
          //for every 2 distinct nodes 
          //separate them, if they are too close
          sep(n1, n2);
        }
      }

    //separate every node from edges
    for (Node n : nodes) {
      if (n.pos.x < crit_relation) 
        sep(n, new PVector(0, n.pos.y));
      if (n.pos.y < crit_relation)
        sep(n, new PVector(n.pos.x, 0));
      if (W - n.pos.x < crit_relation)
        sep(n, new PVector(W, n.pos.y));
      if (W - n.pos.y < crit_relation) 
        sep(n, new PVector(n.pos.x, W));
    }
  }

  void update() {
    relate();
    for (Edge e : edges)
      e.show();
    for (Node n : nodes) {
      n.show();
      n.move();
    }
  }
  
  void consLogEdges() {
    for (Edge e : edges) 
      println(e.A.num + " " + e.B.num);  
    println();
  }

  Node checkOverlap() {
    for (Node n : nodes)
      if (dist(mouseX, mouseY, n.pos.x, n.pos.y) < Node_rad) {
        return n;
      }
    return null;
  }
}