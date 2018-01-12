int W, maxn, Node_rad, crit_relation, text_size;
int str_weight_out_node, str_weight_edge, algItDelay;
float relation_power;
color in_Node_col, out_Node_col, used1_Node_col, used2_Node_col, edge_col, field_col, text_col;
Node place;
boolean Euler_enable;
Field f;

void setup() {
  size(600, 600);

  //initialization
  W = 600;
  maxn = 1000;
  Node_rad = 35;
  crit_relation = 80;
  text_size = 15;
  relation_power = 80;
  in_Node_col = color(255, 255, 0);
  out_Node_col = color(255, 0, 0);
  used1_Node_col = color(175, 175, 0);
  used2_Node_col = color(75, 75, 0);
  str_weight_out_node = 3;
  str_weight_edge = 4;
  edge_col = color(50, 100, 200);
  field_col = text_col = color(0);
  Euler_enable = false;
  algItDelay = 1200;
  place = null;

  f = new Field();
  textSize(text_size);
}

void draw() {
    
  if (Euler_enable) {
    if (place == null) {
      //if the end of alg is reached put back all the edges
      Euler_enable = false;
      f.visEdges();
      f.clearNodeUsage();
    } else {
      place.act = false;
      place = EulerPath(place);
      if (place != null)
        place.act = true;
    }
  }
  
  background(field_col);
  f.update();
}

void keyPressed() {
  if (key == 'e') {
    Euler_enable = true;
    //enable Euler pathfinding animation and choose a node to start
    place = f.nodes.get(0);
    for (Node n : f.nodes)
      if (n.act)
        place = n;
    //print the first element of the path
    println(place.num);
  } else if (key == DELETE) {
    //delete a node and all involved edges
    Node out = f.active;

    if (out != null) {
      f.freeNum[out.num] = false;
      f.nodes.remove(out);
      f.active = null;
      ArrayList<Edge> removed = new ArrayList<Edge>();

      for (Edge e : f.edges)
        if (e.A == out || e.B == out)
          removed.add(e);

      for (Edge e : removed)
        f.edges.remove(e);
    }
  }
}

void mousePressed() {
  if (mouseButton == RIGHT)
    f.create();
  Node cur = f.checkOverlap();

  //if anything is being dragged - trace it
  if (cur != null) 
    if (f.active != null) {
      //if smth was active, create a new edge
      if (cur != f.active) {
        Edge copy = null;

        for (Edge e : f.edges)
          if (other(cur, e) == f.active)
            copy = e;

        //if the same dege allready exists delete it
        if (copy == null)
          f.edges.add(new Edge(0, f.active, cur));
        else
          f.edges.remove(copy);
      }

      //do the active node inactive
      f.active.act = false;
      f.active = null;
    } else {
      //else make curent node active
      f.active = cur;
      cur.act = true;
    }
}

void mouseDragged() {
  if (f.active != null && f.checkOverlap() == f.active)
    f.active.pos.set(mouseX, mouseY);
}