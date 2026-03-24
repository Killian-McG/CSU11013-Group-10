class ScatterPlot {

  final int SC_MARGIN_LEFT   = 80;
  final int SC_MARGIN_RIGHT  = 40;
  final int SC_MARGIN_TOP    = 60;
  final int SC_MARGIN_BOTTOM = 60;
  
  color[] carrierColors = { 
    color(55, 138, 221),
    color(29, 158, 117),
    color(216, 90, 48),
    color(212, 83, 126),
    color(186, 117, 23),
    color(136, 135, 128)
  };
  
  String[] carrierNames = { "AA", "AS", "B6", "HA", "NK", "Other" };
  
  
  void drawScatterPlot() {
    int chartW = width  - SC_MARGIN_LEFT - SC_MARGIN_RIGHT;
    int chartH = height - SC_MARGIN_TOP  - SC_MARGIN_BOTTOM;
  
    fill(0);
    textSize(20);
    textAlign(LEFT, TOP);
    text("Scheduled vs Actual Departure Time", SC_MARGIN_LEFT, 18);
  
    int legendY = 26;
    int legendX = SC_MARGIN_LEFT + 420;
    for (int i = 0; i < carrierNames.length; i++) {
      fill(carrierColors[i]); noStroke();
      ellipse(legendX + 6, legendY, 8, 8);
      fill(0); textSize(12); textAlign(LEFT, CENTER);
      text(carrierNames[i], legendX + 14, legendY);
      legendX += 60;
    }
  
    fill(80);
    textSize(13);
    textAlign(CENTER, CENTER);
    pushMatrix();
    translate(18, SC_MARGIN_TOP + chartH / 2);
    rotate(-HALF_PI);
    text("Actual Departure Time", 0, 0);
    popMatrix();
  
    textAlign(CENTER, BOTTOM);
    textSize(13);
    fill(80);
    text("Scheduled Departure Time", SC_MARGIN_LEFT + chartW / 2, height - 8);
  
    int[] tickTimes  = { 0, 400, 800, 1200, 1600, 2000, 2359 };
    String[] tickLabels = { "00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "23:59" };
  
    for (int t = 0; t < tickTimes.length; t++) {
      float frac = timeToFraction(tickTimes[t]);
  
      float tx = SC_MARGIN_LEFT + frac * chartW;
      stroke(220); 
      strokeWeight(1);
      line(tx, SC_MARGIN_TOP, tx, SC_MARGIN_TOP + chartH);
      stroke(0); 
      strokeWeight(1.5);
      line(tx, SC_MARGIN_TOP + chartH, tx, SC_MARGIN_TOP + chartH + 5);
      fill(80); 
      noStroke();
      textSize(11); 
      textAlign(CENTER, TOP);
      text(tickLabels[t], tx, SC_MARGIN_TOP + chartH + 7);
  
      float ty = SC_MARGIN_TOP + (1 - frac) * chartH;
      stroke(220); 
      strokeWeight(1);
      line(SC_MARGIN_LEFT, ty, SC_MARGIN_LEFT + chartW, ty);
      stroke(0); 
      strokeWeight(1.5);
      line(SC_MARGIN_LEFT - 5, ty, SC_MARGIN_LEFT, ty);
      fill(80); 
      noStroke();
      textSize(11); 
      textAlign(RIGHT, CENTER);
      text(tickLabels[t], SC_MARGIN_LEFT - 8, ty);
    }
  
    stroke(180);
    strokeWeight(1.5);
    drawDashedLine(SC_MARGIN_LEFT, SC_MARGIN_TOP + chartH, SC_MARGIN_LEFT + chartW, SC_MARGIN_TOP, 8, 5);
  
    noStroke();
    for (int i = 0; i < flights.size(); i++) {
      Flight f = flights.get(i);
      if (f.cancelled == 1) continue;
      if (f.scheduledDepartureTime == null || f.scheduledDepartureTime.equals("")) continue;
      if (f.departureTime == null || f.departureTime.equals("")) continue;
  
      int sched  = int(f.scheduledDepartureTime.trim());
      int actual = int(f.departureTime.trim());
      if (actual < 0 || actual > 2359) continue;
  
      float x = SC_MARGIN_LEFT + timeToFraction(sched)  * chartW;
      float y = SC_MARGIN_TOP  + (1 - timeToFraction(actual)) * chartH;
  
      fill(getCarrierColor(f.carrier), 180);
      ellipse(x, y, 3, 3);
    }
  
    stroke(0); 
    strokeWeight(1.5);
    line(SC_MARGIN_LEFT, SC_MARGIN_TOP + chartH, SC_MARGIN_LEFT + chartW, SC_MARGIN_TOP + chartH);
    line(SC_MARGIN_LEFT, SC_MARGIN_TOP, SC_MARGIN_LEFT, SC_MARGIN_TOP + chartH);
  }
  
  
  float timeToFraction(int hhmm) {
    int h = hhmm / 100;
    int m = hhmm % 100;
    return (h * 60 + m) / (23.0 * 60 + 59);
  }
  
  
  color getCarrierColor(String carrier) {
    for (int i = 0; i < carrierNames.length - 1; i++) {
      if (carrierNames[i].equals(carrier)) return carrierColors[i];
    }
    return carrierColors[carrierColors.length - 1];
  }
  
  
  void drawDashedLine(float x1, float y1, float x2, float y2, float dashLen, float gapLen) {
    float dx = x2 - x1, dy = y2 - y1;
    float total = sqrt(dx*dx + dy*dy);
    float nx = dx / total, ny = dy / total;
    float dist = 0;
    boolean drawing = true;
    while (dist < total) {
      float segLen = drawing ? dashLen : gapLen;
      float end = min(dist + segLen, total);
      if (drawing) {
        line(x1 + nx * dist, y1 + ny * dist, x1 + nx * end, y1 + ny * end);
      }
      dist = end;
      drawing = !drawing;
    }
  }
}
