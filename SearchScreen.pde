// MAIN AUTHOR: Cameron - Week 3

// Editors: Matthew and Killian 
//          Improved code layout, fixed filter errors and fixed cosmetics issues

// SEARCH SCREEN
//    First screen users sees, allows users to select chart type and filter data
class SearchScreen {
  
  // Complete list of flights
  ArrayList<Flight> allFlights;
  
  // Filter engine applied to users selections
  FlightFilter flightFilter;
  
  // Layout constants
  final int PADDING = 18;
  final int HEADER_H = 96;
  final int TAB_Y = 108;
  final int TAB_W = 150;
  final int TAB_H = 38;
  final int TAB_GAP = 10;
  final int CARD_RADIUS = 16;
  final int CARD_GAP = 18;
  final int FIELD_H = 34;
  final int FIELD_GAP_Y = 20;
  final int CHECKBOX_GAP_Y = 30;

  // Internal keys used to identify each chart type in code
  String[] chartKeys = { "histogram", "barchart", "scatterplot", "piechart" };
  String[] chartLabels = { "Histogram", "Bar Chart", "Scatter Plot", "Pie Chart" };

  int activeTab = 0;

  // UI COntrols
  TimeSlider[] sliders;
  Button[] searchButtons;
  Button[] resetButtons;
  Button[] tabButtons;
  CheckBox[] cancelledBoxes;
  CheckBox[] divertedBoxes;
  CheckBox[] delayedOnlyBoxes;
  CheckBox[] onTimeOnlyBoxes;

  Dropdown[] carrierDropdowns;
  Dropdown[] originStateDropdowns;
  Dropdown[] destinationStateDropdowns;
  Dropdown[] distanceDropdowns;
  Dropdown[] timeBucketDropdowns;
  Dropdown[] delayToleranceDropdowns;

  // Dropdown Option lists
  String[] carrierOptions;
  String[] originStateOptions;
  String[] destinationStateOptions;
  String[] distanceOptions;
  String[] timeBucketOptions;
  String[] delayToleranceOptions;

  boolean searchFired = false;
  String pendingChartKey;

  PImage headerLogo;

  color bgColor = color(243, 246, 251);
  color cardColor = color(255);
  color cardStroke = color(214, 221, 235);
  color textColor = color(25, 33, 46);
  color mutedText = color(98, 107, 124);
  color accent = color(66, 116, 232);
  color accentSoft = color(232, 239, 255);
  color successCol = color(32, 142, 92);
  color warningCol = color(220, 148, 39);
  color dangerCol = color(194, 69, 69);
  color tabIdle = color(229, 234, 244);
  color tabHover = color(215, 222, 237);

  SearchScreen(ArrayList<Flight> allFlights, FlightFilter flightFilter) {
    this.allFlights = allFlights;
    this.flightFilter = flightFilter;
    headerLogo = loadImage("images/logo.gif");
    initializeFilterOptions();
    initializeInteractiveControls();
  }

  // Builds the string arrays that populate each dropdown
  void initializeFilterOptions() {
    carrierOptions = buildOptionsFromFlights("carrier", "Any carrier");
    originStateOptions = buildOptionsFromFlights("originState", "Any origin state");
    destinationStateOptions = buildOptionsFromFlights("destinationState", "Any destination state");
    distanceOptions = new String[] { "Any distance", "Under 500 mi", "500 - 1000 mi", "1001 - 1500 mi", "1501+ mi" };
    timeBucketOptions = new String[] { "Any departure", "Early Morning (00-05)", "Morning (06-11)", "Afternoon (12-16)", "Evening (17-20)", "Night (21-23)" };
    delayToleranceOptions = new String[] { "0 mins", "10 mins", "20 mins", "30 mins", "45 mins", "60 mins", "90 mins", "120 mins" };
  }

