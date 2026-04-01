class ScatterPlot {
  final float marginL = 80;
  final float marginR = 40;
  final float marginT = 70;
  final float marginB = 80;

  color[] carrierColors = {
    color(100, 140, 220),
    color(78, 168, 128),
    color(232, 126, 76),
    color(203, 98, 145),
    color(196, 148, 70),
    color(136, 135, 128)
  };

  String[] carrierNames = { "AA", "AS", "B6", "HA", "NK", "Other" };

  float hoverMouseX = -1;
  float hoverMouseY = -1;
  int hoveredIndex = -1;

  ArrayList<ScatterPoint> points;

  ScatterPlot() {
    points = new ArrayList<ScatterPoint>();
  }

  void setHoverMouse(float mx, float my) {
    hoverMouseX = mx;
    hoverMouseY = my;
  }

  class ScatterPoint {
    Flight flight;
    float x, y;
    int scheduledMinutes, actualMinutes, delayMinutes;
    color pointColor;

    ScatterPoint(Flight flight, float x, float y,
        int scheduledMinutes, int actualMinutes, int delayMinutes,
        color pointColor) {
      this.flight = flight;
      this.x = x;
      this.y = y;
      this.scheduledMinutes = scheduledMinutes;
      this.actualMinutes = actualMinutes;
      this.delayMinutes = delayMinutes;
      this.pointColor = pointColor;
    }
  }

  float timeToFraction(int minutes) {
    return constrain(minutes / 1439.0, 0, 1);
  }

  int getAdjustedDelay(int scheduled, int actual) {
    int diff = actual - scheduled;
    if (diff < -720) diff += 1440;
    else if (diff > 720) diff -= 1440;
    return diff;
  }

  String formatTimeLabel(int minutes) {
    if (minutes < 0) return "N/A";
    return nf(minutes / 60, 2) + ":" + nf(minutes % 60, 2);
  }

  String formatDelay(int minutes) {
    if (minutes > 0) return "+" + minutes + " min";
    if (minutes < 0) return str(minutes) + " min";
    return "0 min";
  }

  String safeCode(String value, String fallback) {
    if (value == null) return fallback;
    String cleaned = trim(value);
    return cleaned.length() == 0 ? fallback : cleaned;
  }

  color getCarrierColor(String carrier) {
    if (carrier != null) {
      String cleaned = trim(carrier);
      for (int i = 0; i < carrierNames.length - 1; i++) {
        if (carrierNames[i].equals(cleaned)) return carrierColors[i];
      }
    }
    return carrierColors[carrierColors.length - 1];
  }

  void buildPoints(ArrayList<Flight> data, float graphX, float graphY, float graphW, float graphH) {
    points.clear();

    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      if (f.cancelled == 1) continue;

      int scheduledMinutes = parseTimeToMinutes(f.scheduledDepartureTime);
      int actualMinutes = parseTimeToMinutes(f.departureTime);
      if (scheduledMinutes < 0 || actualMinutes < 0) continue;

      float px = graphX + timeToFraction(scheduledMinutes) * graphW;
      float py = graphY + (1 - timeToFraction(actualMinutes)) * graphH;
      int delayMinutes = getAdjustedDelay(scheduledMinutes, actualMinutes);

      points.add(new ScatterPoint(
        f,
        px,
        py,
        scheduledMinutes,
        actualMinutes,
        delayMinutes,
        getCarrierColor(f.carrier)
      ));
    }
  }

  void findHoveredPoint() {
    hoveredIndex = -1;
    float bestDist = 10;
    for (int i = 0; i < points.size(); i++) {
      ScatterPoint p = points.get(i);
      float d = dist(hoverMouseX, hoverMouseY, p.x, p.y);
      if (d <= bestDist) {
        bestDist = d;
        hoveredIndex = i;
      }
    }
  }

  void drawGrid(float graphX, float graphY, float graphW, float graphH) {
    int[] tickMinutes = { 0, 240, 480, 720, 960, 1200, 1439 };
    String[] tickLabels = { "00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "23:59" };

    stroke(228);
    strokeWeight(1);
    for (int i = 0; i < tickMinutes.length; i++) {
      float frac = timeToFraction(tickMinutes[i]);
      float tx = graphX + frac * graphW;
      float ty = graphY + (1 - frac) * graphH;

      line(tx, graphY, tx, graphY + graphH);
      line(graphX, ty, graphX + graphW, ty);

      fill(85);
      noStroke();
      textSize(11);
      textAlign(CENTER, TOP);
      text(tickLabels[i], tx, graphY + graphH + 8);
      textAlign(RIGHT, CENTER);
      text(tickLabels[i], graphX - 8, ty);

      stroke(228);
      strokeWeight(1);
    }
  }

  void drawAxes(float graphX, float graphY, float graphW, float graphH) {
    stroke(60);
    strokeWeight(1.5);
    line(graphX, graphY, graphX, graphY + graphH);
    line(graphX, graphY + graphH, graphX + graphW, graphY + graphH);

    fill(40);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Scheduled Departure Time", graphX + graphW / 2, height - 25);

    pushMatrix();
    translate(24, graphY + graphH / 2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text("Actual Departure Time", 0, 0);
    popMatrix();
  }

  void drawReferenceLine(float graphX, float graphY, float graphW, float graphH) {
    stroke(185);
    strokeWeight(1.5);
    drawDashedLine(graphX, graphY + graphH, graphX + graphW, graphY, 8, 5);
  }

  void drawLegend(float graphX, float graphY, float graphW) {
    float startX = graphX + graphW - 180;
    float startY = graphY + 12;
    float colGap = 86;
    float rowGap = 22;

    for (int i = 0; i < carrierNames.length; i++) {
      float lx = startX + (i % 2) * colGap;
      float ly = startY + (i / 2) * rowGap;

      noStroke();
      fill(carrierColors[i]);
      ellipse(lx + 5, ly + 7, 8, 8);
      fill(70);
      textAlign(LEFT, CENTER);
      textSize(11);
      text(carrierNames[i], lx + 14, ly + 7);
    }
  }

  void drawPoints() {
    for (int i = 0; i < points.size(); i++) {
      if (i == hoveredIndex) continue;
      ScatterPoint p = points.get(i);
      noStroke();
      fill(red(p.pointColor), green(p.pointColor), blue(p.pointColor), 150);
      ellipse(p.x, p.y, 5, 5);
    }

    if (hoveredIndex != -1) {
      ScatterPoint p = points.get(hoveredIndex);
      stroke(255);
      strokeWeight(1.5);
      fill(p.pointColor);
      ellipse(p.x, p.y, 9, 9);
    }
  }

  void drawTooltip(ScatterPoint p, float graphX, float graphY, float graphW, float graphH) {
    rectMode(CORNER);

    String line1 = safeCode(p.flight.carrier, "Other") + "   "
        + safeCode(p.flight.origin, "N/A") + " -> "
        + safeCode(p.flight.destination, "N/A");
    String line2 = "Scheduled: " + formatTimeLabel(p.scheduledMinutes)
        + "   Actual: " + formatTimeLabel(p.actualMinutes);
    String line3 = "Delay: " + formatDelay(p.delayMinutes);

    textSize(12);
    float contentW = max(textWidth(line1), max(textWidth(line2), textWidth(line3)));
    float boxW = contentW + 24;
    float boxH = 66;
    float boxX = constrain(hoverMouseX + 14, graphX + 6, graphX + graphW - boxW - 6);
    float boxY = constrain(hoverMouseY - boxH - 10, graphY + 6, graphY + graphH - boxH - 6);

    noStroke();
    fill(0, 20);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);
    fill(255);
    rect(boxX, boxY, boxW, boxH, 8);
    stroke(220);
    strokeWeight(1);
    noFill();
    rect(boxX, boxY, boxW, boxH, 8);

    fill(30);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(12);
    text(line1, boxX + 12, boxY + 10);
    text(line2, boxX + 12, boxY + 29);
    text(line3, boxX + 12, boxY + 48);
  }

  void drawTitle() {
    fill(30);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Scheduled vs Actual Departure Time", width / 2, 30);
  }

  void drawScatterPlot(ArrayList<Flight> data) {
    background(245);
    rectMode(CORNER);

    float graphX = marginL;
    float graphY = marginT;
    float graphW = width - marginL - marginR;
    float graphH = height - marginT - marginB;

    buildPoints(data, graphX, graphY, graphW, graphH);
    findHoveredPoint();
    drawTitle();

    noStroke();
    fill(255);
    rect(graphX, graphY, graphW, graphH, 8);

    if (points.size() == 0) {
      fill(95);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No valid departure times to display", width / 2, height / 2);
      return;
    }

    drawGrid(graphX, graphY, graphW, graphH);
    drawReferenceLine(graphX, graphY, graphW, graphH);
    drawPoints();
    drawAxes(graphX, graphY, graphW, graphH);
    drawLegend(graphX, graphY, graphW);

    if (hoveredIndex != -1) {
      drawTooltip(points.get(hoveredIndex), graphX, graphY, graphW, graphH);
    }
  }

  void drawDashedLine(float x1, float y1, float x2, float y2, float dashLen, float gapLen) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    float total = sqrt(dx * dx + dy * dy);
    if (total == 0) return;

    float nx = dx / total;
    float ny = dy / total;
    float distCovered = 0;
    boolean drawing = true;

    while (distCovered < total) {
      float segLen = drawing ? dashLen : gapLen;
      float end = min(distCovered + segLen, total);
      if (drawing) {
        line(
          x1 + nx * distCovered,
          y1 + ny * distCovered,
          x1 + nx * end,
          y1 + ny * end
        );
      }
      distCovered = end;
      drawing = !drawing;
    }
  }
}
