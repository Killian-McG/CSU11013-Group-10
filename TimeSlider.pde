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
    this.x = x;
    this.y = y;
    this.w = w;
    this.label = label;

    startMinutes = 480;
    endMinutes = 1020;
    activeKnob = 0;

    trackH = 6;
    knobR = 6;

    trackColor = color(220);
    fillColor = color(70, 120, 230);
    knobColor = color(255);
    knobBorder = color(70, 120, 230);
    textColor = color(25);
    labelColor = color(110);
    tickColor = color(180);
  }

  void display() {
    float startX = getKnobX(startMinutes);
    float endX = getKnobX(endMinutes);

    drawLabel();
    drawTimeText();
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

  void drawTimeText() {
    fill(textColor);
    noStroke();
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(getStartTime() + " - " + getEndTime(), x, y - 6);
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

  void handleMousePressed() {
    float startX = getKnobX(startMinutes);
    float endX = getKnobX(endMinutes);

    float dStart = dist(mouseX, mouseY, startX, y);
    float dEnd = dist(mouseX, mouseY, endX, y);

    if (dStart <= knobR + 6 || dEnd <= knobR + 6) {
      activeKnob = (dStart <= dEnd) ? 1 : 2;
    } else if (mouseX >= x && mouseX <= x + w && abs(mouseY - y) <= 12) {
      activeKnob = (abs(mouseX - startX) <= abs(mouseX - endX)) ? 1 : 2;
      updateActiveKnob();
    }
  }

  void handleMouseDragged() {
    if (activeKnob != 0) {
      updateActiveKnob();
    }
  }

  void handleMouseReleased() {
    activeKnob = 0;
  }

  void updateActiveKnob() {
    int minutes = xToMinutes(constrain(mouseX, x, x + w));

    if (activeKnob == 1) {
      startMinutes = constrain(minutes, 0, endMinutes);
    } else if (activeKnob == 2) {
      endMinutes = constrain(minutes, startMinutes, 1439);
    }
  }

  float getKnobX(int minutes) {
    return x + (minutes / 1439.0) * w;
  }

  int xToMinutes(float px) {
    return round(((px - x) / w) * 1439);
  }

  void snapTo(int interval) {
    startMinutes = round(startMinutes / (float) interval) * interval;
    endMinutes = round(endMinutes / (float) interval) * interval;

    startMinutes = constrain(startMinutes, 0, 1439);
    endMinutes = constrain(endMinutes, startMinutes, 1439);
  }

  String formatTime(int total) {
    int h = total / 60;
    int m = total % 60;
    return nf(h, 2) + ":" + nf(m, 2);
  }

  String getStartTime() {
    return formatTime(startMinutes);
  }

  String getEndTime() {
    return formatTime(endMinutes);
  }

  int getStartHour() {
    return startMinutes / 60;
  }

  int getStartMinute() {
    return startMinutes % 60;
  }

  int getEndHour() {
    return endMinutes / 60;
  }

  int getEndMinute() {
    return endMinutes % 60;
  }

  int getStartTotalMinutes() {
    return startMinutes;
  }

  int getEndTotalMinutes() {
    return endMinutes;
  }

  int getDurationMinutes() {
    return endMinutes - startMinutes;
  }

  void setStartMinutes(int minutes) {
    startMinutes = constrain(minutes, 0, endMinutes);
  }

  void setEndMinutes(int minutes) {
    endMinutes = constrain(minutes, startMinutes, 1439);
  }

  void setInterval(int start, int end) {
    startMinutes = constrain(min(start, end), 0, 1439);
    endMinutes = constrain(max(start, end), 0, 1439);
  }
}
