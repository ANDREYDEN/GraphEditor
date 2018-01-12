void sep(Node n1, Node n2) {
  float dist = PVector.dist(n1.pos, n2.pos);
  PVector f = PVector.sub(n1.pos, n2.pos);
  f = f.mult(relation_power/(dist*dist));
  n1.appForce(f);
  n2.appForce(f.mult(-1));
}

void sep(Node n1, PVector P) {
  Node n2 = new Node(0, 0);
  n2.pos.set(P);
  sep(n1, n2);
}

Node other(Node n, Edge e) {
  if (n == e.A)
    return e.B;
  else if (n == e.B)
    return e.A;
  else
    return null;
}

Node EulerPath(Node cur) {
  delay(500);
  boolean check = false;
  cur.used = true;
  for (Edge e : f.edges) {
    Node to = other(cur, e);
    if (to != null) {
      if (!to.used) {
        println(to.num);
        to.parent = cur;  
        check = true;
        e.visible = false;
        return to;
      } else if (e.visible) {
        e.visible = false;
        return cur;
      }
    }
  } 
  if (!check) 
    if (cur.parent != null)
      return cur.parent;
    else
      return null;
  return null;
}