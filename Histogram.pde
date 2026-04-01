class Histogram {
  int[] hourCounts;
  int hoveredHour;

  float hoverMouseX;
  float hoverMouseY;

  Histogram() {
    hourCounts = new int[24];
    hoveredHour = -1;
    hoverMouseX = -1;
    hoverMouseY = -1;
  }

  void setHoverMouse(float mx, float my) {
    hoverMouseX = mx;
    hoverMouseY = my;
  }

  void setData(ArrayList<Flight> data) {
    for (int i = 0; i < 24; i++) {
      hourCounts[i] = 0;
    }

    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      int hour = getHourFromTime(f.scheduledDepartureTime);
      if (hour >= 0 && hour < 24) {
        hourCounts[hour]++;
      }
    }
  }

  int getHourFromTime(String time) {
    if (time == null) {
      return -1;
    }

    String cleaned = trim(time);
    if (cleaned.length() == 0) {
      return -1;
    }

    if (cleaned.indexOf(':') != -1) {
      String[] parts = split(cleaned, ':');
      if (parts.length > 0) {
        try {
          int hour = Integer.parseInt(parts[0]);
          if (hour >= 0 && hour < 24) {
            return hour;
          }
        }
        catch (Exception e) {
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
      if (digits.length() <= 2) {
        int hour = Integer.parseInt(digits);
        return hour >= 0 && hour < 24 ? hour : -1;
      }

      if (digits.length() == 3) {
        int hour = Integer.parseInt(digits.substring(0, 1));
        return hour >= 0 && hour < 24 ? hour : -1;
      }

      int hour = Integer.parseInt(digits.substring(0, 2));
      return hour >= 0 && hour < 24 ? hour : -1;
    }
    catch (Exception e) {
      return -1;
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

  String getHourLabel(int hour) {
    return nf(hour, 2);
  }

  int getTotalFlights() {
    int total = 0;
    for (int i = 0; i < 24; i++) {
      total += hourCounts[i];
    }
    return total;
  }

  int getMaxCount() {
    int maxCount = 1;
    for (int i = 0; i < 24; i++) {
      if (hourCounts[i] > maxCount) {
        maxCount = hourCounts[i];
      }
    }
    return maxCount;
  }

  void drawTooltip(int hour, int count, int total, float graphX, float graphY, float graphW, float graphH) {
    rectMode(CORNER);

    String line1 = getHourLabel(hour) + ":00 - " + getHourLabel(hour) + ":59";
    String line2 = count + (count == 1 ? " flight" : " flights");
    String line3 = total > 0 ? nf((count * 100.0) / total, 0, 1) + "% of total" : "0.0% of total";

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

    fill(30);
    textAlign(LEFT, TOP);
    textSize(12);
    text(line1, boxX + 12, boxY + 10);
    text(line2, boxX + 12, boxY + 29);
    text(line3, boxX + 12, boxY + 48);
  }

  void display(ArrayList<Flight> data) {
    background(245);
    rectMode(CORNER);
    setData(data);

    float leftMargin = 80;
    float rightMargin = 40;
    float topMargin = 70;
    float bottomMargin = 80;

    float graphX = leftMargin;
    float graphY = topMargin;
    float graphW = width - leftMargin - rightMargin;
    float graphH = height - topMargin - bottomMargin;

    int totalFlights = getTotalFlights();
    int maxCount = getMaxCount();

    float roughStep = max(1, maxCount / 5.0);
    float yStep = getNiceStep(roughStep);
    float yMax = max(yStep, ceil(maxCount / yStep) * yStep);
    int stepCount = max(1, round(yMax / yStep));

    fill(30);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Flights Per Hour", width / 2, 30);

    noStroke();
    fill(255);
    rect(graphX, graphY, graphW, graphH, 8);

    stroke(228);
    strokeWeight(1);
    for (int i = 0; i <= stepCount; i++) {
      float y = map(i, 0, stepCount, graphY + graphH, graphY);
      line(graphX, y, graphX + graphW, y);

      fill(85);
      noStroke();
      textAlign(RIGHT, CENTER);
      textSize(11);
      text(str(int(i * yStep)), graphX - 10, y);
      stroke(228);
      strokeWeight(1);
    }

    stroke(60);
    strokeWeight(1.5);
    line(graphX, graphY, graphX, graphY + graphH);
    line(graphX, graphY + graphH, graphX + graphW, graphY + graphH);

    float slotWidth = graphW / 24.0;
    float barGap = min(8, slotWidth * 0.2);
    float barWidth = max(4, slotWidth - barGap);
    hoveredHour = -1;

    int maxLabels = max(1, floor(graphW / 42.0));
    int labelInterval = max(1, ceil(24.0 / maxLabels));

    for (int i = 0; i < 24; i++) {
      float barHeight = map(hourCounts[i], 0, yMax, 0, graphH - 8);
      float barX = graphX + i * slotWidth + (slotWidth - barWidth) / 2.0;
      float barY = graphY + graphH - barHeight;

      boolean isHovered = hoverMouseX >= barX && hoverMouseX <= barX + barWidth &&
        hoverMouseY >= barY && hoverMouseY <= graphY + graphH;

      if (isHovered) {
        hoveredHour = i;
      }

      noStroke();
      fill(isHovered ? color(74, 122, 214) : color(100, 140, 220));
      rect(barX, barY, barWidth, barHeight, 5);

      if (i % labelInterval == 0) {
        fill(60);
        textAlign(CENTER, TOP);
        textSize(10);
        text(getHourLabel(i), barX + barWidth / 2, graphY + graphH + 8);
      }

      if (hourCounts[i] > 0 && barWidth >= 16) {
        textSize(10);
        if (barY - 6 >= graphY + 12) {
          fill(35);
          textAlign(CENTER, BOTTOM);
          text(str(hourCounts[i]), barX + barWidth / 2, barY - 4);
        } else if (barHeight >= 18) {
          fill(255);
          textAlign(CENTER, TOP);
          text(str(hourCounts[i]), barX + barWidth / 2, barY + 4);
        }
      }
    }

    fill(40);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Hour of Day", graphX + graphW / 2, height - 25);

    pushMatrix();
    translate(25, graphY + graphH / 2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text("Number of Flights", 0, 0);
    popMatrix();

    if (hoveredHour != -1) {
      drawTooltip(hoveredHour, hourCounts[hoveredHour], totalFlights, graphX, graphY, graphW, graphH);
    }
  }
}
