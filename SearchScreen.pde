class SearchScreen {
  String[] tabs;
  int activeTab;

  float outerX;
  float outerY;
  float outerW;
  float outerH;
  float headerH;
  float tabsY;
  float tabsH;
  float bodyX;
  float bodyY;
  float bodyW;
  float bodyH;
  float tabW;
  float tabGap;

  Dropdown sortDropdown;
  Dropdown categoryDropdown;
  Dropdown viewDropdown;
  CheckBox nonstopCheck;
  CheckBox flexibleCheck;
  TimeSlider timeSlider;
  Button searchButton;

  String statusText;
  String[] routeNames;
  String[] routeTimes;
  String[] routeTags;

  SearchScreen() {
    tabs = new String[]{"Overview", "Flights", "Filters", "Stats"};
    activeTab = 0;

    sortDropdown = new Dropdown(0, 0, 210, 38, "Sort By", new String[]{"Best Match", "Price", "Duration", "Departure"});
    categoryDropdown = new Dropdown(0, 0, 210, 38, "Category", new String[]{"All Flights", "Domestic", "International", "Popular"});
    viewDropdown = new Dropdown(0, 0, 210, 38, "View", new String[]{"Compact", "Detailed", "Cards", "Timeline"});

    nonstopCheck = new CheckBox(0, 0, 22, "Non-stop only");
    flexibleCheck = new CheckBox(0, 0, 22, "Flexible dates");

    timeSlider = new TimeSlider(0, 0, 420, "Preferred Time");
    timeSlider.setInterval(420, 1140);

    searchButton = new Button(0, 0, 150, 42, "Run Search");

    statusText = "Ready";

    routeNames = new String[]{
      "Dublin to Paris",
      "Dublin to Rome",
      "Dublin to Berlin",
      "Dublin to Madrid"
    };

    routeTimes = new String[]{
      "08:10  •  2h 05m",
      "10:45  •  2h 55m",
      "13:20  •  2h 20m",
      "17:05  •  2h 40m"
    };

    routeTags = new String[]{
      "Popular",
      "Best Price",
      "Fastest",
      "Evening"
    };
  }

  void display() {
    updateLayout();
    drawBackground();
    drawHeader();
    drawTabs();
    drawBody();
  }

  void updateLayout() {
    outerX = 28;
    outerY = 24;
    outerW = width - 56;
    outerH = height - 48;

    headerH = 92;
    tabsY = outerY + headerH + 16;
    tabsH = 44;

    bodyX = outerX;
    bodyY = tabsY + tabsH + 16;
    bodyW = outerW;
    bodyH = outerH - headerH - tabsH - 32;

    tabGap = 12;
    tabW = min(170, (outerW - tabGap * 3) / 4.0);

    sortDropdown.x = bodyX + bodyW - 250;
    sortDropdown.y = bodyY + 24;
    sortDropdown.w = 220;
    sortDropdown.h = 38;

    categoryDropdown.x = bodyX + 28;
    categoryDropdown.y = bodyY + 36;
    categoryDropdown.w = 220;
    categoryDropdown.h = 38;

    viewDropdown.x = bodyX + 272;
    viewDropdown.y = bodyY + 36;
    viewDropdown.w = 220;
    viewDropdown.h = 38;

    nonstopCheck.x = bodyX + 34;
    nonstopCheck.y = bodyY + 108;
    nonstopCheck.size = 22;

    flexibleCheck.x = bodyX + 230;
    flexibleCheck.y = bodyY + 108;
    flexibleCheck.size = 22;

    timeSlider.x = bodyX + 34;
    timeSlider.y = bodyY + 200;
    timeSlider.w = bodyW - 68;

    searchButton.x = bodyX + bodyW - 180;
    searchButton.y = bodyY + 100;
    searchButton.w = 150;
    searchButton.h = 42;
  }

  void drawBackground() {
    background(244, 247, 252);

    noStroke();
    fill(70, 120, 230, 20);
    ellipse(width - 120, 90, 220, 220);
    fill(70, 120, 230, 12);
    ellipse(width - 40, 140, 180, 180);
    fill(255);
    rect(outerX, outerY, outerW, outerH, 26);
  }

  void drawHeader() {
    drawShadow(outerX, outerY, outerW, headerH, 26);

    noStroke();
    fill(255);
    rect(outerX, outerY, outerW, headerH, 26);

    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(28);
    text("Search Screen", outerX + 26, outerY + 20);

    fill(110, 118, 132);
    textSize(14);
    text("Simple tab layout with placeholders you can swap later", outerX + 26, outerY + 56);

    float badgeW = 136;
    float badgeH = 34;
    float badgeX = outerX + outerW - badgeW - 24;
    float badgeY = outerY + 28;

    fill(232, 240, 255);
    rect(badgeX, badgeY, badgeW, badgeH, 14);
    fill(55, 95, 195);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Screen 1 Active", badgeX + badgeW / 2, badgeY + badgeH / 2);
  }

  void drawTabs() {
    for (int i = 0; i < tabs.length; i++) {
      float tx = outerX + i * (tabW + tabGap);
      float ty = tabsY;
      boolean hovered = mouseX >= tx && mouseX <= tx + tabW && mouseY >= ty && mouseY <= ty + tabsH;
      boolean selected = i == activeTab;

      noStroke();
      if (selected) {
        fill(70, 120, 230);
      } else if (hovered) {
        fill(232, 238, 248);
      } else {
        fill(246, 248, 252);
      }

      rect(tx, ty, tabW, tabsH, 14);

      if (selected) {
        fill(255);
      } else {
        fill(70, 78, 92);
      }

      textAlign(CENTER, CENTER);
      textSize(15);
      text(tabs[i], tx + tabW / 2, ty + tabsH / 2);
    }
  }

  void drawBody() {
    drawShadow(bodyX, bodyY, bodyW, bodyH, 26);

    noStroke();
    fill(255);
    rect(bodyX, bodyY, bodyW, bodyH, 26);

    if (activeTab == 0) {
      drawOverviewTab();
    } else if (activeTab == 1) {
      drawFlightsTab();
    } else if (activeTab == 2) {
      drawFiltersTab();
    } else if (activeTab == 3) {
      drawStatsTab();
    }
  }

  void drawOverviewTab() {
    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(22);
    text("Overview", bodyX + 28, bodyY + 24);

    fill(112, 120, 134);
    textSize(14);
    text("This tab can hold a quick summary of whatever the search screen should show first.", bodyX + 28, bodyY + 56);

    float cardY = bodyY + 100;
    float cardW = (bodyW - 84) / 3.0;
    float cardH = 118;

    drawMiniCard(bodyX + 28, cardY, cardW, cardH, "Saved Routes", "12", "Placeholder count");
    drawMiniCard(bodyX + 42 + cardW, cardY, cardW, cardH, "Visible Results", "248", "Placeholder count");
    drawMiniCard(bodyX + 56 + cardW * 2, cardY, cardW, cardH, "Best Match", "Morning Flight", "Placeholder label");

    float panelX = bodyX + 28;
    float panelY = cardY + cardH + 24;
    float panelW = bodyW - 56;
    float panelH = bodyH - (panelY - bodyY) - 28;

    fill(248, 250, 254);
    rect(panelX, panelY, panelW, panelH, 22);

    fill(34, 40, 52);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Quick Notes", panelX + 22, panelY + 20);

    drawBulletRow(panelX + 22, panelY + 62, "Tab 1 can introduce the screen");
    drawBulletRow(panelX + 22, panelY + 102, "Tab 2 can list search results");
    drawBulletRow(panelX + 22, panelY + 142, "Tab 3 can hold interactive filters");
    drawBulletRow(panelX + 22, panelY + 182, "Tab 4 can show charts or summary values");
  }

  void drawFlightsTab() {
    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(22);
    text("Flights", bodyX + 28, bodyY + 24);

    sortDropdown.display();

    fill(112, 120, 134);
    textSize(14);
    text("Simple placeholder rows for future search results", bodyX + 28, bodyY + 58);

    float listX = bodyX + 28;
    float listY = bodyY + 92;
    float listW = bodyW - 56;
    float rowH = 84;

    for (int i = 0; i < 4; i++) {
      float ry = listY + i * (rowH + 14);
      drawFlightRow(listX, ry, listW, rowH, routeNames[i], routeTimes[i], routeTags[i], i);
    }

    fill(85, 94, 110);
    textSize(13);
    textAlign(LEFT, BOTTOM);
    text("Status: " + statusText, bodyX + 32, bodyY + bodyH - 18);
  }

  void drawFiltersTab() {
    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(22);
    text("Filters", bodyX + 28, bodyY + 24);

    fill(112, 120, 134);
    textSize(14);
    text("These controls already work and can act as placeholders for your final filters", bodyX + 28, bodyY + 58);

    fill(248, 250, 254);
    rect(bodyX + 24, bodyY + 84, bodyW - 48, bodyH - 108, 22);

    categoryDropdown.display();
    viewDropdown.display();
    nonstopCheck.display();
    flexibleCheck.display();
    timeSlider.display();
    searchButton.display();

    fill(70, 78, 92);
    textAlign(LEFT, TOP);
    textSize(15);
    text("Current Selection", bodyX + 34, bodyY + 286);

    float infoY = bodyY + 322;
    drawValueLine(bodyX + 34, infoY, "Category", categoryDropdown.getSelected());
    drawValueLine(bodyX + 34, infoY + 34, "View", viewDropdown.getSelected());
    drawValueLine(bodyX + 34, infoY + 68, "Time Range", timeSlider.getStartTime() + " - " + timeSlider.getEndTime());
    drawValueLine(bodyX + 34, infoY + 102, "Non-stop", nonstopCheck.isChecked() ? "Yes" : "No");
    drawValueLine(bodyX + 34, infoY + 136, "Flexible", flexibleCheck.isChecked() ? "Yes" : "No");
  }

  void drawStatsTab() {
    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(22);
    text("Stats", bodyX + 28, bodyY + 24);

    fill(112, 120, 134);
    textSize(14);
    text("Simple visual placeholders for future data", bodyX + 28, bodyY + 58);

    float cardY = bodyY + 92;
    float statW = (bodyW - 84) / 3.0;

    drawMiniCard(bodyX + 28, cardY, statW, 112, "Average Price", "€184", "Placeholder value");
    drawMiniCard(bodyX + 42 + statW, cardY, statW, 112, "Fastest Route", "2h 05m", "Placeholder value");
    drawMiniCard(bodyX + 56 + statW * 2, cardY, statW, 112, "Top Period", "Morning", "Placeholder value");

    float chartX = bodyX + 28;
    float chartY = cardY + 138;
    float chartW = bodyW - 56;
    float chartH = bodyH - (chartY - bodyY) - 28;

    fill(248, 250, 254);
    rect(chartX, chartY, chartW, chartH, 22);

    fill(34, 40, 52);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Activity Snapshot", chartX + 22, chartY + 20);

    float baseY = chartY + chartH - 44;
    float barW = 86;
    float gap = 34;
    float startX = chartX + 34;
    float[] values = {120, 180, 100, 220};
    String[] labels = {"Mon", "Tue", "Wed", "Thu"};

    for (int i = 0; i < values.length; i++) {
      float bx = startX + i * (barW + gap);
      float bh = values[i];
      noStroke();
      fill(220, 229, 245);
      rect(bx, baseY - 220, barW, 220, 16);
      fill(70, 120, 230);
      rect(bx, baseY - bh, barW, bh, 16);
      fill(70, 78, 92);
      textAlign(CENTER, TOP);
      textSize(13);
      text(labels[i], bx + barW / 2, baseY + 10);
    }
  }

  void drawMiniCard(float x, float y, float w, float h, String title, String value, String subtitle) {
    fill(248, 250, 254);
    rect(x, y, w, h, 22);

    fill(108, 116, 130);
    textAlign(LEFT, TOP);
    textSize(13);
    text(title, x + 18, y + 18);

    fill(28, 33, 45);
    textSize(24);
    text(value, x + 18, y + 44);

    fill(112, 120, 134);
    textSize(13);
    text(subtitle, x + 18, y + h - 24);
  }

  void drawBulletRow(float x, float y, String label) {
    fill(70, 120, 230);
    ellipse(x + 6, y + 8, 10, 10);
    fill(70, 78, 92);
    textAlign(LEFT, TOP);
    textSize(15);
    text(label, x + 22, y);
  }

  void drawFlightRow(float x, float y, float w, float h, String route, String timeText, String tag, int index) {
    fill(248, 250, 254);
    rect(x, y, w, h, 20);

    float accentH = h - 18;
    fill(70, 120, 230);
    rect(x + 10, y + 9, 8, accentH, 10);

    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(18);
    text(route, x + 34, y + 18);

    fill(112, 120, 134);
    textSize(14);
    text(timeText, x + 34, y + 48);

    float tagW = 104;
    float tagH = 28;
    float tagX = x + w - tagW - 22;
    float tagY = y + 16;

    fill(232, 240, 255);
    rect(tagX, tagY, tagW, tagH, 12);
    fill(55, 95, 195);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(tag, tagX + tagW / 2, tagY + tagH / 2);

    fill(70, 78, 92);
    textAlign(RIGHT, BOTTOM);
    textSize(13);
    text("Placeholder row " + (index + 1), x + w - 22, y + h - 16);
  }

  void drawValueLine(float x, float y, String label, String value) {
    fill(108, 116, 130);
    textAlign(LEFT, TOP);
    textSize(14);
    text(label, x, y);

    fill(28, 33, 45);
    textAlign(LEFT, TOP);
    textSize(15);
    text(value, x + 120, y);
  }

  void drawShadow(float x, float y, float w, float h, float r) {
    noStroke();
    fill(20, 28, 45, 12);
    rect(x + 4, y + 6, w, h, r);
    fill(20, 28, 45, 6);
    rect(x + 2, y + 3, w, h, r);
  }

  void handleMousePressed() {
    for (int i = 0; i < tabs.length; i++) {
      float tx = outerX + i * (tabW + tabGap);
      if (mouseX >= tx && mouseX <= tx + tabW && mouseY >= tabsY && mouseY <= tabsY + tabsH) {
        activeTab = i;
        return;
      }
    }

    if (activeTab == 1) {
      sortDropdown.handleMousePressed();
    }

    if (activeTab == 2) {
      categoryDropdown.handleMousePressed();
      viewDropdown.handleMousePressed();
      timeSlider.handleMousePressed();

      if (nonstopCheck.isMouseOver()) {
        nonstopCheck.setChecked(!nonstopCheck.isChecked());
      }

      if (flexibleCheck.isMouseOver()) {
        flexibleCheck.setChecked(!flexibleCheck.isChecked());
      }

      if (searchButton.isClicked()) {
        statusText = "Updated at " + nf(hour(), 2) + ":" + nf(minute(), 2);
      }
    }
  }

  void handleMouseMoved() {
    if (activeTab == 1) {
      sortDropdown.handleMouseMoved();
    }

    if (activeTab == 2) {
      categoryDropdown.handleMouseMoved();
      viewDropdown.handleMouseMoved();
    }
  }

  void handleMouseDragged() {
    if (activeTab == 1) {
      sortDropdown.handleMouseDragged();
    }

    if (activeTab == 2) {
      categoryDropdown.handleMouseDragged();
      viewDropdown.handleMouseDragged();
      timeSlider.handleMouseDragged();
    }
  }

  void handleMouseReleased() {
    if (activeTab == 2) {
      timeSlider.handleMouseReleased();
    }
  }
}
