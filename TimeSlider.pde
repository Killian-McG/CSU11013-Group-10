class TimeSlider {
  float x, y, w;
  String label;

  int totalMinutes;
  boolean dragging;

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
    this.x = x;
    this.y = y;
    this.w = w;
    this.label = label;

    totalMinutes = 0;
    dragging = false;

    trackH = 4;
    knobR = 10;

    trackColor = color(200);
    fillColor = color(80, 120, 220);
    knobColor = color(255);
    knobBorder = color(80, 120, 220);
    textColor = color(30);
    labelColor = color(100);
    tickColor = color(180);
  }

  void display() {
    float knobX = getKnobX();

    drawLabel();
    drawTimeText();
    drawTicks();
    drawTrack(knobX);
    drawKnob(knobX);
  }

  void drawLabel() {
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 22);
  }

  void drawTimeText() {
    fill(textColor);
    noStroke();
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(getTime(), x, y - 6);
  }

  void drawTicks() {
    stroke(tickColor);
    strokeWeight(1);

    for (int h = 0; h <= 23; h++) {
      float tx = x + (h / 23.0) * w;
      float th = (h % 6 == 0) ? 6 : 3;

      line(tx, y + 2, tx, y + 2 + th);

      if (h % 6 == 0) {
        fill(tickColor);
        noStroke();
        textSize(9);
        textAlign(CENTER, TOP);
        text(h + ":00", tx, y + 10);
      }
    }
  }

  void drawTrack(float knobX) {
    stroke(trackColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(x, y, x + w, y);

    stroke(fillColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(x, y, knobX, y);
  }

  void drawKnob(float knobX) {
    fill(knobColor);
    stroke(knobBorder);
    strokeWeight(2);
    ellipse(knobX, y, knobR * 2, knobR * 2);
  }

  void handleMousePressed() {
    float knobX = getKnobX();

    if (dist(mouseX, mouseY, knobX, y) <= knobR + 4) {
      dragging = true;
    }
  }

  void handleMouseDragged() {
    if (dragging) {
      float clampedX = constrain(mouseX, x, x + w);
      totalMinutes = round(((clampedX - x) / w) * 1439);
      totalMinutes = constrain(totalMinutes, 0, 1439);
    }
  }

  void handleMouseReleased() {
    dragging = false;
  }

  float getKnobX() {
    return x + (totalMinutes / 1439.0) * w;
  }

  void snapTo(int interval) {
    totalMinutes = round(totalMinutes / (float) interval) * interval;
    totalMinutes = constrain(totalMinutes, 0, 1439);
  }

  String getTime() {
    int h = totalMinutes / 60;
    int m = totalMinutes % 60;
    return nf(h, 2) + ":" + nf(m, 2);
  }

  int getHour() {
    return totalMinutes / 60;
  }

  int getMinute() {
    return totalMinutes % 60;
  }

  int getTotalMinutes() {
    return totalMinutes;
  }

  void setTotalMinutes(int minutes) {
    totalMinutes = constrain(minutes, 0, 1439);
  }
}
