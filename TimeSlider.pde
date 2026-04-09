// MAIN AUTHOR: Calvin - Week 3

// TIME SLIDER
//   SLider for user to input data during search in relation to time periods

class TimeSlider {
  // Position of the slider on screen
  float x, y, w;
  String label;

  int startMinutes;
  int endMinutes;
  int activeKnob;

  float trackH;
  float knobR;

  color trackColor;
  color fillColor;
  color knobColor;
  color knobBorder;
  color textColor;
  color labelColor;
  color tickColor;

  // Constructor stores position/size and sets default colours and starting time range
  TimeSlider(float x, float y, float w, String label) {
    this.x     = x;
    this.y     = y;
    this.w     = w;
    this.label = label;

    startMinutes = 480;
    endMinutes   = 1020;
    activeKnob   = 0;

    trackH = 6;
    knobR  = 6;

    trackColor = color(220);
    fillColor  = color(70, 120, 230);
    knobColor  = color(255);
    knobBorder = color(70, 120, 230);
    textColor  = color(25);
    labelColor = color(110);
    tickColor  = color(180);
  }

  // Draws all parts of the slider from back to front
  void display() {
    float startX = getKnobX(startMinutes);
    float endX   = getKnobX(endMinutes);

    drawLabel();
    drawTicks();
    drawTrack(startX, endX);
    drawKnob(startX);
    drawKnob(endX);
  }

  // Draws the small text label above the track
  void drawLabel() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 22);
  }

  // Draws small vertical tick marks every hour and longer marks every 6 hours
  void drawTicks() {
    stroke(tickColor);
    strokeWeight(1);

    for (int h = 0; h <= 23; h++) {
      float tx = getKnobX(h * 60);
      float th = (h % 6 == 0) ? 6 : 3;

      line(tx, y + 8, tx, y + 8 + th);

      if (h % 6 == 0) {
        fill(tickColor);
        noStroke();
        textSize(9);
        textAlign(CENTER, TOP);
        text(nf(h, 2) + ":00", tx, y + 16);
      }
    }
  }

  // Draws the track: first the full grey line, then the blue highlight between the two knobs
  void drawTrack(float startX, float endX) {
    stroke(trackColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(x, y, x + w, y);

    stroke(fillColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(startX, y, endX, y);
  }

  // Draws a single circular knob
  void drawKnob(float knobX) {
    fill(knobColor);
    stroke(knobBorder);
    strokeWeight(2);
    ellipse(knobX, y, knobR * 2, knobR * 2);
  }

  // Mouse pressed event handling
  void handleMousePressed() {
    float startX = getKnobX(startMinutes);
    float endX   = getKnobX(endMinutes);

    float dStart = dist(mouseX, mouseY, startX, y);
    float dEnd   = dist(mouseX, mouseY, endX,   y);

    if (dStart <= knobR + 6 || dEnd <= knobR + 6) {
      activeKnob = (dStart <= dEnd) ? 1 : 2;
    } else if (mouseX >= x && mouseX <= x + w && abs(mouseY - y) <= 12) {
      activeKnob = (abs(mouseX - startX) <= abs(mouseX - endX)) ? 1 : 2;
      updateActiveKnob();
    }
  }

  // Mouse dragged event handling
  void handleMouseDragged() {
    if (activeKnob != 0) updateActiveKnob();
  }

  // Mouse released event handling
  void handleMouseReleased() {
    activeKnob = 0;
  }

  // Converts the mouse's current x position into a minute value and assigns it to the correct knob
  void updateActiveKnob() {
    int minutes = xToMinutes(constrain(mouseX, x, x + w));
    if (activeKnob == 1) startMinutes = constrain(minutes, 0, endMinutes);
    else if (activeKnob == 2) endMinutes = constrain(minutes, startMinutes, 1439);
  }

  // Returns knob x value
  float getKnobX(int minutes) {
    return x + (minutes / 1439.0) * w;
  }

  // Return x value in minutes
  int xToMinutes(float px) {
    return round(((px - x) / w) * 1439);
  }

  // Sets the selected range
  void setInterval(int start, int end) {
    startMinutes = constrain(min(start, end), 0, 1439);
    endMinutes   = constrain(max(start, end), 0, 1439);
  }

  // Returns the selected start time in minutes from midnight
  int getStartTotalMinutes() { return startMinutes; }
  // Returns the selected end time in minutes from midnight
  int getEndTotalMinutes()   { return endMinutes;   }
}
