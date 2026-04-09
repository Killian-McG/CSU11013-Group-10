// MAIN AUTHOR: Matthew - Week 2

//  Button
//    Click button used across search and results screens

class Button {

  float x, y, w, h;
  String label;
  boolean hovered;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  // Displays button and calculates hover state
  void display() {

    hovered = isMouseOver();

    noStroke();

    if (hovered) {
      fill(0, 120, 255);
    } else {
      fill(0, 100, 220);
    }

    rect(x, y, w, h, 12);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(label, x + w/2, y + h/2);
  }

  // Mouse position checker
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }

  // Button clicked
  boolean isClicked() {
    return isMouseOver();
  }
}
