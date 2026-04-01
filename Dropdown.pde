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
  
  
  int scrollOffset = 0;
  int visibleRows = 6;
  float scrollY = 0;
  float targetScrollY = 0;
  
  boolean draggingScrollbar = false;
  float scrollbarGrabOffset = 0;
  
  float wheelStep = 18;
  float scrollEase = 0.22;

  Dropdown(float x, float y, float w, float h, String label, String[] options) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.options = options;
    selectedIndex = (options != null && options.length > 0) ? 0 : -1;
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
  updateScrollAnimation();

  drawLabel();
  drawClosedBox();

  if (isOpen) {
    drawVisibleOptions();
    drawScrollbar();
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
    if (options != null && options.length > 0 && selectedIndex >= 0) {
      text(options[selectedIndex], x + 12, y + h / 2);
    } else {
      text("No options", x + 12, y + h / 2);
    }
    fill(arrowColor);
    drawArrow(x + w - 18, y + h / 2, isOpen);
  }

  void drawVisibleOptions() {
  int totalVisible = min(visibleRows + 1, options.length);

  int firstIndex = floor(scrollY / h);
  float offsetY = scrollY - firstIndex * h;

  for (int i = 0; i < totalVisible; i++) {
    int optionIndex = firstIndex + i;
    if (optionIndex >= options.length) break;

    float itemY = round(y + h + i * h - offsetY);

  
    if (itemY + h < y + h) continue;
    if (itemY > y + h + visibleRows * h) continue;

    boolean hovered =
      mouseX >= x && mouseX <= x + w &&
      mouseY >= itemY && mouseY <= itemY + h;

    fill(hovered ? 230 : 255);
    stroke(180);
    rect(x, itemY, w, h);

    fill(0);
    textAlign(LEFT, CENTER);
    text(options[optionIndex], x + 10, itemY + h / 2);
  }
}

  void drawArrow(float cx, float cy, boolean isOpen) {
    float s = 5;
    noStroke();
    fill(arrowColor);
    if (isOpen) {
      triangle(cx - s, cy + s / 2, cx + s, cy + s / 2, cx, cy - s / 2);
    } else {
      triangle(cx - s, cy - s / 2, cx + s, cy - s / 2, cx, cy + s / 2);
    }
  }
  
  void jumpScrollbarToMouse() {
  float menuY = y + h;
  float menuH = visibleRows * h;
  float thumbH = getScrollbarThumbH();

  float totalContentH = options.length * h;
  float visibleH = visibleRows * h;
  float maxScroll = totalContentH - visibleH;

  float trackTravel = menuH - thumbH;
  if (trackTravel <= 0) return;

  float desiredThumbY = mouseY - thumbH / 2.0;
  desiredThumbY = constrain(desiredThumbY, menuY, menuY + trackTravel);

  float t = (desiredThumbY - menuY) / trackTravel;
  targetScrollY = t * maxScroll;
}

  void handleMousePressed() {
  if (mouseX >= x && mouseX <= x + w &&
      mouseY >= y && mouseY <= y + h) {
    isOpen = !isOpen;

    if (isOpen) {
      draggingScrollbar = false;
    }
    return;
  }

  
  if (isOpen && options.length > visibleRows) {
    if (isMouseOverScrollbarThumb()) {
      draggingScrollbar = true;
      scrollbarGrabOffset = mouseY - getScrollbarThumbY();
      return;
    }

    if (isMouseOverScrollbarTrack()) {
      jumpScrollbarToMouse();
      return;
    }
  }

  // click an option in the open menu
  if (isOpen && isMouseOverOpenMenu()) {
    int clickedIndex = floor((scrollY + (mouseY - (y + h))) / h);

    if (clickedIndex >= 0 && clickedIndex < options.length) {
      selectedIndex = clickedIndex;
    }

    draggingScrollbar = false;
    isOpen = false;
    return;
  }

  
  draggingScrollbar = false;
  isOpen = false;
}

  void handleMouseMoved() {
    hoveredIndex = -1;
    if (isOpen) {
      hoveredIndex = getOptionIndexAt(mouseX, mouseY);
    }
  }

  void handleMouseDragged() {
  if (!draggingScrollbar) return;

  float menuY = y + h;
  float menuH = visibleRows * h;
  float thumbH = getScrollbarThumbH();

  float totalContentH = options.length * h;
  float visibleH = visibleRows * h;
  float maxScroll = totalContentH - visibleH;

  float trackTravel = menuH - thumbH;
  if (trackTravel <= 0) return;

  float thumbY = mouseY - scrollbarGrabOffset;
  thumbY = constrain(thumbY, menuY, menuY + trackTravel);

  float t = (thumbY - menuY) / trackTravel;
  targetScrollY = t * maxScroll;
}

