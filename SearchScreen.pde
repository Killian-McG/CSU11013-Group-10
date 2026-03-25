class SearchScreen {

  final int PADDING = 20;
  final int TAB_W = 160;
  final int TAB_H = 40;

  String[] chartKeys = { "histogram", "barchart", "scatterplot", "piechart" };
  String[] chartLabels = { "Histogram", "Bar Chart", "Scatter Plot", "Pie Chart" };

  int activeTab = 0;

  TimeSlider[] sliders;
  Button[] searchButtons;
  Button[] tabButtons;
  CheckBox[] cancelledBoxes;
  Dropdown toleranceDropdown;

  boolean searchFired = false;
  String pendingChartKey;
  int pendingStartMin;
  int pendingEndMin;
  boolean pendingIncludeCancelled;
  int pendingDelayTolerance;

  color bgColor = color(244, 247, 252);
  color panelBg = color(255);
  color panelStroke = color(200, 210, 230);
  color titleCol = color(28, 33, 45);

  SearchScreen() {
    sliders = new TimeSlider[4];
    searchButtons = new Button[4];
    tabButtons = new Button[4];
    cancelledBoxes = new CheckBox[3];

    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * 10;
    int tabStartX = (1200 - totalTabW) / 2;
    for (int i = 0; i < 4; i++) {
      tabButtons[i] = new Button(tabStartX + i * (TAB_W + 10), 88, TAB_W, TAB_H, chartLabels[i]);
    }

    for (int i = 0; i < 4; i++) {
      sliders[i] = new TimeSlider(0, 0, 500, "Scheduled Departure Time Range");
      sliders[i].setInterval(0, 1439);
      searchButtons[i] = new Button(0, 0, 160, 44, "Search");
    }

    for (int i = 0; i < 3; i++) {
      cancelledBoxes[i] = new CheckBox(0, 0, 20, "Include cancelled flights");
    }

    toleranceDropdown = new Dropdown(0, 0, 220, 36, "Delay Tolerance",
      new String[]{"0 mins", "10 mins", "20 mins", "30 mins", "40 mins", "50 mins", "60 mins"});
  }

  void display() {
    background(bgColor);
    drawHeader();
    drawTabs();
    drawBody();
  }

  void drawHeader() {
    fill(panelBg);
    stroke(panelStroke);
    strokeWeight(1);
    rect(0, 0, width, 70);

    fill(titleCol);
    noStroke();
    textSize(24);
    textAlign(LEFT, CENTER);
    text("Flight Data Explorer", PADDING, 35);
  }

  void drawTabs() {
    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * 10;
    int tabStartX = (width - totalTabW) / 2;

    for (int i = 0; i < 4; i++) {
      tabButtons[i].x = tabStartX + i * (TAB_W + 10);
      tabButtons[i].y = 82;

      boolean active = (i == activeTab);
      boolean hov = mouseX >= tabButtons[i].x && mouseX <= tabButtons[i].x + TAB_W &&
                    mouseY >= tabButtons[i].y && mouseY <= tabButtons[i].y + TAB_H;

      noStroke();
      fill(active ? color(70, 120, 230) : hov ? color(210, 218, 235) : color(225, 230, 240));
      rect(tabButtons[i].x, tabButtons[i].y, TAB_W, TAB_H, 10);

      fill(active ? color(255) : color(80, 90, 110));
      textSize(13);
      textAlign(CENTER, CENTER);
      text(chartLabels[i], tabButtons[i].x + TAB_W / 2, tabButtons[i].y + TAB_H / 2);
    }
  }

  void drawBody() {
    float bodyX = PADDING;
    float bodyY = 82 + TAB_H + 8;
    float bodyW = width - PADDING * 2;
    float bodyH = height - bodyY - PADDING;

    fill(panelBg);
    stroke(panelStroke);
    strokeWeight(1);
    rect(bodyX, bodyY, bodyW, bodyH, 8);

    fill(titleCol);
    noStroke();
    textSize(20);
    textAlign(LEFT, TOP);
    text(chartLabels[activeTab], bodyX + 28, bodyY + 24);

    float sliderX = bodyX + 40;
    float sliderY = bodyY + 90;
    float sliderW = bodyW - 80;

    sliders[activeTab].x = sliderX;
    sliders[activeTab].y = sliderY;
    sliders[activeTab].w = sliderW;
    sliders[activeTab].display();

    float extraY = sliderY + 70;
    if (activeTab < 3) {
      cancelledBoxes[activeTab].x = bodyX + 40;
      cancelledBoxes[activeTab].y = extraY;
      cancelledBoxes[activeTab].display();
    } else {
      toleranceDropdown.x = bodyX + 40;
      toleranceDropdown.y = extraY;
      toleranceDropdown.display();
    }

    float btnX = bodyX + bodyW / 2 - 80;
    float btnY = bodyY + bodyH - 64;

    searchButtons[activeTab].x = btnX;
    searchButtons[activeTab].y = btnY;
    searchButtons[activeTab].display();
  }

  void handleMousePressed() {
    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * 10;
    int tabStartX = (width - totalTabW) / 2;
    for (int i = 0; i < 4; i++) {
      float tx = tabStartX + i * (TAB_W + 10);
      if (mouseX >= tx && mouseX <= tx + TAB_W &&
          mouseY >= 82 && mouseY <= 82 + TAB_H) {
        activeTab = i;
        return;
      }
    }

    sliders[activeTab].handleMousePressed();

    if (activeTab < 3) {
      if (cancelledBoxes[activeTab].isMouseOver()) {
        cancelledBoxes[activeTab].setChecked(!cancelledBoxes[activeTab].isChecked());
      }
    } else {
      toleranceDropdown.handleMousePressed();
    }

    float bodyX = PADDING;
    float bodyY = 82 + TAB_H + 8;
    float bodyW = width - PADDING * 2;
    float bodyH = height - bodyY - PADDING;
    float btnX = bodyX + bodyW / 2 - 80;
    float btnY = bodyY + bodyH - 64;

    searchButtons[activeTab].x = btnX;
    searchButtons[activeTab].y = btnY;

    if (searchButtons[activeTab].isClicked()) {
      pendingChartKey = chartKeys[activeTab];
      pendingStartMin = sliders[activeTab].getStartTotalMinutes();
      pendingEndMin = sliders[activeTab].getEndTotalMinutes();
      pendingIncludeCancelled = (activeTab < 3) && cancelledBoxes[activeTab].isChecked();
      pendingDelayTolerance = (activeTab == 3)
                                ? int(split(toleranceDropdown.getSelected(), ' ')[0])
                                : 0;
      searchFired = true;
    }
  }

  void handleMouseMoved() {
    if (activeTab == 3) toleranceDropdown.handleMouseMoved();
  }

  void handleMouseDragged() {
    sliders[activeTab].handleMouseDragged();
    if (activeTab == 3) toleranceDropdown.handleMouseDragged();
  }

  void handleMouseReleased() {
    sliders[activeTab].handleMouseReleased();
  }
}
