class DataScreen {

  final int PADDING   = 20;
  final int TITLE_H   = 40;
  final int ICON_SIZE = 28;

  color bgColor      = color(245, 246, 248);
  color panelBg      = color(255);
  color panelStroke  = color(200, 210, 230);
  color graphStroke  = color(100, 140, 220);
  color infoStroke   = color(200, 60,  60);
  color infoFill     = color(255, 240, 240);
  color filterStroke = color(140, 90, 200);
  color filterFill   = color(240, 230, 255);
  color titleColor   = color(30);
  color subtleText   = color(140);
  color btnBg        = color(70, 120, 230);
  color btnHover     = color(50, 100, 210);

  String currentChart = "histogram";
  boolean homeFired   = false;

  Histogram   histogram;
  BarChart    barChart;
  ScatterPlot scatterPlot;
  PieChart    pieChart;

  DataScreen() {
    histogram   = new Histogram();
    barChart    = new BarChart();
    scatterPlot = new ScatterPlot();
    pieChart    = new PieChart(width / 2, height / 2, 300);
  }

  void setChart(String chartName) {
    currentChart = chartName;
  }

  String getChartTitle() {
    if (currentChart.equals("histogram"))   return "Histogram";
    if (currentChart.equals("barchart"))    return "Bar Chart";
    if (currentChart.equals("scatterplot")) return "Scatter Plot";
    if (currentChart.equals("piechart"))    return "Pie Chart";
    return "No Chart Selected";
  }

  void display() {
    fill(bgColor);
    noStroke();
    rect(0, 0, width, height);

    drawTitleBar();

    int contentY = PADDING + TITLE_H + PADDING;
    int bottomH  = 90;
    int bottomY  = height - bottomH - PADDING;
    int graphH   = bottomY - contentY - PADDING;
    int graphW   = width - PADDING * 2;
    int halfW    = (width - PADDING * 3) / 2;

    drawGraph(PADDING, contentY, graphW, graphH);
    drawInfo(PADDING, bottomY, halfW, bottomH);
    drawFilter(PADDING * 2 + halfW, bottomY, halfW, bottomH);
  }

  void drawTitleBar() {
    fill(panelBg);
    stroke(panelStroke);
    strokeWeight(1);
    rect(0, 0, width, PADDING + TITLE_H + PADDING / 2);

    fill(titleColor);
    noStroke();
    textSize(18);
    textAlign(LEFT, CENTER);
    text(getChartTitle(), PADDING, PADDING + TITLE_H / 2);

    drawHomeButton();
  }

  void drawHomeButton() {
    float bw   = 120;
    float bh   = 32;
    float bx   = width - bw - PADDING;
    float by   = PADDING + TITLE_H / 2 - bh / 2;
    boolean hov = mouseX >= bx && mouseX <= bx + bw &&
                  mouseY >= by && mouseY <= by + bh;

    noStroke();
    fill(hov ? btnHover : btnBg);
    rect(bx, by, bw, bh, 8);

    fill(255);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("< Home", bx + bw / 2, by + bh / 2);
  }

  void handleMousePressed() {
    float bw = 120;
    float bh = 32;
    float bx = width - bw - PADDING;
    float by = PADDING + TITLE_H / 2 - bh / 2;

    if (mouseX >= bx && mouseX <= bx + bw &&
        mouseY >= by && mouseY <= by + bh) {
      homeFired = true;
    }
  }

  void drawGraph(int gx, int gy, int gw, int gh) {
    fill(panelBg);
    stroke(graphStroke);
    strokeWeight(1.5);
    rect(gx, gy, gw, gh, 8);

    clip(gx + 2, gy + 2, gw - 4, gh - 4);
    pushMatrix();

    float scaleX = (float) gw / width;
    float scaleY = (float) gh / height;
    float s      = min(scaleX, scaleY);

    float scaledW = width  * s;
    float scaledH = height * s;
    float offsetX = gx + (gw - scaledW) / 2.0;
    float offsetY = gy + (gh - scaledH) / 2.0;

    translate(offsetX, offsetY);
    scale(s);

    if      (currentChart.equals("histogram"))   histogram.display();
    else if (currentChart.equals("barchart"))    barChart.drawbarchart();
    else if (currentChart.equals("scatterplot")) scatterPlot.drawScatterPlot();
    else if (currentChart.equals("piechart"))    pieChart.display(flights);
    else {
      popMatrix();
      noClip();
      fill(subtleText);
      noStroke();
      textSize(14);
      textAlign(CENTER, CENTER);
      text("No chart selected", gx + gw / 2, gy + gh / 2);
      return;
    }

    popMatrix();
    noClip();
  }

  void drawInfo(int ix, int iy, int iw, int ih) {
    fill(infoFill);
    stroke(infoStroke);
    strokeWeight(1.5);
    rect(ix, iy, iw, ih, 8);

    fill(infoStroke);
    noStroke();
    textSize(13);
    textAlign(LEFT, TOP);
    text("Info", ix + 12, iy + 10);
  }

  void drawFilter(int fx, int fy, int fw, int fh) {
    fill(filterFill);
    stroke(filterStroke);
    strokeWeight(1.5);
    rect(fx, fy, fw, fh, 8);

    fill(filterStroke);
    noStroke();
    textSize(13);
    textAlign(LEFT, TOP);
    text("Filter", fx + 12, fy + 10);
  }
}
