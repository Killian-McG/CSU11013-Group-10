class CheckBox {

  float x, y, size;
  boolean checked;
  String label;

  CheckBox(float x, float y, float size, String label) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.label = label;
    this.checked = false;
  }

  void display() {
    stroke(180);
    strokeWeight(1.5);
    fill(255);
    rect(x, y, size, size, 6);

    if (checked) {
      fill(0, 120, 255);
      noStroke();
      rect(x, y, size, size, 6);

      stroke(255);
      strokeWeight(3);
      line(x + size*0.25, y + size*0.55, x + size*0.45, y + size*0.75);
      line(x + size*0.45, y + size*0.75, x + size*0.75, y + size*0.3);
    }

    fill(0);
    noStroke();
    textSize(20);
    text(label, x + size + 15, y + size*0.7);
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + size &&
           mouseY >= y && mouseY <= y + size;
  }

  void setChecked(boolean value) {
    checked = value;
  }

  boolean isChecked() {
    return checked;
  }
}
