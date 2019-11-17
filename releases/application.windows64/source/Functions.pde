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
    if (to != null && !e.visited) {
      e.visited = true;
      EulerPath(to);
    }
  }
  EuAns.append(cur.num);
  println(cur.num);
}

void checkFlash() {
  if (flash == 1) {
    background(flash_col);
    flash = 2;
  } else if (flash == 2) {
    flash = 0;
    delay(flash_time);
  }
}

void marginLogEu() {
  if (EuAns != null)
    for (int i = 0; i < EuAns.size()-1; i++) {
      int from = EuAns.get(i);
      int to = EuAns.get(i+1);
      int sz = R_margin/5;
      textSize(sz);
      text(from + " " + to, L_margin+W+sz, (i+1)*sz);
    }
}

void marginUpdate() {
  fill(margin_col);
  noStroke();
  rect(0, 0, L_margin, W);
  rect(L_margin+W, 0, R_margin, W);
  fill(text_col);
  f.marginLogEdges();
  marginLogEu();
}
