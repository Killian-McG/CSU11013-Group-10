class Dropdown {
  float x, y, w, h;
  String label;
  String[] options;
  int selectedIndex = 0;
  boolean isOpen = false;

  color bgColor     = color(255);
  color borderColor = color(180);
  color hoverColor  = color(230, 240, 255);
  color textColor   = color(30);
  color labelColor  = color(100);
  color arrowColor  = color(80);
  color headerBg    = color(245);

  int hoveredIndex = -1;
  float itemH;

  Dropdown(float x, float y, float w, float h, String label, String[] options) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.options = options;
    this.itemH = h;
  }

  void draw() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 4);

    stroke(isOpen ? color(80, 120, 220) : borderColor);
    strokeWeight(1);
    fill(headerBg);
    rect(x, y, w, h, 6);

    fill(textColor);
    textSize(13);
    textAlign(LEFT, CENTER);
    text(options[selectedIndex], x + 12, y + h / 2);

    fill(arrowColor);
    noStroke();
    drawArrow(x + w - 22, y + h / 2, isOpen);

    if (isOpen) {
      stroke(borderColor);
      strokeWeight(1);
      for (int i = 0; i < options.length; i++) {
        float iy = y + h + i * itemH;
        boolean hovered = (i == hoveredIndex);
        fill(hovered ? hoverColor : bgColor);
        rect(x, iy, w, itemH);

        fill(textColor);
        noStroke();
        textSize(13);
        textAlign(LEFT, CENTER);
        text(options[i], x + 12, iy + itemH / 2);

        if (i == selectedIndex) {
          fill(color(80, 120, 220));
          textAlign(RIGHT, CENTER);
          text("✓", x + w - 10, iy + itemH / 2);
        }
      }
    }
  }

  void drawArrow(float cx, float cy, boolean up) {
    float s = 5;
    if (up) {
      triangle(cx - s, cy + s/2, cx + s, cy + s/2, cx, cy - s/2);
    } else {
      triangle(cx - s, cy - s/2, cx + s, cy - s/2, cx, cy + s/2);
    }
  }

  void mousePressed() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      isOpen = !isOpen;
    } else if (isOpen) {
      for (int i = 0; i < options.length; i++) {
        float iy = y + h + i * itemH;
        if (mouseX >= x && mouseX <= x + w && mouseY >= iy && mouseY <= iy + itemH) {
          selectedIndex = i;
          isOpen = false;
          return;
        }
      }
      isOpen = false;
    }
  }

  void mouseMoved() {
    hoveredIndex = -1;
    if (isOpen) {
      for (int i = 0; i < options.length; i++) {
        float iy = y + h + i * itemH;
        if (mouseX >= x && mouseX <= x + w && mouseY >= iy && mouseY <= iy + itemH) {
          hoveredIndex = i;
        }
      }
    }
  }

  String getSelected() {
    return options[selectedIndex];
  }
}


// =============================================
// Demo
// =============================================

Dropdown dropdownA;
Dropdown dropdownB;

void setup() {
  size(400, 350);
  smooth();

  String[] optionsA = {
    "Option A",
    "Option B",
    "Option C",
    "Option D",
    "Option E"
  };

  String[] optionsB = {
    "Item 1",
    "Item 2",
    "Item 3",
    "Item 4"
  };

  dropdownA = new Dropdown(80, 80,  240, 36, "Label One", optionsA);
  dropdownB = new Dropdown(80, 200, 240, 36, "Label Two", optionsB);
}

void draw() {
  background(245);

  // Draw bottom dropdown first so top one's list overlaps it
  dropdownB.draw();
  dropdownA.draw();
}

void mousePressed() {
  dropdownA.mousePressed();
  dropdownB.mousePressed();
}

void mouseMoved() {
  dropdownA.mouseMoved();
  dropdownB.mouseMoved();
}
