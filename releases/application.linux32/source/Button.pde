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

  void change() {
    if (mouseX > pos.x && mouseX < pos.x + w &&
      mouseY > pos.y && mouseY < pos.y + w) {
      on = !on;
      physics_enable = on;
    }
  }

  void show() {
    noStroke();
    if (on) 
      fill(Button_on_col);
    else
      fill(Button_off_col);
    rect(pos.x, pos.y, w, h);
    float sz = float(w/txt.length());
    textSize(sz);
    fill(text_col);
    text(txt, pos.x + sz, pos.y + sz);
  }
}
