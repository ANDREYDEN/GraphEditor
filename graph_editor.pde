int W, maxn, Node_rad, relation_dist, crit_relation, text_size;
int str_weight_out_node, str_weight_edge, alg_it_delay, des_edge_len;
float relation_power, spring_coef;
color in_Node_col, out_Node_col, used1_Node_col, used2_Node_col;
color edge_col, field_col, text_col, flash_col;
PVector deltaF;
boolean Euler_enable;
IntList EuAns;
int EuIt, flash, flash_time;
Field f;

void setup() {
  size(600, 600);

  //initialization
  W = 600;
  maxn = 1000;
  Node_rad = 35;
  relation_dist = 120;
  crit_relation = 10;
  des_edge_len = 100;
  text_size = 15;
  relation_power = 2000;
  spring_coef = 0.005;
  in_Node_col = color(255, 255, 0);
  out_Node_col = color(255, 0, 0);
  used1_Node_col = color(175, 175, 0);
  used2_Node_col = color(75, 75, 0);
  str_weight_out_node = 3;
  str_weight_edge = 4;
  edge_col = color(50, 100, 200);
  field_col = text_col = color(0);
  flash_col = color(255, 0, 0);
  deltaF = new PVector(0, 1);
  Euler_enable = false;
  alg_it_delay = 1200;
  EuIt = flash = 0;
  flash_time = 10;
  f = new Field();
  textSize(text_size);
}

void draw() {
  if (Euler_enable) {
    //renew graph, if alg finished
    if (EuIt == EuAns.size()-1 || EuAns.size() == 1) {
      Euler_enable = false;
      f.visEdges();
      f.clearNodeUsage();
      EuIt = 0;
      EuAns.clear();
    } else {
      //remove an edge from the answer
      int from = EuAns.get(EuIt);
      int to = EuAns.get(EuIt+1);
      EuIt++;
      f.adj[from][to].visible = false;
    }
    delay(alg_it_delay);
  }

  if (mousePressed)
    if (f.dragged != null)
      f.dragged.pos.set(mouseX, mouseY);

  background(field_col);
  checkFlash();
  f.update();
}

void keyPressed() {
  if (key == 'e' && !Euler_enable) {
    //find the path (cycle) and enable Euler pathfinding animation
    Node st = EulerStart();
    if (st != null) {
      EuAns = new IntList();
      EulerPath(st);
      Euler_enable = true;
      f.visEdges();
    } else 
      flash = 1;
  } else if (key == DELETE) {
    //delete a node and all involved edges
    Node out = f.active;
    if (out != null) {
      f.invNum[out.num] = false;
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
  Node cur = f.checkOverlap();

  //if anything is being dragged - trace it
  if (cur != null) { 
    if (f.active == cur) {
      //if the node was pressed twice
      f.active.act = false;
      f.active = null;
    } else if (f.active != null) {
      //if smth was active, create a new edge
      f.changeEdge(f.active, cur);
      f.active.act = false;
      f.active = null;
    } else {
      //else make curent node active
      f.active = cur;
      cur.act = true;
    }
    f.dragged = cur;
  }

  if (mouseButton == RIGHT) 
    f.createNode();
}

void mouseReleased() {
  f.dragged = null;
}