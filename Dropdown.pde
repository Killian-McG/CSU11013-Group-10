class Dropdown {
  float x, y, w, h;
  String label;
  String[] options;

  int selectedIndex;
  boolean isOpen;
  int hoveredIndex;

  color bgColor;
  color borderColor;
  color hoverColor;
  color textColor;
  color labelColor;
  color arrowColor;
  color headerBg;
  color activeBorderColor;
  color selectedMarkColor;

  Dropdown(float x, float y, float w, float h, String label, String[] options) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.options = options;

    selectedIndex = 0;
    isOpen = false;
    hoveredIndex = -1;

    bgColor = color(255);
    borderColor = color(180);
    hoverColor = color(230, 240, 255);
    textColor = color(30);
    labelColor = color(100);
    arrowColor = color(80);
    headerBg = color(245);
    activeBorderColor = color(80, 120, 220);
    selectedMarkColor = color(80, 120, 220);
  }

  void display() {
    drawLabel();
    drawClosedBox();

    if (isOpen) {
      drawOptions();
    }
  }

  void drawLabel() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 4);
  }

  void drawClosedBox() {
    stroke(isOpen ? activeBorderColor : borderColor);
    strokeWeight(1);
    fill(headerBg);
    rect(x, y, w, h, 6);

    fill(textColor);
    noStroke();
    textSize(13);
    textAlign(LEFT, CENTER);

    if (options != null && options.length > 0) {
      text(options[selectedIndex], x + 12, y + h / 2);
    } else {
      text("No options", x + 12, y + h / 2);
    }

    fill(arrowColor);
    drawArrow(x + w - 18, y + h / 2, isOpen);
  }

  void drawOptions() {
    if (options == null || options.length == 0) return;

    for (int i = 0; i < options.length; i++) {
      float optionY = y + h + i * h;

      stroke(borderColor);
      strokeWeight(1);
      fill(i == hoveredIndex ? hoverColor : bgColor);
      rect(x, optionY, w, h);

      fill(textColor);
      noStroke();
      textSize(13);
      textAlign(LEFT, CENTER);
      text(options[i], x + 12, optionY + h / 2);

      if (i == selectedIndex) {
        fill(selectedMarkColor);
        textAlign(RIGHT, CENTER);
        text("✓", x + w - 10, optionY + h / 2);
      }
    }
  }

  void drawArrow(float cx, float cy, boolean open) {
    float s = 5;
    noStroke();

    if (open) {
      triangle(
        cx - s, cy + s / 2,
        cx + s, cy + s / 2,
        cx,     cy - s / 2
      );
    } else {
      triangle(
        cx - s, cy - s / 2,
        cx + s, cy - s / 2,
        cx,     cy + s / 2
      );
    }
  }

  void handleMousePressed() {
    if (isInsideHeader(mouseX, mouseY)) {
      isOpen = !isOpen;
      return;
    }

    if (isOpen) {
      int clickedIndex = getOptionIndexAt(mouseX, mouseY);

      if (clickedIndex != -1) {
        selectedIndex = clickedIndex;
      }

      isOpen = false;
    }
  }

  void handleMouseMoved() {
    hoveredIndex = -1;

    if (isOpen) {
      hoveredIndex = getOptionIndexAt(mouseX, mouseY);
    }
  }

  boolean isInsideHeader(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  int getOptionIndexAt(float mx, float my) {
    if (options == null) return -1;

    for (int i = 0; i < options.length; i++) {
      float optionY = y + h + i * h;

      if (mx >= x && mx <= x + w && my >= optionY && my <= optionY + h) {
        return i;
      }
    }

    return -1;
  }

  String getSelected() {
    if (options == null || options.length == 0) {
      return "";
    }
    return options[selectedIndex];
  }

  int getSelectedIndex() {
    return selectedIndex;
  }

  void setSelectedIndex(int index) {
    if (options != null && index >= 0 && index < options.length) {
      selectedIndex = index;
    }
  }

  void setOptions(String[] newOptions) {
    options = newOptions;
    selectedIndex = 0;
    hoveredIndex = -1;
    isOpen = false;
  }
}