  // Creates all the UI widgets
  void initializeInteractiveControls() {
    sliders = new TimeSlider[chartKeys.length];
    searchButtons = new Button[chartKeys.length];
    resetButtons = new Button[chartKeys.length];
    tabButtons = new Button[chartKeys.length];
    cancelledBoxes = new CheckBox[chartKeys.length];
    divertedBoxes = new CheckBox[chartKeys.length];
    delayedOnlyBoxes = new CheckBox[chartKeys.length];
    onTimeOnlyBoxes = new CheckBox[chartKeys.length];
    carrierDropdowns = new Dropdown[chartKeys.length];
    originStateDropdowns = new Dropdown[chartKeys.length];
    destinationStateDropdowns = new Dropdown[chartKeys.length];
    distanceDropdowns = new Dropdown[chartKeys.length];
    timeBucketDropdowns = new Dropdown[chartKeys.length];
    delayToleranceDropdowns = new Dropdown[chartKeys.length];

    // Calculate where the tab row should start so it is centred on screen
    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * TAB_GAP;
    int tabStartX = (width - totalTabW) / 2;

    for (int i = 0; i < chartKeys.length; i++) {
      tabButtons[i] = new Button(tabStartX + i * (TAB_W + TAB_GAP), TAB_Y, TAB_W, TAB_H, chartLabels[i]);
      sliders[i] = new TimeSlider(0, 0, 460, "Scheduled Departure");
      sliders[i].setInterval(0, 1439);
      searchButtons[i] = new Button(0, 0, 148, 42, "Search");
      resetButtons[i] = new Button(0, 0, 124, 42, "Reset");
      cancelledBoxes[i] = new CheckBox(0, 0, 20, "Cancelled");
      divertedBoxes[i] = new CheckBox(0, 0, 20, "Diverted");
      delayedOnlyBoxes[i] = new CheckBox(0, 0, 20, "Only delayed");
      onTimeOnlyBoxes[i] = new CheckBox(0, 0, 20, "Only on-time");

      carrierDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Carrier", carrierOptions);
      originStateDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Origin state", originStateOptions);
      destinationStateDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Destination state", destinationStateOptions);
      distanceDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Distance", distanceOptions);
      timeBucketDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Departure bucket", timeBucketOptions);
      delayToleranceDropdowns[i] = new Dropdown(0, 0, 210, FIELD_H, "Delay tolerance", delayToleranceOptions);
    }
  }

  // Return the widget for the currently active tab
  Dropdown carrierDropdown() {
    return carrierDropdowns[activeTab];
  }

  Dropdown originStateDropdown() {
    return originStateDropdowns[activeTab];
  }

  Dropdown destinationStateDropdown() {
    return destinationStateDropdowns[activeTab];
  }

  Dropdown distanceDropdown() {
    return distanceDropdowns[activeTab];
  }

  Dropdown timeBucketDropdown() {
    return timeBucketDropdowns[activeTab];
  }

  Dropdown delayToleranceDropdown() {
    return delayToleranceDropdowns[activeTab];
  }

  void display() {
    background(bgColor);
    drawHeader();
    drawTabs();

    PanelRects rects = calculatePanelRects();
    drawPreviewPanel(rects.previewX, rects.bodyY, rects.previewW, rects.bodyH);
    drawFilterPanel(rects.filterX, rects.bodyY, rects.filterW, rects.bodyH);
    drawDropdownOverlays();
  }

  // Draws any dropdown that is currently open
  void drawDropdownOverlays() {
    if (carrierDropdown().isOpen) carrierDropdown().display();
    if (originStateDropdown().isOpen) originStateDropdown().display();
    if (destinationStateDropdown().isOpen) destinationStateDropdown().display();
    if (distanceDropdown().isOpen) distanceDropdown().display();
    if (timeBucketDropdown().isOpen) timeBucketDropdown().display();
    if (delayToleranceDropdown().isOpen) delayToleranceDropdown().display();
  }

  // Draws the white header bar at the top of the screen with the logo centred
  void drawHeader() {
    noStroke();
    fill(cardColor);
    rect(0, 0, width, HEADER_H);

    stroke(mutedText, 60);
    line(0, HEADER_H - 1, width, HEADER_H - 1);
    noStroke();

    if (headerLogo != null) {
      float maxLogoW = width - 40;
      float maxLogoH = HEADER_H - 16;
      float scale = min(maxLogoW / headerLogo.width, maxLogoH / headerLogo.height);
      float logoW = headerLogo.width * scale;
      float logoH = headerLogo.height * scale;

      imageMode(CENTER);
      image(headerLogo, width / 2.0, HEADER_H / 2.0, logoW, logoH);
      imageMode(CORNER);
    } else {
      // Fallback text if the image file is not found
      fill(textColor);
      textAlign(CENTER, CENTER);
      textSize(32);
      text("Flight Data Explorer", width / 2.0, HEADER_H / 2.0);
    }
  }

