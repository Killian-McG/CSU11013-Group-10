class BarChart {

  int NUM_AIRPORTS = 20;
  
  color BAR_COLOR  = color(70, 130, 200);
  color BAR_HOVER  = color(255, 160, 50);
  color BG_COLOR   = color(255, 255, 255);
  color TEXT_COLOR = color(30, 30, 30);
  color GRID_COLOR = color(200, 200, 200);
  float LABEL_SIZE = 11;
  
  
   
  String[] airports;
  int[]    counts;
  int      maxCount;
  int      marginL = 70, marginR = 30, marginT = 50, marginB = 70;
  
  
  
  
  void drawbarchart() {
    background(BG_COLOR);
    computeCounts();
    if (airports == null || airports.length == 0) {
      fill(255, 80, 80);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No data.", width/2, height/2);
      return;
    }
    drawGrid();
    drawBars();
    drawAxes();
    drawTitle();
  }
  
  void keyPressed() {
    if (key == 'r' || key == 'R') computeCounts();
  }
  
  
  
  void computeCounts() {
    java.util.HashMap<String, Integer> map = new java.util.HashMap<>();
    for (Flight f : flights) {
      map.put(f.origin, map.getOrDefault(f.origin, 0) + 1);
      
    }
  
    java.util.List<java.util.Map.Entry<String, Integer>> entries =
        new java.util.ArrayList<>(map.entrySet());
    entries.sort((a, b) -> b.getValue() - a.getValue());
  
    int n    = min(NUM_AIRPORTS, entries.size());
    airports = new String[n];
    counts   = new int[n];
    for (int i = 0; i < n; i++) {
      airports[i] = entries.get(i).getKey();
      counts[i]   = entries.get(i).getValue();
    }
    maxCount = (n > 0) ? counts[0] : 1;
  }
  
  
  void drawBars() {
    int   n     = airports.length;
    float plotW = width  - marginL - marginR;
    float plotH = height - marginT - marginB;
    float barW  = plotW / n;
    float gap   = barW * 0.18;
  
    for (int i = 0; i < n; i++) {
      float x  = marginL + i * barW + gap / 2;
      float bw = barW - gap;
      float bh = map(counts[i], 0, maxCount, 0, plotH);
      float y  = marginT + plotH - bh;
  
      boolean hover = (mouseX >= x && mouseX <= x + bw &&
                       mouseY >= y && mouseY <= marginT + plotH);
  
      fill(hover ? BAR_HOVER : BAR_COLOR);
      noStroke();
      rect(x, y, bw, bh, 3, 3, 0, 0);
  
      fill(TEXT_COLOR);
      textAlign(CENTER, BOTTOM);
      textSize(LABEL_SIZE - 1);
      text(counts[i], x + bw / 2, y - 3);
  
      textAlign(CENTER, TOP);
      textSize(LABEL_SIZE);
      text(airports[i], x + bw / 2, marginT + plotH + 8);
  
      if (hover) drawTooltip(airports[i], counts[i], mouseX, mouseY);
    }
  }
  
  void drawGrid() {
    int   gridLines = 5;
    float plotW = width  - marginL - marginR;
    float plotH = height - marginT - marginB;
  
    stroke(GRID_COLOR);
    strokeWeight(1);
    textAlign(RIGHT, CENTER);
    textSize(LABEL_SIZE);
  
    for (int g = 0; g <= gridLines; g++) {
      float y   = marginT + plotH - (plotH / gridLines) * g;
      int   val = (int) map(g, 0, gridLines, 0, maxCount);
      line(marginL, y, marginL + plotW, y);
      fill(TEXT_COLOR);
      noStroke();
      text(val, marginL - 8, y);
      stroke(GRID_COLOR);
    }
  }
  
  void drawAxes() {
    stroke(TEXT_COLOR);
    strokeWeight(2);
    float plotH = height - marginT - marginB;
    float plotW = width  - marginL - marginR;
    line(marginL, marginT, marginL, marginT + plotH);
    line(marginL, marginT + plotH, marginL + plotW, marginT + plotH);
    noStroke();
  
    pushMatrix();
    translate(16, height / 2);
    rotate(-HALF_PI);
    fill(TEXT_COLOR);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("Number of Flights", 0, 0);
    popMatrix();
  }
  
  void drawTitle() {
    fill(TEXT_COLOR);
    textAlign(CENTER, TOP);
    textSize(16);
    text("Flights by Airport — Top " + NUM_AIRPORTS, width / 2, 14);
  }
  
  void drawTooltip(String code, int count, float mx, float my) {
    String msg = code + ": " + count + " flights";
    float  tw  = textWidth(msg) + 16;
    float  th  = 26;
    float  tx  = mx + 12;
    float  ty  = my - th - 4;
    if (tx + tw > width) tx = mx - tw - 12;
    if (ty < 0)          ty = my + 8;
  
    fill(230, 230, 230, 220);
    stroke(BAR_HOVER);
    strokeWeight(1);
    rect(tx, ty, tw, th, 4);
    noStroke();
    fill(TEXT_COLOR);
    textAlign(LEFT, CENTER);
    textSize(12);
    text(msg, tx + 8, ty + th / 2);
  }
}
