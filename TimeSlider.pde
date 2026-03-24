class TimeSlider {
  float x, y, w;
  String label;
  int totalMinutes = 0;

  color trackColor  = color(200);
  color fillColor   = color(80, 120, 220);
  color knobColor   = color(255);
  color knobBorder  = color(80, 120, 220);
  color textColor   = color(30);
  color labelColor  = color(100);
  color tickColor   = color(180);

  boolean dragging = false;
  float trackH = 4;
  float knobR  = 10;

  TimeSlider(float x, float y, float w, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.label = label;
  }

  void draw() {
    float knobX = x + (totalMinutes / 1439.0) * w;

    // Label
    fill(labelColor);
    noStroke();
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text(label, x, y - 22);

    // Time display
    fill(textColor);
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(getTime(), x, y - 6);

    // Hour ticks
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

    // Track background
    stroke(trackColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(x, y, x + w, y);

    // Track fill
    stroke(fillColor);
    strokeWeight(trackH);
    strokeCap(ROUND);
    line(x, y, knobX, y);

    // Knob
    fill(knobColor);
    stroke(knobBorder);
    strokeWeight(2);
    ellipse(knobX, y, knobR * 2, knobR * 2);
  }

  void mousePressed() {
    float knobX = x + (totalMinutes / 1439.0) * w;
    if (dist(mouseX, mouseY, knobX, y) <= knobR + 4) {
      dragging = true;
    }
  }

  void mouseDragged() {
    if (dragging) {
      float clamped = constrain(mouseX, x, x + w);
      totalMinutes = round(((clamped - x) / w) * 1439);
    }
  }

  void mouseReleased() {
    dragging = false;
  }

  // Snap to nearest N minutes (e.g. 15)
  void snapTo(int interval) {
    totalMinutes = round(totalMinutes / (float) interval) * interval;
    totalMinutes = constrain(totalMinutes, 0, 1439);
  }

  String getTime() {
    int h = totalMinutes / 60;
    int m = totalMinutes % 60;
    return nf(h, 2) + ":" + nf(m, 2);
  }

  int getHour()   { return totalMinutes / 60; }
  int getMinute() { return totalMinutes % 60; }
}


// =============================================
// Demo
// =============================================

TimeSlider sliderA;
TimeSlider sliderB;

void setup() {
  size(480, 280);
  smooth();

  sliderA = new TimeSlider(60, 110, 360, "Start Time");
  sliderB = new TimeSlider(60, 210, 360, "End Time");
  sliderB.totalMinutes = 1080; // default to 18:00
}

void draw() {
  background(245);

  fill(30);
  textSize(18);
  textAlign(LEFT, TOP);
  noStroke();
  text("Time Range", 60, 30);

  sliderA.draw();
  sliderB.draw();

  // Selected range readout
  fill(120);
  textSize(12);
  textAlign(LEFT, TOP);
  text(sliderA.getTime() + "  →  " + sliderB.getTime(), 60, 240);
}

void mousePressed()  { sliderA.mousePressed();  sliderB.mousePressed();  }
void mouseDragged()  { sliderA.mouseDragged();  sliderB.mouseDragged();  }
void mouseReleased() { sliderA.mouseReleased(); sliderB.mouseReleased(); }