void handleMouseReleased() {
  draggingScrollbar = false;
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
    if (options == null || options.length == 0 || selectedIndex < 0) {
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
  
  boolean isMouseOverScrollbarTrack() {
  if (!isOpen || options.length <= visibleRows) return false;

  float menuY = y + h;
  float menuH = visibleRows * h;
  float trackX = x + w - 10;
  float trackW = 8;

  return mouseX >= trackX && mouseX <= trackX + trackW &&
         mouseY >= menuY && mouseY <= menuY + menuH;
}

  float getScrollbarThumbY() {
  float menuY = y + h;
  float menuH = visibleRows * h;
  float totalContentH = options.length * h;
  float visibleH = visibleRows * h;
  float maxScroll = totalContentH - visibleH;

  float thumbH = max(24, menuH * (visibleH / totalContentH));

  if (maxScroll <= 0) return menuY;
  return menuY + (menuH - thumbH) * (scrollY / maxScroll);
}

  float getScrollbarThumbH() {
  float menuH = visibleRows * h;
  float totalContentH = options.length * h;
  float visibleH = visibleRows * h;
  return max(24, menuH * (visibleH / totalContentH));
}

  boolean isMouseOverScrollbarThumb() {
  if (!isOpen || options.length <= visibleRows) return false;

  float trackX = x + w - 10;
  float trackW = 8;
  float thumbY = getScrollbarThumbY();
  float thumbH = getScrollbarThumbH();

  return mouseX >= trackX && mouseX <= trackX + trackW &&
         mouseY >= thumbY && mouseY <= thumbY + thumbH;
}

  void setOptions(String[] newOptions) {
    options = newOptions;
    selectedIndex = (newOptions != null && newOptions.length > 0) ? 0 : -1;
    hoveredIndex = -1;
    isOpen = false;
  }
  
  void updateScrollAnimation() {
  scrollY = lerp(scrollY, targetScrollY, scrollEase);

  float maxScroll = max(0, options.length * h - visibleRows * h);

  if (abs(scrollY - targetScrollY) < 0.3) {
    scrollY = targetScrollY;
  }

  scrollY = constrain(scrollY, 0, maxScroll);
  targetScrollY = constrain(targetScrollY, 0, maxScroll);
}
  
  boolean isMouseOverOpenMenu() {
  if (!isOpen) return false;

  float menuTop = y + h;
  float menuBottom = menuTop + min(visibleRows, options.length) * h;

  return mouseX >= x && mouseX <= x + w &&
         mouseY >= menuTop && mouseY <= menuBottom;
  }

  void handleMouseWheel(float amount) {
  if (!isOpen) return;
  if (!isMouseOverOpenMenu()) return;

  float maxScroll = max(0, options.length * h - visibleRows * h);

  targetScrollY += amount * wheelStep;
  targetScrollY = constrain(targetScrollY, 0, maxScroll);
  }
  
  
  void drawOpenMenu() {
  int rowsShown = min(visibleRows, options.length);

  for (int i = 0; i < rowsShown; i++) {
    int optionIndex = i + scrollOffset;
    float itemY = y + h + i * h;

    if (optionIndex >= options.length) break;

    boolean hovered =
      mouseX >= x && mouseX <= x + w &&
      mouseY >= itemY && mouseY <= itemY + h;

    fill(hovered ? 230 : 255);
    stroke(180);
    rect(x, itemY, w, h);

    fill(0);
    text(options[optionIndex], x + 10, itemY + h / 2);
  }

  drawScrollbar();
}

  void drawScrollbar() {
  if (options.length <= visibleRows) return;

  float menuY = y + h;
  float menuH = visibleRows * h;

  float trackX = x + w - 10;
  float trackW = 8;

  float totalContentH = options.length * h;
  float visibleH = visibleRows * h;
  float maxScroll = totalContentH - visibleH;

  float thumbH = max(24, menuH * (visibleH / totalContentH));
  float thumbY = menuY;

  if (maxScroll > 0) {
    thumbY = menuY + (menuH - thumbH) * (scrollY / maxScroll);
  }

  noStroke();
  fill(235);
  rect(trackX, menuY, trackW, menuH, 4);

  fill(draggingScrollbar ? 120 : 160);
  rect(trackX, thumbY, trackW, thumbH, 4);
  }
}