  // Draws the row of chart-selection tabs below the header
  void drawTabs() {
    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * TAB_GAP;
    int tabStartX = (width - totalTabW) / 2;

    for (int i = 0; i < chartLabels.length; i++) {
      tabButtons[i].x = tabStartX + i * (TAB_W + TAB_GAP);
      tabButtons[i].y = TAB_Y;

      boolean active = i == activeTab;
      boolean hover = mouseX >= tabButtons[i].x && mouseX <= tabButtons[i].x + TAB_W
          && mouseY >= tabButtons[i].y && mouseY <= tabButtons[i].y + TAB_H;

      noStroke();
      fill(active ? accent : hover ? tabHover : tabIdle);
      rect(tabButtons[i].x, tabButtons[i].y, TAB_W, TAB_H, 11);

      fill(active ? color(255) : textColor);
      textAlign(CENTER, CENTER);
      textSize(12);
      text(chartLabels[i], tabButtons[i].x + TAB_W / 2, tabButtons[i].y + TAB_H / 2);
    }
  }

  // Returns a PanelRects struct describing the positions and sizes of the filter panel (left) and preview panel (right)
  PanelRects calculatePanelRects() {
    PanelRects rects = new PanelRects();
    rects.bodyY = TAB_Y + TAB_H + 12;
    rects.bodyH = height - rects.bodyY - PADDING;
    rects.filterX = PADDING;
    rects.filterW = 470;
    rects.previewX = rects.filterX + rects.filterW + CARD_GAP;
    rects.previewW = width - rects.previewX - PADDING;
    return rects;
  }

  // The left-hand panel containing the time slider, dropdowns, checkboxes, and the Search / Reset buttons
  void drawFilterPanel(float x, float y, float w, float h) {
    drawCard(x, y, w, h);

    fill(textColor);
    textAlign(LEFT, TOP);
    textSize(18);
    text(chartLabels[activeTab], x + 20, y + 18);

    fill(mutedText);
    textSize(11);

    float sliderTop = y + 74;
    drawSmallLabel("", x + 20, sliderTop - 18);

    sliders[activeTab].x = x + 20;
    sliders[activeTab].y = sliderTop;
    sliders[activeTab].w = w - 40;
    sliders[activeTab].display();

    drawRangePill(x + 20, sliderTop + 34, w - 40, 26);

    float fieldsTop = sliderTop + 76;
    drawSmallLabel("", x + 20, fieldsTop - 18);
    drawCompactFilterGrid(x + 20, fieldsTop, w - 40);

    float buttonY = y + h - 60;
    drawActionButtons(x + 20, buttonY, w - 40);
  }

  // The right-hand panel that shows a live count and breakdown of how many flights currently match the filter settings
  void drawPreviewPanel(float x, float y, float w, float h) {
    drawCard(x, y, w, h);
    
    // Compute live statistics from the current filter selection
    ArrayList<Flight> previewFlights = buildFilteredFlightsFromCurrentSelections();
    int flightCount = previewFlights.size();
    int delayedCount = countDelayed(previewFlights);
    int onTimeCount = countOnTime(previewFlights);
    int cancelledCount = countCancelled(previewFlights);
    int divertedCount = countDiverted(previewFlights);

    fill(textColor);
    textAlign(LEFT, TOP);
    textSize(18);
    text("Data Preview", x + 20, y + 18);

    drawSummaryHero(x + 20, y + 64, w - 40, 70, flightCount);

    float statsY = y + 152;
    float statsW = (w - 54) / 2.0;
    drawStatTile("On-time", str(onTimeCount), x + 20, statsY, statsW, successCol);
    drawStatTile("Delayed", str(delayedCount), x + 34 + statsW, statsY, statsW, warningCol);

    statsY += 56;
    drawStatTile("Cancelled", str(cancelledCount), x + 20, statsY, statsW, dangerCol);
    drawStatTile("Diverted", str(divertedCount), x + 34 + statsW, statsY, statsW, warningCol);

    // Info blocks summarising each active filter in plain text
    float infoTop = y + 272;
    float infoX = x + 20;
    float infoW = w - 40;
    float gapX = 14;
    float gapY = 18;
    float rowH = 46;
    float colW = (infoW - gapX * 2) / 3.0;

    drawInfoBlock("Time", buildSelectedTimeSummary(), infoX, infoTop, colW);

    drawInfoBlock(
      "Carrier",
      simplifyAnyValue(getSelectedCarrier(), "Any carrier", "Any carrier"),
      infoX + colW + gapX,
      infoTop,
      colW
    );

    drawInfoBlock(
      "Route",
      buildRouteSummary(),
      infoX + (colW + gapX) * 2,
      infoTop,
      colW
    );

    drawInfoBlock(
      "Distance",
      simplifyAnyValue(getSelectedDistanceBand(), "Any distance", "Any distance"),
      infoX,
      infoTop + rowH + gapY,
      colW
    );

    drawInfoBlock(
      "Departure bucket",
      simplifyAnyValue(getSelectedTimeBucket(), "Any departure", "Any departure"),
      infoX + colW + gapX,
      infoTop + rowH + gapY,
      colW
    );

    drawInfoBlock(
      "Delay",
      buildDelayAndFlagSummary(),
      infoX + (colW + gapX) * 2,
      infoTop + rowH + gapY,
      colW
    );
  }

