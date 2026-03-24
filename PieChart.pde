class PieChart {
  float x;
  float y;
  float diameter;

  color onTimeColor;
  color lateColor;
  color cancelledColor;
  color textColor;

  PieChart(float x, float y, float diameter) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;

    onTimeColor = color(0, 200, 0);
    lateColor = color(255, 150, 0);
    cancelledColor = color(200, 0, 0);
    textColor = color(0);
  }

  void display(ArrayList<Flight> flights) {
    int onTime = 0;
    int late = 0;
    int cancelledCount = 0;

    for (Flight f : flights) {
      if (f.cancelled == 1) {
        cancelledCount++;
      } else {
        if (f.departureTime != null && f.scheduledDepartureTime != null &&
            f.departureTime.length() > 0 && f.scheduledDepartureTime.length() > 0) {

          int dep = int(f.departureTime);
          int sched = int(f.scheduledDepartureTime);

          if (dep <= sched) {
            onTime++;
          } else {
            late++;
          }
        }
      }
    }

    float total = onTime + late + cancelledCount;

    if (total == 0) {
      fill(textColor);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No data to display", x, y);
      return;
    }

    float pOnTime = (onTime / total) * 100.0;
    float pLate = (late / total) * 100.0;
    float pCancelled = (cancelledCount / total) * 100.0;

    float angleOnTime = (onTime / total) * TWO_PI;
    float angleLate = (late / total) * TWO_PI;
    float angleCancelled = (cancelledCount / total) * TWO_PI;

    float startAngle = 0;

    noStroke();

    fill(onTimeColor);
    arc(x, y, diameter, diameter, startAngle, startAngle + angleOnTime, PIE);
    startAngle += angleOnTime;

    fill(lateColor);
    arc(x, y, diameter, diameter, startAngle, startAngle + angleLate, PIE);
    startAngle += angleLate;

    fill(cancelledColor);
    arc(x, y, diameter, diameter, startAngle, startAngle + angleCancelled, PIE);

    drawLegend(onTime, late, cancelledCount, pOnTime, pLate, pCancelled);
  }

  void drawLegend(int onTime, int late, int cancelledCount,
                  float pOnTime, float pLate, float pCancelled) {
    float legendX = x + diameter / 2 + 40;
    float legendY = y - 60;

    textSize(16);
    textAlign(LEFT, TOP);

    fill(onTimeColor);
    rect(legendX, legendY, 20, 20);
    fill(textColor);
    text("On Time (" + onTime + ", " + nf(pOnTime, 0, 1) + "%)", legendX + 30, legendY);

    fill(lateColor);
    rect(legendX, legendY + 40, 20, 20);
    fill(textColor);
    text("Late (" + late + ", " + nf(pLate, 0, 1) + "%)", legendX + 30, legendY + 40);

    fill(cancelledColor);
    rect(legendX, legendY + 80, 20, 20);
    fill(textColor);
    text("Cancelled (" + cancelledCount + ", " + nf(pCancelled, 0, 1) + "%)", legendX + 30, legendY + 80);
  }
}
