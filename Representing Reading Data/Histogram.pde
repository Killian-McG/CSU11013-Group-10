
class Histogram {
  int[] hourCounts;

  Histogram() {
    hourCounts = new int[24];
  }

  void setData(ArrayList<String> times) {
    for (int i = 0; i < 24; i++) {
      hourCounts[i] = 0;
    }

    for (String time : times) {
      int hour = getHourFromTime(time);

      if (hour >= 0 && hour < 24) {
        hourCounts[hour]++;
      }
    }
  }

  int getHourFromTime(String time) {
    if (time == null) {
      return -1;
    }

    String[] parts = split(time, ':');

    if (parts.length < 2) {
      return -1;
    }

    return int(parts[0]);
  }

  void display() {
    background(245);

    // DELETE FROM HERE

    int leftMargin = 80;
    int rightMargin = 40;
    int topMargin = 70;
    int bottomMargin = 80;

    int graphX = leftMargin;
    int graphY = topMargin;
    int graphW = width - leftMargin - rightMargin;
    int graphH = height - topMargin - bottomMargin;

    int maxCount = 1;
    for (int i = 0; i < 24; i++) {
      if (hourCounts[i] > maxCount) {
        maxCount = hourCounts[i];
      }
    }

    // title
    fill(30);
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Flights Per Hour", width / 2, 30);

    // graph background
    noStroke();
    fill(255);
    rect(graphX, graphY, graphW, graphH);

    // horizontal grid lines + y labels
    stroke(220);
    fill(80);
    textSize(11);
    textAlign(RIGHT, CENTER);

    int steps = maxCount;
    if (steps > 6) {
      steps = 6;
    }

    for (int i = 0; i <= steps; i++) {
      float y = map(i, 0, steps, graphY + graphH, graphY);
      line(graphX, y, graphX + graphW, y);

      int labelValue = round(map(i, 0, steps, 0, maxCount));
      text(labelValue, graphX - 10, y);
    }

    // axes
    stroke(60);
    strokeWeight(1.5);
    line(graphX, graphY, graphX, graphY + graphH);
    line(graphX, graphY + graphH, graphX + graphW, graphY + graphH);

    // bars
    float barWidth = graphW / 24.0;

    for (int i = 0; i < 24; i++) {
      float barHeight = map(hourCounts[i], 0, maxCount, 0, graphH - 10);
      float barX = graphX + i * barWidth + 2;
      float barY = graphY + graphH - barHeight;

      noStroke();
      fill(100, 140, 220);
      rect(barX, barY, barWidth - 4, barHeight);

      // hour labels
      fill(50);
      textAlign(CENTER, TOP);
      textSize(10);

      if (i % 2 == 0) {
        text(i, barX + (barWidth - 4) / 2, graphY + graphH + 8);
      }

      // count above bar
      if (hourCounts[i] > 0) {
        fill(30);
        textAlign(CENTER, BOTTOM);
        text(hourCounts[i], barX + (barWidth - 4) / 2, barY - 4);
      }
    }

    // axis labels
    fill(40);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Hour of Day", graphX + graphW / 2, height - 25);

    pushMatrix();
    translate(25, graphY + graphH / 2);
    rotate(-HALF_PI);
    text("Number of Flights", 0, 0);
    popMatrix();

    // TO HERE
  }
}
