class BarChart {
  int NUM_AIRPORTS = 20;

  color barColor;
  color barHoverColor;
  color bgColor;
  color textColor;
  color mutedText;
  color gridColor;

  float hoverMouseX;
  float hoverMouseY;
  int hoveredIndex;

  String[] airports;
  int[] counts;
  int maxCount;

  float marginL;
  float marginR;
  float marginT;
  float marginB;

  BarChart() {
    barColor = color(100, 140, 220);
    barHoverColor = color(74, 122, 214);
    bgColor = color(245);
    textColor = color(30);
    mutedText = color(90);
    gridColor = color(228);

    hoverMouseX = -1;
    hoverMouseY = -1;
    hoveredIndex = -1;

    maxCount = 1;

    marginL = 76;
    marginR = 36;
    marginT = 70;
    marginB = 82;
  }

  void setHoverMouse(float mx, float my) {
    hoverMouseX = mx;
    hoverMouseY = my;
  }

  String cleanCode(String value) {
    if (value == null) {
      return null;
    }
    String cleaned = trim(value);
    if (cleaned.length() == 0) {
      return null;
    }
    return cleaned;
  }

  void computeCounts(ArrayList<Flight> data) {
    java.util.HashMap<String, Integer> map = new java.util.HashMap<String, Integer>();

    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      String origin = cleanCode(f.origin);
      if (origin != null) {
        Integer current = map.get(origin);
        if (current == null) {
          map.put(origin, 1);
        } else {
          map.put(origin, current + 1);
        }
      }
    }

    java.util.ArrayList<java.util.Map.Entry<String, Integer>> entries =
      new java.util.ArrayList<java.util.Map.Entry<String, Integer>>(map.entrySet());

    java.util.Collections.sort(entries, new java.util.Comparator<java.util.Map.Entry<String, Integer>>() {
      public int compare(java.util.Map.Entry<String, Integer> a, java.util.Map.Entry<String, Integer> b) {
        return b.getValue() - a.getValue();
      }
    });

    int n = min(NUM_AIRPORTS, entries.size());
    airports = new String[n];
    counts = new int[n];

    maxCount = 1;

