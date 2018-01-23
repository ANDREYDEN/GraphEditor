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

  void appForce(PVector force) {
    acc.add(force);
  }

  void move() {
    vel.add(acc);
    //pos.add(vel);
    //PVector wanted = PVector.add(pos, vel);
    //pos.set(lerp(pos.x, wanted.x, 0.3), lerp(pos.y, wanted.y, 0.3));
    pos.lerp(PVector.add(pos, vel), 0.3);
    acc.mult(0);
  }

  PVector relate(Node n, boolean e) {
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

  void show() {
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