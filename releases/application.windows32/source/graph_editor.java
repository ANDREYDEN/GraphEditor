import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class graph_editor extends PApplet {

//constants
int W, L_margin, R_margin, maxn, Node_rad, relation_dist, crit_relation, text_size;
int str_weight_out_node, str_weight_edge, des_edge_len;
float relation_power, spring_coef, animation_velocity;
int in_Node_col, out_Node_col, used1_Node_col, used2_Node_col;
int edge_col, field_col, text_col, flash_col, margin_col;
int Button_on_col, Button_off_col;
PVector deltaF;
boolean Euler_enable, Euler_erase, physics_enable;
IntList EuAns;
int EuIt, flash, flash_time;
Edge animated;
Button phyButton;
Field f;

public void setup() {
  

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
  spring_coef = 0.005f;
  
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
  animation_velocity = 0.01f;
  EuIt = flash = 0;
  flash_time = 10;
  f = new Field(L_margin, 0, W);
}

public void draw() {
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

public void keyPressed() {
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

public void mousePressed() {
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

public void mouseReleased() {
  f.dragged = null;
  phyButton.change();
}
class Button {
  PVector pos;
  int w, h;
  String txt;
  boolean on;

  Button(int x, int y, int w, int h, String txt) {
    this.pos = new PVector(x, y);
    this.w = w;
    this.h = h;
    this.on = true;
    this.txt = txt;
  }

  public void change() {
    if (mouseX > pos.x && mouseX < pos.x + w &&
      mouseY > pos.y && mouseY < pos.y + w) {
      on = !on;
      physics_enable = on;
    }
  }

  public void show() {
    noStroke();
    if (on) 
      fill(Button_on_col);
    else
      fill(Button_off_col);
    rect(pos.x, pos.y, w, h);
    float sz = PApplet.parseFloat(w/txt.length());
    textSize(sz);
    fill(text_col);
    text(txt, pos.x + sz, pos.y + sz);
  }
}
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

  public void move() {
    ratio += animation_velocity*direction;  
    if (ratio > 1) {
      ratio = 1;
      direction = 0;
    } else if (ratio < 0) {
      ratio = 0;
      direction = 0;
    }
  }

  public void show() {
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
public Node other(Node n, Edge e) {
  if (n == e.A)
    return e.B;
  else if (n == e.B)
    return e.A;
  else
    return null;
}

public Node EulerStart() {
  int cnt = 0;
  int ans = -1;
  for (int i = 1; i < maxn && cnt < 3; i++) {
    int c = 0;
    for (int j = 1; j < maxn; j++)
      if (f.adj[i][j] != null)
        c++;
    if (c%2 == 1) {
      ans = i;
      cnt++;
    }
  }
  if (cnt == 0)
    return f.nodes.get(0);
  if (cnt == 2)
    for (Node n : f.nodes)
      if (n.num == ans)
        return n;
  return null;
}

public void EulerPath(Node cur) {
  for (Edge e : f.edges) {
    Node to = other(cur, e);
    if (to != null && !e.visited) {
      e.visited = true;
      EulerPath(to);
    }
  }
  EuAns.append(cur.num);
  println(cur.num);
}

public void checkFlash() {
  if (flash == 1) {
    background(flash_col);
    flash = 2;
  } else if (flash == 2) {
    flash = 0;
    delay(flash_time);
  }
}

public void marginLogEu() {
  if (EuAns != null)
    for (int i = 0; i < EuAns.size()-1; i++) {
      int from = EuAns.get(i);
      int to = EuAns.get(i+1);
      int sz = R_margin/5;
      textSize(sz);
      text(from + " " + to, L_margin+W+sz, (i+1)*sz);
    }
}

public void marginUpdate() {
  fill(margin_col);
  noStroke();
  rect(0, 0, L_margin, W);
  rect(L_margin+W, 0, R_margin, W);
  fill(text_col);
  f.marginLogEdges();
  marginLogEu();
}
class Node {
  int r;
  PVector pos, vel, acc;
  boolean act;
  int num, used;
  Node parent;

  Node(int _r, int _num) {
    r = _r;
    pos = new PVector(mouseX, mouseY);
    vel = acc = new PVector(0, 0);
    act = false;
    num = _num;
    used = 0;
    parent = null;
  }

  public void appForce(PVector force) {
    acc.add(force);
  }

  public void move() {
    vel.add(acc);
    //pos.add(vel);
    //PVector wanted = PVector.add(pos, vel);
    //pos.set(lerp(pos.x, wanted.x, 0.3), lerp(pos.y, wanted.y, 0.3));
    pos.lerp(PVector.add(pos, vel), 0.3f);
    acc.mult(0);
  }

  public PVector relate(Node n, boolean e) {
    PVector f = new PVector(0, 0);
    float dist = PVector.dist(pos, n.pos);

    if (!e) {
      if (dist < relation_dist) {
        f = PVector.sub(pos, n.pos);
        f.normalize();

        //if nodes are too close constrain the distance
        if (dist < crit_relation)
          dist = crit_relation;

        f.mult(relation_power/(dist*dist));
        //if nodes ideally overlap, move them a bit
        f.add(deltaF);
      } 
    } else {
        f = PVector.sub(pos, n.pos);
        f.normalize();
        f.mult(spring_coef*(des_edge_len - dist));
        
        //delta, in wich nodes do not relate
        if (abs(des_edge_len - dist) < 2)
          f.mult(0);
    }
    return f;
  }

  public void show() {
    if (act) {
      strokeWeight(str_weight_out_node);
      stroke(out_Node_col);
    } else
      noStroke();

    fill(in_Node_col);
    if (this.used == 1)
      fill(used1_Node_col);
    else if (this.used == 2)
      fill(used2_Node_col);

    ellipse(pos.x, pos.y, r, r);
    fill(text_col);
     textSize(text_size);
    text(num, pos.x - text_size/2, pos.y + text_size/4);
  }
}
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

  public void createNode() {
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

  public void changeEdge(Node u, Node v) {
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

  public void clearEdgeVisiting() {
    for (Edge e : edges)
      e.visited = false;
  }

  public void clearNodeUsage() {
    for (Node n : nodes)
      n.used = 0;
  }

  public void relate() {
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

  public void update() {
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

  public boolean bounds(int x, int y) {
    return (x > pos.x + Node_rad/2 && x < pos.x + a - Node_rad/2 &&
      y > pos.y + Node_rad/2 && y < pos.y + a - Node_rad/2);
  }

  public void marginLogEdges() {
    int sz = L_margin/5;
    int cnt = 1;
    for (int i = 0; i < maxn; i++) 
      for (int j = i+1; j < maxn; j++) 
        if (adj[i][j] != null) {
        textSize(sz);
        text(i + " " + j, sz, (cnt++)*sz);
      }
  }

  public Node checkOverlap() {
    for (Node n : nodes)
      if (dist(mouseX, mouseY, n.pos.x, n.pos.y) < Node_rad) {
        return n;
      }
    return null;
  }
}
  public void settings() {  size(1000, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "graph_editor" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