  // Positions and draws all dropdowns and checkboxes in a tidy two column grid
  void drawCompactFilterGrid(float x, float y, float availableW) {
    float gapX = 14;
    float colW = (availableW - gapX) / 2.0;

    drawDropdownPair(carrierDropdown(), originStateDropdown(), x, y, colW, gapX);
    y += FIELD_H + FIELD_GAP_Y;
    drawDropdownPair(destinationStateDropdown(), distanceDropdown(), x, y, colW, gapX);
    y += FIELD_H + FIELD_GAP_Y;
    drawDropdownPair(timeBucketDropdown(), delayToleranceDropdown(), x, y, colW, gapX);
    y += FIELD_H + FIELD_GAP_Y + 2;
    drawCheckboxPair(cancelledBoxes[activeTab], divertedBoxes[activeTab], x, y, colW, gapX);
    y += CHECKBOX_GAP_Y;
    drawCheckboxPair(delayedOnlyBoxes[activeTab], onTimeOnlyBoxes[activeTab], x, y, colW, gapX);
  }

  // Sets the position of two dropdowns side by side and draws them
  void drawDropdownPair(Dropdown left, Dropdown right, float x, float y, float colW, float gapX) {
    left.x = x;
    left.y = y;
    left.display();
    right.x = x + colW + gapX;
    right.y = y;
    right.display();
  }

  // Sets the position of two checkboxes side by side and draws them
  void drawCheckboxPair(CheckBox left, CheckBox right, float x, float y, float colW, float gapX) {
    left.x = x;
    left.y = y;
    left.display();
    right.x = x + colW + gapX;
    right.y = y;
    right.display();
  }

  // Draws the Reset and Search buttons right-aligned at the bottom
  void drawActionButtons(float x, float y, float availableW) {
    float totalW = 124 + 12 + 148;
    float startX = x + availableW - totalW;

    resetButtons[activeTab].x = startX;
    resetButtons[activeTab].y = y;
    resetButtons[activeTab].display();

    searchButtons[activeTab].x = startX + 136;
    searchButtons[activeTab].y = y;
    searchButtons[activeTab].display();
  }

  // Draws the large "N flights matching your filters" hero area at the top of the preview panel
  void drawSummaryHero(float x, float y, float w, float h, int flightCount) {
    noStroke();
    fill(accentSoft);
    rect(x, y, w, h, 12);

    fill(accent);
    textAlign(LEFT, TOP);
    textSize(28);
    text(str(flightCount), x + 16, y + 12);

    fill(textColor);
    textSize(13);
    text("Flights matching your filters", x + 16, y + 45);

    fill(mutedText);
    textSize(11);
  }

  // Draws a single coloured stat tile
  void drawStatTile(String label, String value, float x, float y, float w, color dotCol) {
    fill(color(250));
    stroke(cardStroke);
    rect(x, y, w, 42, 10);

    noStroke();
    fill(dotCol);
    ellipse(x + 12, y + 21, 9, 9);

    fill(textColor);
    textAlign(LEFT, CENTER);
    textSize(11);
    text(label, x + 24, y + 21);

    fill(mutedText);
    textAlign(RIGHT, CENTER);
    textSize(12);
    text(value, x + w - 10, y + 21);
  }

