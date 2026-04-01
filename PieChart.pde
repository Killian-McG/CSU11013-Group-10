class PieChart {
  float x;
  float y;
  float diameter;

  color onTimeColor;
  color lateColor;
  color cancelledColor;
  color textColor;
  color mutedText;
  color panelColor;
  color gridColor;

  float hoverMouseX;
  float hoverMouseY;
  int hoveredSlice;

  PieChart(float x, float y, float diameter) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;

    onTimeColor = color(100, 140, 220);
    lateColor = color(244, 170, 70);
    cancelledColor = color(214, 92, 92);
    textColor = color(30);
    mutedText = color(95);
    panelColor = color(255);
    gridColor = color(225);

    hoverMouseX = -1;
    hoverMouseY = -1;
    hoveredSlice = -1;
  }

  void setHoverMouse(float mx, float my) {
    hoverMouseX = mx;
    hoverMouseY = my;
  }

  int parseTimeToMinutes(String value) {
    if (value == null) {
      return -1;
    }

    String cleaned = trim(value);
    if (cleaned.length() == 0) {
      return -1;
    }

    if (cleaned.indexOf(':') != -1) {
      String[] parts = split(cleaned, ':');
      if (parts.length >= 2) {
        try {
          int h = Integer.parseInt(parts[0]);
          int m = Integer.parseInt(parts[1]);
          if (h >= 0 && h < 24 && m >= 0 && m < 60) {
            return h * 60 + m;
          }
        }
        catch (Exception e) {
          return -1;
        }
      }
      return -1;
    }

    String digits = "";
    for (int i = 0; i < cleaned.length(); i++) {
      char c = cleaned.charAt(i);
      if (c >= '0' && c <= '9') {
        digits += c;
      }
    }

    if (digits.length() == 0) {
      return -1;
    }

    try {
      int hhmm = Integer.parseInt(digits);
      int h = hhmm / 100;
      int m = hhmm % 100;
      if (h < 0 || h > 23 || m < 0 || m > 59) {
        return -1;
      }
      return h * 60 + m;
    }
    catch (Exception e) {
      return -1;
    }
  }

  String formatPercent(float value) {
    return nf(value * 100.0, 0, 1) + "%";
  }

  String getSliceLabel(int index) {
    if (index == 0) {
      return "On Time";
    }
    if (index == 1) {
      return "Late";
    }
    return "Cancelled";
  }

  color getSliceColor(int index) {
    if (index == 0) {
      return onTimeColor;
    }
    if (index == 1) {
      return lateColor;
    }
    return cancelledColor;
  }

  float normalizeAngle(float angle) {
    while (angle < 0) {
      angle += TWO_PI;
    }
    while (angle >= TWO_PI) {
      angle -= TWO_PI;
    }
    return angle;
  }

  boolean angleBetween(float angle, float start, float end) {
    angle = normalizeAngle(angle);
    start = normalizeAngle(start);
    end = normalizeAngle(end);

    if (start <= end) {
      return angle >= start && angle < end;
    }
    return angle >= start || angle < end;
  }

  void drawTooltip(String label, int count, float fraction, float graphX, float graphY, float graphW, float graphH) {
    rectMode(CORNER);

    String line1 = label;
    String line2 = count + (count == 1 ? " flight" : " flights");
    String line3 = formatPercent(fraction) + " of total";

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
    textAlign(LEFT, TOP);
    textSize(12);
    text(line1, boxX + 12, boxY + 10);
    text(line2, boxX + 12, boxY + 29);
    text(line3, boxX + 12, boxY + 48);
  }

  void drawLegendRow(float x, float y, float w, String label, int count, float fraction, color swatch, boolean active) {
    float rowH = 44;
    float swatchSize = 14;

    noStroke();
    fill(active ? color(246, 249, 255) : panelColor);
    rect(x, y, w, rowH, 10);

    stroke(active ? color(180, 198, 235) : gridColor);
    strokeWeight(1);
    noFill();
    rect(x, y, w, rowH, 10);

    noStroke();
    fill(swatch);
    rect(x + 12, y + 15, swatchSize, swatchSize, 4);

    fill(textColor);
    textAlign(LEFT, TOP);
    textSize(12);
    text(label, x + 34, y + 9, w - 120, 16);

    fill(mutedText);
    textSize(11);
    text(count + (count == 1 ? " flight" : " flights"), x + 34, y + 24, w - 120, 14);

    fill(textColor);
    textAlign(RIGHT, CENTER);
    textSize(12);
    text(formatPercent(fraction), x + w - 12, y + rowH / 2);
  }

  void display(ArrayList<Flight> flights) {
    background(245);
    rectMode(CORNER);
    hoveredSlice = -1;

    int onTime = 0;
    int late = 0;
    int cancelledCount = 0;

    for (int i = 0; i < flights.size(); i++) {
      Flight f = flights.get(i);

      if (f.cancelled == 1) {
        cancelledCount++;
      } else {
        int dep = parseTimeToMinutes(f.departureTime);
        int sched = parseTimeToMinutes(f.scheduledDepartureTime);

        if (dep >= 0 && sched >= 0) {
          if (dep <= sched) {
            onTime++;
          } else {
            late++;
          }
        }
      }
    }

    int totalCount = onTime + late + cancelledCount;

    fill(textColor);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Flight Status Breakdown", width / 2, 30);

    if (totalCount == 0) {
      fill(255);
      noStroke();
      rect(80, 70, width - 120, height - 150, 8);

      fill(mutedText);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No data to display", width / 2, height / 2);
      return;
    }

    float[] fractions = new float[3];
    fractions[0] = onTime / float(totalCount);
    fractions[1] = late / float(totalCount);
    fractions[2] = cancelledCount / float(totalCount);

    int[] counts = new int[3];
    counts[0] = onTime;
    counts[1] = late;
    counts[2] = cancelledCount;

    float leftMargin = 80;
    float rightMargin = 50;
    float topMargin = 70;
    float bottomMargin = 80;

    float graphX = leftMargin;
    float graphY = topMargin;
    float graphW = width - leftMargin - rightMargin;
    float graphH = height - topMargin - bottomMargin;

    fill(255);
    noStroke();
    rect(graphX, graphY, graphW, graphH, 8);

    float legendW = min(230, graphW * 0.34);
    float pieAreaW = graphW - legendW - 28;
    float pieDiameter = min(diameter, min(graphH - 36, pieAreaW - 30));
    pieDiameter = max(140, pieDiameter);

    float pieX = graphX + pieAreaW * 0.5;
    float pieY = graphY + graphH * 0.5 + 8;
    float radius = pieDiameter / 2.0;

    float legendX = graphX + pieAreaW + 28;
    float legendY = graphY + graphH * 0.5 - 72;
    float legendRowW = graphX + graphW - legendX;
    float legendRowH = 44;
    float legendGap = 12;

    float dx = hoverMouseX - pieX;
    float dy = hoverMouseY - pieY;
    float distToCenter = sqrt(dx * dx + dy * dy);

    if (distToCenter <= radius) {
      float mouseAngle = atan2(dy, dx);
      mouseAngle = normalizeAngle(mouseAngle);

      float startAngle = 0;
      for (int i = 0; i < 3; i++) {
        float sweep = fractions[i] * TWO_PI;
        if (sweep > 0 && angleBetween(mouseAngle, startAngle, startAngle + sweep)) {
          hoveredSlice = i;
          break;
        }
        startAngle += sweep;
      }
    }

    float startAngle = 0;
    for (int i = 0; i < 3; i++) {
      float sweep = fractions[i] * TWO_PI;
      if (sweep <= 0) {
        continue;
      }

      float midAngle = startAngle + sweep / 2.0;
      float offset = hoveredSlice == i ? 8 : 0;
      float sliceX = pieX + cos(midAngle) * offset;
      float sliceY = pieY + sin(midAngle) * offset;

      noStroke();
      fill(getSliceColor(i));
      arc(sliceX, sliceY, pieDiameter, pieDiameter, startAngle, startAngle + sweep, PIE);

      startAngle += sweep;
    }

    fill(255);
    noStroke();
    ellipse(pieX, pieY, pieDiameter * 0.42, pieDiameter * 0.42);

    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(str(totalCount), pieX, pieY - 6);

    fill(mutedText);
    textSize(11);
    text("total flights", pieX, pieY + 16);

    drawLegendRow(legendX, legendY, legendRowW, "On Time", onTime, fractions[0], onTimeColor, hoveredSlice == 0);
    drawLegendRow(legendX, legendY + legendRowH + legendGap, legendRowW, "Late", late, fractions[1], lateColor, hoveredSlice == 1);
    drawLegendRow(legendX, legendY + (legendRowH + legendGap) * 2, legendRowW, "Cancelled", cancelledCount, fractions[2], cancelledColor, hoveredSlice == 2);

    if (hoveredSlice != -1) {
      drawTooltip(getSliceLabel(hoveredSlice), counts[hoveredSlice], fractions[hoveredSlice], graphX, graphY, graphW, graphH);
    }
  }
}
