Node other(Node n, Edge e) {
  if (n == e.A)
    return e.B;
  else if (n == e.B)
    return e.A;
  else
    return null;
}

Node EulerStart() {
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

void EulerPath(Node cur) {
  for (Edge e : f.edges) {
    Node to = other(cur, e);
    if (to != null && e.visible) {
      e.visible = false;
      EulerPath(to);
    }
  }
  EuAns.append(cur.num);
  println(cur.num);
}