  // Used to summarise each active filter in the preview panel
  void drawInfoBlock(String label, String value, float x, float y, float w) {
    fill(textColor);
    textAlign(LEFT, TOP);
    textSize(11);
    text(label, x, y);

    fill(mutedText);
    textSize(11);
    text(value, x, y + 16, w, 28);
  }

  // Draws a pill-shaped text label showing the selected time range
  void drawRangePill(float x, float y, float w, float h) {
    noStroke();
    fill(color(248, 250, 254));
    rect(x, y, w, h, 10);

    fill(mutedText);
    textAlign(CENTER, CENTER);
    textSize(11);
    text(buildSelectedTimeSummary(), x + w / 2, y + h / 2);
  }

  // Draws a simple rounded-rectangle card background
  void drawCard(float x, float y, float w, float h) {
    fill(cardColor);
    stroke(cardStroke);
    strokeWeight(1);
    rect(x, y, w, h, CARD_RADIUS);
  }

  // Draws a small section label above a group of controls
  void drawSmallLabel(String label, float x, float y) {
    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(12);
    text(label, x, y);
  }

  // Returns a "HH:MM - HH:MM" string for the current slider range
  String buildSelectedTimeSummary() {
    return formatMinutes(sliders[activeTab].getStartTotalMinutes()) + " - "
        + formatMinutes(sliders[activeTab].getEndTotalMinutes());
  }

  // If value equals anyLabel returns fallback. Otherwise returns value as is
  String simplifyAnyValue(String value, String anyLabel, String fallback) {
    if (value == null || value.length() == 0 || value.equals(anyLabel)) return fallback;
    return value;
  }

  // Returns a OriginState to DestinationState summary string
  String buildRouteSummary() {
    String origin = simplifyAnyValue(getSelectedOriginState(), "Any origin state", "Any origin state");
    String destination = simplifyAnyValue(getSelectedDestinationState(), "Any destination state", "Any destination state");
    return origin + " to " + destination;
  }

  // Combines the delay tolerance number and any checkbox flags into one string
  String buildDelayAndFlagSummary() {
    String delayText = getSelectedDelayTolerance() + " mins tolerance";
    String flags = buildFlagSummary();
    if (flags.equals("default")) return delayText;
    return delayText + ", " + flags;
  }

  // Mouse pressed event handler
  void handleMousePressed() {
    if (handleTabClick()) return;

    sliders[activeTab].handleMousePressed();
    handleDropdownPressed();
    handleCheckBoxPressed();
    layoutActionButtonsForHitTesting();

    if (resetButtons[activeTab].isClicked()) {
      resetFilters();
      return;
    }
    if (searchButtons[activeTab].isClicked()) {
      fireSearch();
    }
  }

  // Checks whether any tab button was clicked and switches to it
  boolean handleTabClick() {
    int totalTabW = chartLabels.length * TAB_W + (chartLabels.length - 1) * TAB_GAP;
    int tabStartX = (width - totalTabW) / 2;

    for (int i = 0; i < chartLabels.length; i++) {
      float tx = tabStartX + i * (TAB_W + TAB_GAP);
      if (mouseX >= tx && mouseX <= tx + TAB_W && mouseY >= TAB_Y && mouseY <= TAB_Y + TAB_H) {
        activeTab = i;
        return true;
      }
    }
    return false;
  }

  // Forwards a mouse press event to all dropdowns so they can open/close or register a selection
  void handleDropdownPressed() {
    carrierDropdown().handleMousePressed();
    originStateDropdown().handleMousePressed();
    destinationStateDropdown().handleMousePressed();
    distanceDropdown().handleMousePressed();
    timeBucketDropdown().handleMousePressed();
    delayToleranceDropdown().handleMousePressed();
  }

