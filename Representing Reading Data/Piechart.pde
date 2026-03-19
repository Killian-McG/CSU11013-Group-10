
class PieChart {

  float x, y, diameter;

  PieChart(float x, float y, float diameter) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
  }

  void draw(ArrayList<Flight> flights) {

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
    if (total == 0) return;

    float pOnTime = (onTime / total) * 100;
    float pLate = (late / total) * 100;
    float pCancelled = (cancelledCount / total) * 100;

    float angle1 = (onTime / total) * TWO_PI;
    float angle2 = (late / total) * TWO_PI;
    float angle3 = (cancelledCount / total) * TWO_PI;

    float lastAngle = 0;

    fill(0, 200, 0);
    arc(x, y, diameter, diameter, lastAngle, lastAngle + angle1);
    lastAngle += angle1;

    fill(255, 150, 0);
    arc(x, y, diameter, diameter, lastAngle, lastAngle + angle2);
    lastAngle += angle2;

    fill(200, 0, 0);
    arc(x, y, diameter, diameter, lastAngle, lastAngle + angle3);

    drawLegend(onTime, late, cancelledCount, pOnTime, pLate, pCancelled);
  }

  void drawLegend(int onTime, int late, int cancelledCount,
                  float pOnTime, float pLate, float pCancelled) {

    float legendX = x + diameter/2 + 40;
    float legendY = y - 60;

    textSize(16);

    fill(0, 200, 0);
    rect(legendX, legendY, 20, 20);
    fill(0);
    text("On Time (" + onTime + ", " + nf(pOnTime, 0, 1) + "%)", legendX + 30, legendY + 15);

    fill(255, 150, 0);
    rect(legendX, legendY + 40, 20, 20);
    fill(0);
    text("Late (" + late + ", " + nf(pLate, 0, 1) + "%)", legendX + 30, legendY + 55);

    fill(200, 0, 0);
    rect(legendX, legendY + 80, 20, 20);
    fill(0);
    text("Cancelled (" + cancelledCount + ", " + nf(pCancelled, 0, 1) + "%)", legendX + 30, legendY + 95);
  }
}
