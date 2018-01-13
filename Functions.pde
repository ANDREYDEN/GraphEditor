Node other(Node n, Edge e) {
  if (n == e.A)
    return e.B;
  else if (n == e.B)
    return e.A;
  else
    return null;
}

Node EulerPath(Node cur) {
  delay(algItDelay);
  cur.used = 1;

  for (Edge e : f.edges) {
    Node to = other(cur, e);
    if (to != null && to.used == 0) {
      println(to.num);
      to.parent = cur;
      e.visible = false;
      return to;
    }
  } 
  for (Edge e : f.edges) {
    Node to = other(cur, e);
    if (to != null && e.visible) {
      e.visible = false;
      return cur;
    }
  }
  if (cur.parent != null && cur.parent.used == 1) {
    cur.used = 2;
    return cur.parent;
  } else
    return null;
}