  // Handles checkbox toggles
  void handleCheckBoxPressed() {
    if (cancelledBoxes[activeTab].isMouseOver()) {
      cancelledBoxes[activeTab].setChecked(!cancelledBoxes[activeTab].isChecked());
    }

    if (divertedBoxes[activeTab].isMouseOver()) {
      divertedBoxes[activeTab].setChecked(!divertedBoxes[activeTab].isChecked());
    }

    if (delayedOnlyBoxes[activeTab].isMouseOver()) {
      boolean next = !delayedOnlyBoxes[activeTab].isChecked();
      delayedOnlyBoxes[activeTab].setChecked(next);
      if (next) onTimeOnlyBoxes[activeTab].setChecked(false);
    }

    if (onTimeOnlyBoxes[activeTab].isMouseOver()) {
      boolean next = !onTimeOnlyBoxes[activeTab].isChecked();
      onTimeOnlyBoxes[activeTab].setChecked(next);
      if (next) delayedOnlyBoxes[activeTab].setChecked(false);
    }
  }

  void layoutActionButtonsForHitTesting() {
    PanelRects rects = calculatePanelRects();
    float x = rects.filterX + 20;
    float availableW = rects.filterW - 40;
    float y = rects.bodyY + rects.bodyH - 60;
    float startX = x + availableW - (124 + 12 + 148);

    resetButtons[activeTab].x = startX;
    resetButtons[activeTab].y = y;
    searchButtons[activeTab].x = startX + 136;
    searchButtons[activeTab].y = y;
  }

  // Records which chart is active and signals the main sketch
  void fireSearch() {
    pendingChartKey = chartKeys[activeTab];
    searchFired = true;
  }

  // Resets all controls back to their default state
  void resetFilters() {
    initializeInteractiveControls();
    searchFired = false;
  }

  // Sends users search filter to filter criteria and forms flight filter
  FilterCriteria buildCriteriaFromCurrentSelections() {
    FilterCriteria criteria = new FilterCriteria();
    criteria.startMinutes = sliders[activeTab].getStartTotalMinutes();
    criteria.endMinutes = sliders[activeTab].getEndTotalMinutes();
    criteria.includeCancelled = cancelledBoxes[activeTab].isChecked();
    criteria.includeDiverted = divertedBoxes[activeTab].isChecked();
    criteria.onlyDelayed = delayedOnlyBoxes[activeTab].isChecked();
    criteria.onlyOnTime = onTimeOnlyBoxes[activeTab].isChecked();
    criteria.toleranceMinutes = getSelectedDelayTolerance();

    criteria.selectedCarrier = getSelectedCarrier();
    criteria.selectedOriginState = getSelectedOriginState();
    criteria.selectedDestinationState = getSelectedDestinationState();
    criteria.selectedDistanceBand = getSelectedDistanceBand();
    criteria.selectedTimeBucket = getSelectedTimeBucket();
    return criteria;
  }

  ArrayList<Flight> buildFilteredFlightsFromCurrentSelections() {
    return flightFilter.filter(allFlights, buildCriteriaFromCurrentSelections());
  }

  // Returns number of cancelled flights
  int countCancelled(ArrayList<Flight> data) {
    int count = 0;
    for (int i = 0; i < data.size(); i++) {
      if (data.get(i).cancelled == 1) count++;
    }
    return count;
  }

  // Returns number of diverted flights
  int countDiverted(ArrayList<Flight> data) {
    int count = 0;
    for (int i = 0; i < data.size(); i++) {
      if (data.get(i).diverted == 1) count++;
    }
    return count;
  }

