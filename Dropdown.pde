// MAIN AUTHOR: Calvin - Week 2

// DROPDOWN
//   Dropdown, scollable input list
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

  int visibleRows = 6;
  float scrollY = 0;
  float targetScrollY = 0;

  boolean draggingScrollbar = false;
  float scrollbarGrabOffset = 0;

  float wheelStep = 18;
  float scrollEase = 0.22;

  // Constructor – creates the drop-down at position (x, y) with the given
  // width, height, label text, and list of option strings
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

  // Renders all visible parts of the widget
  void display() {
    
    // Smooth scrolling makes menu feel less jumpy
    updateScrollAnimation();
    drawLabel();
    drawClosedBox();

    if (isOpen) {
      drawVisibleOptions();
      drawScrollbar();
    }
  }

  //  Draws the small label text above the header box
  void drawLabel() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 4);
  }

  // Draws the closed header rectangle with the selected option text and arrow
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

  // Draws the visible rows of options below the header
  void drawVisibleOptions() {
    // Draws one extra row past the visible area so scrolling does not show gaps at the edge
    int totalVisible = min(visibleRows + 1, options.length);
    int firstIndex = floor(scrollY / h);
    float offsetY = scrollY - firstIndex * h;

    for (int i = 0; i < totalVisible; i++) {
      int optionIndex = firstIndex + i;
      if (optionIndex >= options.length) break;

      float itemY = round(y + h + i * h - offsetY);
      if (itemY + h < y + h) continue;
      if (itemY > y + h + visibleRows * h) continue;

      boolean hovered = mouseX >= x && mouseX <= x + w
          && mouseY >= itemY && mouseY <= itemY + h;

      fill(hovered ? 230 : 255);
      stroke(180);
      rect(x, itemY, w, h);

      fill(0);
      textAlign(LEFT, CENTER);
      text(options[optionIndex], x + 10, itemY + h / 2);
    }
  }

  // Draws the small triangle arrow icon
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

  // Draws the scrollbar track and draggable thumb on the right side of the list
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

  // Each frame, gently moves scrollY toward targetScrollY using linear interpolation
  void updateScrollAnimation() {
    scrollY = lerp(scrollY, targetScrollY, scrollEase);

    float maxScroll = max(0, options.length * h - visibleRows * h);

    if (abs(scrollY - targetScrollY) < 0.3) {
      scrollY = targetScrollY;
    }

    scrollY = constrain(scrollY, 0, maxScroll);
    targetScrollY = constrain(targetScrollY, 0, maxScroll);
  }

  // Mouse pressed event handler
  void handleMousePressed() {
    // First click opens/closes the header
    if (mouseX >= x && mouseX <= x + w
        && mouseY >= y && mouseY <= y + h) {
      isOpen = !isOpen;
      if (isOpen) draggingScrollbar = false;
      return;
    }

    if (isOpen && options.length > visibleRows) {
      if (isMouseOverScrollbarThumb()) {
        // Remembers where the grab started so the thumb does not snap under the mouse
        draggingScrollbar = true;
        scrollbarGrabOffset = mouseY - getScrollbarThumbY();
        return;
      }

      if (isMouseOverScrollbarTrack()) {
        jumpScrollbarToMouse();
        return;
      }
    }

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

  // Mouse moved event handler
  void handleMouseMoved() {
    hoveredIndex = -1;
    if (isOpen) {
      hoveredIndex = getOptionIndexAt(mouseX, mouseY);
    }
  }

  // Mouse dragged event handler
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

    targetScrollY = ((thumbY - menuY) / trackTravel) * maxScroll;
  }

  // Mouse released event handler
  void handleMouseReleased() {
    draggingScrollbar = false;
  }

  // Mouse wheel event handler
  void handleMouseWheel(float amount) {
    if (!isOpen || !isMouseOverOpenMenu()) return;

    float maxScroll = max(0, options.length * h - visibleRows * h);
    targetScrollY = constrain(targetScrollY + amount * wheelStep, 0, maxScroll);
  }

  // Clicking the track moves the thumb toward the mouse, similar to a native scroll bar
  void jumpScrollbarToMouse() {
    float menuY = y + h;
    float menuH = visibleRows * h;

    float thumbH = getScrollbarThumbH();
    float totalContentH = options.length * h;
    float visibleH = visibleRows * h;
    float maxScroll = totalContentH - visibleH;

    float trackTravel = menuH - thumbH;
    if (trackTravel <= 0) return;

    float desiredThumbY = constrain(mouseY - thumbH / 2.0, menuY, menuY + trackTravel);
    targetScrollY = ((desiredThumbY - menuY) / trackTravel) * maxScroll;
  }

  // Returns true if the mouse is over the scrollbar track area
  boolean isMouseOverScrollbarTrack() {
    if (!isOpen || options.length <= visibleRows) return false;

    float menuY = y + h;
    float menuH = visibleRows * h;
    float trackX = x + w - 10;

    return mouseX >= trackX && mouseX <= trackX + 8
        && mouseY >= menuY && mouseY <= menuY + menuH;
  }

  // Returns the pixel y-coordinate of the top of the scrollbar thumb
  float getScrollbarThumbY() {
    float menuY = y + h;
    float menuH = visibleRows * h;

    float totalContentH = options.length * h;
    float visibleH = visibleRows * h;
    float maxScroll = totalContentH - visibleH;

    float thumbH = getScrollbarThumbH();

    if (maxScroll <= 0) return menuY;

    return menuY + (menuH - thumbH) * (scrollY / maxScroll);
  }

  // Returns the pixel height of the scrollbar thumb
  float getScrollbarThumbH() {
    float menuH = visibleRows * h;
    float totalContentH = options.length * h;
    float visibleH = visibleRows * h;

    return max(24, menuH * (visibleH / totalContentH));
  }

  // Returns true if the mouse is directly over the scrollbar thumb
  boolean isMouseOverScrollbarThumb() {
    if (!isOpen || options.length <= visibleRows) return false;

    float trackX = x + w - 10;
    float thumbY = getScrollbarThumbY();
    float thumbH = getScrollbarThumbH();

    return mouseX >= trackX && mouseX <= trackX + 8
        && mouseY >= thumbY && mouseY <= thumbY + thumbH;
  }

  // Returns true if the mouse is inside the visible option list area
  boolean isMouseOverOpenMenu() {
    if (!isOpen) return false;

    float menuTop = y + h;
    float menuBottom = menuTop + min(visibleRows, options.length) * h;

    return mouseX >= x && mouseX <= x + w
        && mouseY >= menuTop && mouseY <= menuBottom;
  }

  int getOptionIndexAt(float mx, float my) {
    if (options == null) return -1;

    // Mainly used for hover state
    for (int i = 0; i < options.length; i++) {
      float optionY = y + h + i * h;

      if (mx >= x && mx <= x + w
          && my >= optionY && my <= optionY + h) {
        return i;
      }
    }

    return -1;
  }

  // Returns the string value of the currently selected option
  String getSelected() {
    if (options == null || options.length == 0 || selectedIndex < 0) {
      return "";
    }

    return options[selectedIndex];
  }
  
  // Returns the numeric index of the currently selected option
  int getSelectedIndex() {
    return selectedIndex;
  }

  // selects an option by index
  void setSelectedIndex(int index) {
    if (options != null && index >= 0 && index < options.length) {
      selectedIndex = index;
    }
  }

  // Replaces the option list entirely
  void setOptions(String[] newOptions) {
    options = newOptions;
    selectedIndex = (newOptions != null && newOptions.length > 0) ? 0 : -1;
    hoveredIndex = -1;
    isOpen = false;
  }
}