    for (int i = 0; i < n; i++) {
      airports[i] = entries.get(i).getKey();
      counts[i] = entries.get(i).getValue();
      if (counts[i] > maxCount) {
        maxCount = counts[i];
      }
    }
  }

  float getNiceStep(float value) {
    if (value <= 0) {
      return 1;
    }

    float exponent = pow(10, floor(log(value) / log(10)));
    float fraction = value / exponent;

    if (fraction <= 1) {
      return 1 * exponent;
    } else if (fraction <= 2) {
      return 2 * exponent;
    } else if (fraction <= 5) {
      return 5 * exponent;
    } else {
      return 10 * exponent;
    }
  }

  int getTotalFlights() {
    if (counts == null) {
      return 0;
    }

    int total = 0;
    for (int i = 0; i < counts.length; i++) {
      total += counts[i];
    }
    return total;
  }

  void drawTooltip(String code, int count, int total, float graphX, float graphY, float graphW, float graphH) {
    rectMode(CORNER);

    String line1 = code;
    String line2 = count + (count == 1 ? " flight" : " flights");
    String line3 = total > 0 ? nf((count * 100.0) / total, 0, 1) + "% of shown total" : "0.0% of shown total";

    textSize(12);
    float contentW = max(textWidth(line1), max(textWidth(line2), textWidth(line3)));
    float boxW = contentW + 24;
    float boxH = 66;

    float boxX = hoverMouseX + 14;
    float boxY = hoverMouseY - boxH - 10;

    boxX = constrain(boxX, graphX + 6, graphX + graphW - boxW - 6);
    boxY = constrain(boxY, graphY + 6, graphY + graphH - boxH - 6);

    noStroke();
    fill(0, 20);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);

    fill(255);
    rect(boxX, boxY, boxW, boxH, 8);

    stroke(220);
    strokeWeight(1);
    noFill();
    rect(boxX, boxY, boxW, boxH, 8);

    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(12);
    text(line1, boxX + 12, boxY + 10);
    text(line2, boxX + 12, boxY + 29);
    text(line3, boxX + 12, boxY + 48);
  }

  void drawTitle() {
    fill(textColor);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Flights by Origin Airport", width / 2, 30);
  }

  void drawGrid(float graphX, float graphY, float graphW, float graphH, float yMax, int stepCount, float yStep) {
    stroke(gridColor);
    strokeWeight(1);

    for (int i = 0; i <= stepCount; i++) {
      float y = map(i, 0, stepCount, graphY + graphH, graphY);
      line(graphX, y, graphX + graphW, y);

      fill(85);
      noStroke();
      textAlign(RIGHT, CENTER);
      textSize(11);
      text(str(int(i * yStep)), graphX - 10, y);

      stroke(gridColor);
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
    text("Origin Airport", graphX + graphW / 2, height - 25);

    pushMatrix();
    translate(24, graphY + graphH / 2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text("Number of Flights", 0, 0);
    popMatrix();
  }

  void drawBars(float graphX, float graphY, float graphW, float graphH, float yMax) {
    int n = airports.length;
    if (n == 0) {
      return;
    }

    float slotWidth = graphW / float(n);
    float gap = min(12, slotWidth * 0.22);
    float barWidth = max(6, slotWidth - gap);

    hoveredIndex = -1;

    int maxLabels = max(1, floor(graphW / 52.0));
    int labelInterval = max(1, ceil(n / float(maxLabels)));

    for (int i = 0; i < n; i++) {
      float barHeight = map(counts[i], 0, yMax, 0, graphH - 8);
      float barX = graphX + i * slotWidth + (slotWidth - barWidth) / 2.0;
      float barY = graphY + graphH - barHeight;

      boolean isHovered = hoverMouseX >= barX && hoverMouseX <= barX + barWidth &&
        hoverMouseY >= barY && hoverMouseY <= graphY + graphH;

      if (isHovered) {
        hoveredIndex = i;
      }

      noStroke();
      fill(isHovered ? barHoverColor : barColor);
      rect(barX, barY, barWidth, barHeight, 5, 5, 0, 0);

      if (counts[i] > 0 && barWidth >= 18) {
        textSize(10);

        if (barY - 6 >= graphY + 12) {
          fill(35);
          textAlign(CENTER, BOTTOM);
          text(str(counts[i]), barX + barWidth / 2, barY - 4);
        } else if (barHeight >= 18) {
          fill(255);
          textAlign(CENTER, TOP);
          text(str(counts[i]), barX + barWidth / 2, barY + 4);
        }
      }

      if (i % labelInterval == 0) {
        fill(60);
        noStroke();
        textAlign(CENTER, TOP);
        textSize(10);

        String label = airports[i];
        if (label == null) {
          label = "";
        }
        if (label.length() > 6) {
          label = label.substring(0, 6);
        }

        text(label, barX + barWidth / 2, graphY + graphH + 8);
      }
    }
  }

  void drawBarChart(ArrayList<Flight> data) {
    background(bgColor);
    rectMode(CORNER);
    computeCounts(data);

    drawTitle();

    float graphX = marginL;
    float graphY = marginT;
    float graphW = width - marginL - marginR;
    float graphH = height - marginT - marginB;

    if (airports == null || airports.length == 0) {
      fill(255);
      noStroke();
      rect(graphX, graphY, graphW, graphH, 8);

      fill(mutedText);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No data to display", width / 2, height / 2);
      return;
    }

    float roughStep = max(1, maxCount / 5.0);
    float yStep = getNiceStep(roughStep);
    float yMax = max(yStep, ceil(maxCount / yStep) * yStep);
    int stepCount = max(1, round(yMax / yStep));

    fill(255);
    noStroke();
    rect(graphX, graphY, graphW, graphH, 8);

    drawGrid(graphX, graphY, graphW, graphH, yMax, stepCount, yStep);
    drawAxes(graphX, graphY, graphW, graphH);
    drawBars(graphX, graphY, graphW, graphH, yMax);

    if (hoveredIndex != -1) {
      drawTooltip(airports[hoveredIndex], counts[hoveredIndex], getTotalFlights(), graphX, graphY, graphW, graphH);
    }
  }
}
