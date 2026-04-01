class TimeSlider {
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

  // ── Display ───────────────────────────────────────────────────────────────

  void display() {
    float startX = getKnobX(startMinutes);
    float endX   = getKnobX(endMinutes);

    drawLabel();
    drawTicks();
    drawTrack(startX, endX);
    drawKnob(startX);
    drawKnob(endX);
  }

  void drawLabel() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 22);
  }

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

  void drawKnob(float knobX) {
    fill(knobColor);
    stroke(knobBorder);
    strokeWeight(2);
    ellipse(knobX, y, knobR * 2, knobR * 2);
  }

  // ── Mouse handling ────────────────────────────────────────────────────────

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

  void handleMouseDragged() {
    if (activeKnob != 0) updateActiveKnob();
  }

  void handleMouseReleased() {
    activeKnob = 0;
  }

  void updateActiveKnob() {
    int minutes = xToMinutes(constrain(mouseX, x, x + w));
    if (activeKnob == 1) startMinutes = constrain(minutes, 0, endMinutes);
    else if (activeKnob == 2) endMinutes = constrain(minutes, startMinutes, 1439);
  }

  // ── Geometry helpers ──────────────────────────────────────────────────────

  float getKnobX(int minutes) {
    return x + (minutes / 1439.0) * w;
  }

  int xToMinutes(float px) {
    return round(((px - x) / w) * 1439);
  }

  // ── Setters / getters used externally ────────────────────────────────────

  void setInterval(int start, int end) {
    startMinutes = constrain(min(start, end), 0, 1439);
    endMinutes   = constrain(max(start, end), 0, 1439);
  }

  int getStartTotalMinutes() { return startMinutes; }
  int getEndTotalMinutes()   { return endMinutes;   }
}