  // Returns number of delayed flights
  int countDelayed(ArrayList<Flight> data) {
    int count = 0;
    int toleranceMinutes = getSelectedDelayTolerance();
    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      if (f.cancelled == 1) continue;
      if (f.isDelayedDeparture(toleranceMinutes)) count++;
    }
    return count;
  }

  // Returns number of ontime flights
  int countOnTime(ArrayList<Flight> data) {
    int count = 0;
    int toleranceMinutes = getSelectedDelayTolerance();
    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      if (f.cancelled == 1) continue;
      if (f.isOnTimeOrEarlyDeparture(toleranceMinutes)) count++;
    }
    return count;
  }

  // Returns selected delay tolerance
  int getSelectedDelayTolerance() {
    String selected = delayToleranceDropdown().getSelected();
    if (selected == null || selected.length() == 0 || selected.equals("Delay tolerance")) return 0;
    return int(split(selected, ' ')[0]);
  }

  // Returns selected carrier
  String getSelectedCarrier() {
    return getSelectedOrFallback(carrierDropdown(), "Any carrier", "Carrier");
  }

  // Returns selected origin state
  String getSelectedOriginState() {
    return getSelectedOrFallback(originStateDropdown(), "Any origin state", "Origin state");
  }

  // Returns selected destination state
  String getSelectedDestinationState() {
    return getSelectedOrFallback(destinationStateDropdown(), "Any destination state", "Destination state");
  }

  // Returns selected distance band
  String getSelectedDistanceBand() {
    return getSelectedOrFallback(distanceDropdown(), "Any distance", "Distance");
  }

  // Returns selected time bucket
  String getSelectedTimeBucket() {
    return getSelectedOrFallback(timeBucketDropdown(), "Any departure", "Departure bucket");
  }

  String getSelectedOrFallback(Dropdown dropdown, String fallback, String placeholder) {
    String selected = dropdown.getSelected();
    if (selected == null || selected.length() == 0 || selected.equals(placeholder)) return fallback;
    return selected;
  }

  // Builds preview sumary
  String buildFlagSummary() {
    ArrayList<String> flags = new ArrayList<String>();
    if (cancelledBoxes[activeTab].isChecked()) flags.add("include cancelled");
    if (divertedBoxes[activeTab].isChecked()) flags.add("include diverted");
    if (delayedOnlyBoxes[activeTab].isChecked()) flags.add("only delayed");
    if (onTimeOnlyBoxes[activeTab].isChecked()) flags.add("only on-time");

    if (flags.size() == 0) return "default";

    String result = "";
    for (int i = 0; i < flags.size(); i++) {
      if (i > 0) result += ", ";
      result += flags.get(i);
    }
    return result;
  }

  String formatMinutes(int totalMinutes) {
    int h = totalMinutes / 60;
    int m = totalMinutes % 60;
    return nf(h, 2) + ":" + nf(m, 2);
  }

  String[] buildOptionsFromFlights(String key, String anyLabel) {
    ArrayList<String> values = new ArrayList<String>();

    for (int i = 0; i < allFlights.size(); i++) {
      Flight f = allFlights.get(i);
      String value = getFlightFieldValue(f, key);
      if (value != null) value = trim(value);
      if (value != null && value.length() > 0 && !values.contains(value)) {
        values.add(value);
      }
    }

    String[] sorted = new String[values.size()];
    for (int i = 0; i < values.size(); i++) {
      sorted[i] = values.get(i);
    }
    sorted = sort(sorted);

    String[] result = new String[sorted.length + 1];
    result[0] = anyLabel;
    for (int i = 0; i < sorted.length; i++) {
      result[i + 1] = sorted[i];
    }
    return result;
  }

  String getFlightFieldValue(Flight f, String key) {
    if (key.equals("carrier")) return f.carrier;
    if (key.equals("originState")) return f.originStateAbr;
    if (key.equals("destinationState")) return f.destinationStateAbr;
    return "";
  }

  void handleMouseMoved() {
    carrierDropdown().handleMouseMoved();
    originStateDropdown().handleMouseMoved();
    destinationStateDropdown().handleMouseMoved();
    distanceDropdown().handleMouseMoved();
    timeBucketDropdown().handleMouseMoved();
    delayToleranceDropdown().handleMouseMoved();
  }

  void handleMouseDragged() {
    sliders[activeTab].handleMouseDragged();
    carrierDropdown().handleMouseDragged();
    originStateDropdown().handleMouseDragged();
    destinationStateDropdown().handleMouseDragged();
    distanceDropdown().handleMouseDragged();
    timeBucketDropdown().handleMouseDragged();
    delayToleranceDropdown().handleMouseDragged();
  }

  void handleMouseReleased() {
    sliders[activeTab].handleMouseReleased();
  }

  void handleMouseWheel(float amount) {
    carrierDropdown().handleMouseWheel(amount);
    originStateDropdown().handleMouseWheel(amount);
    destinationStateDropdown().handleMouseWheel(amount);
    distanceDropdown().handleMouseWheel(amount);
    timeBucketDropdown().handleMouseWheel(amount);
    delayToleranceDropdown().handleMouseWheel(amount);
  }

  class PanelRects {
    float bodyY, bodyH;
    float filterX, filterW;
    float previewX, previewW;
  }
}
