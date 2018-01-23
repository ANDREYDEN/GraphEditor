//constants
int W, L_margin, R_margin, maxn, Node_rad, relation_dist, crit_relation, text_size;
int str_weight_out_node, str_weight_edge, des_edge_len;
float relation_power, spring_coef, animation_velocity;
color in_Node_col, out_Node_col, used1_Node_col, used2_Node_col;
color edge_col, field_col, text_col, flash_col, margin_col;
color Button_on_col, Button_off_col;
PVector deltaF;
boolean Euler_enable, Euler_erase, physics_enable;
IntList EuAns;
int EuIt, flash, flash_time;
Edge animated;
Button phyButton;
Field f;

void setup() {
  size(1000, 600);

  //initialization
  
  //basic
  W = 600;
  L_margin = R_margin = 200;
  maxn = 1000;
  Node_rad = 35;
  text_size = 15;
  phyButton = new Button(L_margin, 0, 100, 20, "Physics");
  
  //physics
  physics_enable = true;
  relation_dist = 120;
  crit_relation = 10;
  des_edge_len = 200;
  deltaF = new PVector(0, 1);
  relation_power = 2000;
  spring_coef = 0.005;
  
  //visual stuff
  str_weight_out_node = 3;
  str_weight_edge = 4;
  in_Node_col = color(255, 255, 0);
  out_Node_col = color(255, 0, 0);
  used1_Node_col = color(175, 175, 0);
  used2_Node_col = color(75, 75, 0);
  edge_col = color(50, 100, 200);
  field_col = text_col = color(0);
  flash_col = color(255, 0, 0);
  margin_col = color(145);
  Button_on_col = color(50, 200, 0);
  Button_off_col = color(200, 50, 0);
  
  //Euler stats
  Euler_enable = false;
  Euler_erase = false;
  animation_velocity = 0.01;
  EuIt = flash = 0;
  flash_time = 10;
  f = new Field(L_margin, 0, W);
}

void draw() {
  if (Euler_enable) {
    //renew graph, if alg finished
    if (EuIt == -1 || EuAns.size() == 1) {
      Euler_enable = false;
      f.clearNodeUsage();
      f.clearEdgeVisiting();
      EuIt = 0;
    } else {
      //remove an edge from the answer
      if (animated == null || animated.direction == 0) {
        int from = EuAns.get(EuIt);
        int to = EuAns.get(EuIt+1);   
        animated = f.adj[from][to];
        if (Euler_erase) {
          EuIt++;
          animated.direction = -1;
          if (from == animated.A.num) {
            Node C = animated.A;
            animated.A = animated.B;
            animated.B = C;
          }
        } else {
          EuIt--;
          animated.direction = 1;
        }
      }
    }
    if (EuIt == EuAns.size()-1) {
      EuIt--;
      Euler_erase = false;
    }
  }

  if (mousePressed) {
    if (f.dragged != null)
      f.dragged.pos.set(mouseX, mouseY);
  }

  marginUpdate();
  f.update();
  phyButton.show();
  checkFlash();
}

void keyPressed() {
  if (key == 'e' && !Euler_enable) {
    //find the path (cycle) and enable Euler pathfinding animation
    Node st = EulerStart();
    if (st != null) {
      EuAns = new IntList();
      EulerPath(st);
      Euler_enable = true;
      Euler_erase = true;
      f.clearEdgeVisiting();
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

      for (Edge e : removed) {
        f.adj[e.A.num][e.B.num] = null;
        f.adj[e.B.num][e.A.num] = null;
        f.edges.remove(e);
      }
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

  if (mouseButton == RIGHT && f.bounds(mouseX, mouseY)) 
    f.createNode();
}

void mouseReleased() {
  f.dragged = null;
  phyButton.change();
}