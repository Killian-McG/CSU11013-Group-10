// MAIN AUTHOR: Cameron - Week 3

// Editor: Killian - Week 4
//          Improved code layout and fixed cosmetic issues

// DATA SCREEN
//  SHows results of search screen after user confirms filters
//  Draws selected chart on the left and scrollable metric summary on the right

class DataScreen {
  
  // Layout constants
  final float PADDING = 18;
  final float HEADER_H = 78;
  final float CARD_RADIUS = 18;
  final float CARD_GAP = 18;
  final float SIDEBAR_W = 360;

  // Colour palette
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
  color buttonHover = color(52, 100, 212);
  color surfaceTint = color(248, 250, 254);
  color scrollbarTrack = color(232, 236, 244);
  color scrollbarThumb = color(176, 186, 205);

  // Defults for when search page first loads
  String currentChart = "histogram";
  boolean homeFired = false;

  // All four chart types are instantiated
  Histogram histogram;
  BarChart barChart;
  ScatterPlot scatterPlot;
  PieChart pieChart;
  
  // Computes sidebar stats
  MetricsCalculator metricsCalculator;
  ArrayList<Flight> activeFlights;
  int delayToleranceMinutes = 0;
  PImage headerLogo;

  float sidebarScroll = 0;
  float sidebarTargetScroll = 0;
  float sidebarViewportX = 0;
  float sidebarViewportY = 0;
  float sidebarViewportW = 0;
  float sidebarViewportH = 0;
  float sidebarContentH = 0;

  // Constructor: creates all chart instances and initialises state
  DataScreen() {
    histogram = new Histogram();
    barChart = new BarChart();
    scatterPlot = new ScatterPlot();
    pieChart = new PieChart(width / 2, height / 2, 300);
    metricsCalculator = new MetricsCalculator();
    activeFlights = new ArrayList<Flight>();
    headerLogo = loadImage("images/logo.gif");
  }

  // Sets users choice of chart
  void setChart(String chartName) {
    currentChart = chartName;
    
    // Resets sidebar scroll position when changing chart
    sidebarScroll = 0;
    sidebarTargetScroll = 0;
  }

  // Replaces the flight data with new filtered flights
  void setActiveFlights(ArrayList<Flight> flights) {
    if (flights == null) {
      activeFlights = new ArrayList<Flight>();
    } else {
      activeFlights = flights;
    }
  }

  // Stores the delay tolerance so charts that need it
  void setDelayToleranceMinutes(int minutes) {
    delayToleranceMinutes = max(0, minutes);
  }

  // Called by the main sketchs mouseWheel event
  void handleMouseWheel(float amount) {
    if (mouseX >= sidebarViewportX && mouseX <= sidebarViewportX + sidebarViewportW
        && mouseY >= sidebarViewportY && mouseY <= sidebarViewportY + sidebarViewportH) {
      sidebarTargetScroll += amount * 42;
    }
  }
  
 void display() {
    background(bgColor);

    // Compute metrics for sidebar
    ScreenMetrics metrics = metricsCalculator.computeMetrics(activeFlights, delayToleranceMinutes);
    ArrayList<SidebarGroup> groups = buildSidebarGroups(metrics);

    drawHeader(metrics);

    // Calculate the body area below the header
    float bodyY = HEADER_H + PADDING;
    float bodyH = height - bodyY - PADDING;
    float chartX = PADDING;
    float chartW = width - PADDING * 3 - SIDEBAR_W;
    float sidebarX = chartX + chartW + CARD_GAP;

    drawChartCard(chartX, bodyY, chartW, bodyH, activeFlights, metrics);
    drawSidebar(sidebarX, bodyY, SIDEBAR_W, bodyH, metrics, groups);
  }

  // Draws header with chart title and project logo
  void drawHeader(ScreenMetrics metrics) {
    drawCard(0, 0, width, HEADER_H, 0);

    if (headerLogo != null) {
      float maxLogoW = 220;
      float maxLogoH = HEADER_H - 18;
      float scale = min(maxLogoW / headerLogo.width, maxLogoH / headerLogo.height);
      float logoW = headerLogo.width * scale;
      float logoH = headerLogo.height * scale;
      imageMode(CORNER);
      image(headerLogo, PADDING, (HEADER_H - logoH) / 2.0, logoW, logoH);
    }

    fill(textColor);
    noStroke();
    textAlign(CENTER, CENTER);
    textSize(26);
    text(getChartTitle(), width / 2.0, HEADER_H / 2.0);

    drawHomeButton();
  }

  // Draws the Home button in the top-right corner
  void drawHomeButton() {
    float bw = 118;
    float bh = 36;
    float bx = width - bw - PADDING;
    float by = 18;
    boolean hov = mouseX >= bx && mouseX <= bx + bw
        && mouseY >= by && mouseY <= by + bh;

    noStroke();
    fill(hov ? buttonHover : accent);
    rect(bx, by, bw, bh, 12);

    fill(255);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("< Home", bx + bw / 2, by + bh / 2);
  }

  // Chart sits within a padded acrd so every graph is framed the smae way
  void drawChartCard(float x, float y, float w, float h, ArrayList<Flight> data, ScreenMetrics metrics) {
    drawCard(x, y, w, h, CARD_RADIUS);

    // Inner frame
    float frameX = x + 18;
    float frameY = y + 18;
    float frameW = w - 36;
    float frameH = h - 36;

    noStroke();
    fill(surfaceTint);
    rect(frameX, frameY, frameW, frameH, 16);

    drawGraph(frameX, frameY, frameW, frameH, data);
  }

  // Measures how wide a rounded tag label should be
  float measureTagWidth(String label) {
    textSize(10);
    return textWidth(label) + 22;
  }

  // Draws a small pill-shaped colour tag
  void drawChartTag(float x, float y, String label, color bg, color fg) {
    float w = measureTagWidth(label);
    noStroke();
    fill(bg);
    rect(x, y, w, 22, 11);
    fill(fg);
    textAlign(CENTER, CENTER);
    textSize(10);
    text(label, x + w / 2, y + 11);
  }

  // The sidebar can overflow vertically, so it is clipped with a scrollbar
  void drawSidebar(float x, float y, float w, float h, ScreenMetrics metrics, ArrayList<SidebarGroup> groups) {
    drawCard(x, y, w, h, CARD_RADIUS);

    // "Relevant metrics" heading at the top of the sidebar
    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(18);
    text("Relevant metrics", x + 18, y + 18);

    // Store viewport bounds so handleMouseWheel can check whether the cursor is inside the scrollable area
    sidebarViewportX = x + 14;
    sidebarViewportY = y + 54;
    sidebarViewportW = w - 28;
    sidebarViewportH = h - 68;

    float contentW = sidebarViewportW - 6;
    sidebarContentH = measureSidebarContentHeight(contentW, groups);
    float maxScroll = max(0, sidebarContentH - sidebarViewportH);

    // Clamp and smoothly animate the scroll position
    sidebarTargetScroll = constrain(sidebarTargetScroll, 0, maxScroll);
    sidebarScroll = lerp(sidebarScroll, sidebarTargetScroll, maxScroll > 0 ? 0.22 : 0.32);
    if (abs(sidebarScroll - sidebarTargetScroll) < 0.4) {
      sidebarScroll = sidebarTargetScroll;
    }

    float clipW = sidebarViewportW - (maxScroll > 0 ? 12 : 0);

    // Clip so cards below the fold dont draw over the rest of the screen
    clip(int(sidebarViewportX), int(sidebarViewportY), int(clipW), int(sidebarViewportH));
    pushMatrix();
    
    // Shift the content upward by the scroll offset.
    translate(0, -sidebarScroll);
    drawSidebarContent(sidebarViewportX, sidebarViewportY, clipW, metrics, groups);
    popMatrix();
    noClip();

    if (maxScroll > 0) {
      drawScrollbar(x + w - 12, sidebarViewportY, 6, sidebarViewportH, maxScroll);
    }
  }

  // Returns true if the sidebar content is taller than the visible area
  boolean needsScroll(float w, float h, ArrayList<SidebarGroup> groups) {
    float viewportH = h - 68;
    float contentH = measureSidebarContentHeight(w - 34, groups);
    return contentH > viewportH + 1;
  }

  // Calculates the total pixel height of all sidebar content
  float measureSidebarContentHeight(float w, ArrayList<SidebarGroup> groups) {
    float h = 128 + 18;
    for (int i = 0; i < groups.size(); i++) {
      SidebarGroup g = groups.get(i);
      h += 28 + g.tiles.length * 68 + 10;
    }
    h += 12;
    return h;
  }

  // Draws the hero card followed by each metric group
  void drawSidebarContent(float x, float y, float w, ScreenMetrics metrics, ArrayList<SidebarGroup> groups) {
    float cy = y;
    cy = drawHeroCard(x, cy, w, metrics);
    cy += 18;
    for (int i = 0; i < groups.size(); i++) {
      cy = drawSidebarGroup(x, cy, w, groups.get(i));
      cy += 10;
    }
  }

  // Large coloured card at top of relevant metrics
  float drawHeroCard(float x, float y, float w, ScreenMetrics metrics) {
    float h = 128;

    noStroke();
    fill(accentSoft);
    rect(x, y, w, h, 16);

    fill(accent);
    rect(x + 16, y + 16, 74, 24, 12);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(10);
    text("Overview", x + 53, y + 28);

    fill(textColor);
    textAlign(LEFT, TOP);
    textSize(24);
    textLeading(24);
    text(getHeroValue(metrics), x + 18, y + 50, w - 36, 30);

    fill(textColor);
    textSize(12);
    text(getHeroSubline(metrics), x + 18, y + 88, w - 36, 18);

    return y + h;
  }

  // Draws a labelled group of metric tiles with a section heading
  float drawSidebarGroup(float x, float y, float w, SidebarGroup group) {
    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(15);
    text(group.title, x + 2, y);

    float cy = y + 28;
    for (int i = 0; i < group.tiles.length; i++) {
      drawMetricTile(x, cy, w, group.tiles[i]);
      cy += 68;
    }
    return cy;
  }

  // Draws a single metric tile containing a small coloured bar with data
  void drawMetricTile(float x, float y, float w, MetricTile tile) {
    color tileBg = lerpColor(color(255), tile.valueColor, 0.06);
    color tileStroke = lerpColor(cardStroke, tile.valueColor, 0.14);

    noStroke();
    fill(20, 28, 45, 8);
    rect(x, y + 4, w, 58, 14);

    fill(tileBg);
    stroke(tileStroke);
    strokeWeight(1);
    rect(x, y, w, 58, 14);

    noStroke();
    fill(tile.valueColor);
    rect(x + 14, y + 15, 4, 28, 2);

    fill(mutedText);
    textAlign(LEFT, TOP);
    textSize(10);
    text(tile.label, x + 28, y + 12, w - 42, 12);

    fill(textColor);
    textSize(16);
    textLeading(16);
    text(tile.value, x + 28, y + 28, w - 42, 18);
  }

  // Draws the vertical scrollbar track and thumb on the right edge of the sidebar
  void drawScrollbar(float x, float y, float w, float h, float maxScroll) {
    noStroke();
    fill(scrollbarTrack);
    rect(x, y, w, h, 4);

    float thumbH = max(42, h * (h / sidebarContentH));
    float thumbY = y + (sidebarScroll / maxScroll) * (h - thumbH);

    fill(scrollbarThumb);
    rect(x, thumbY, w, thumbH, 4);
  }

  // Draws a white rounded-rectangle card with a subtle drop shadow and a light border
  void drawCard(float x, float y, float w, float h, float radius) {
    noStroke();
    fill(20, 28, 45, 12);
    rect(x, y + 6, w, h, radius);

    fill(cardColor);
    stroke(cardStroke);
    strokeWeight(1);
    rect(x, y, w, h, radius);
  }

  // Draws users chosen graph
  void drawGraph(float gx, float gy, float gw, float gh, ArrayList<Flight> data) {
    clip(int(gx + 2), int(gy + 2), int(gw - 4), int(gh - 4));
    pushMatrix();

    // Scale chart into chart card
    float scaleX = gw / width;
    float scaleY = gh / height;
    float s = min(scaleX, scaleY);
    float scaledW = width * s;
    float scaledH = height * s;
    float offsetX = gx + (gw - scaledW) / 2.0;
    float offsetY = gy + (gh - scaledH) / 2.0;

    // Converts mouse coordinates to chart coordinates to ensure hover logic still works
    float localMouseX = (mouseX - offsetX) / s;
    float localMouseY = (mouseY - offsetY) / s;

    translate(offsetX, offsetY);
    scale(s);

    // Call the appropriate charts draw method
    if (currentChart.equals("histogram")) {
      histogram.setHoverMouse(localMouseX, localMouseY);
      histogram.display(data);
    } else if (currentChart.equals("barchart")) {
      barChart.setHoverMouse(localMouseX, localMouseY);
      barChart.drawBarChart(data);
    } else if (currentChart.equals("scatterplot")) {
      scatterPlot.setHoverMouse(localMouseX, localMouseY);
      scatterPlot.drawScatterPlot(data);
    } else if (currentChart.equals("piechart")) {
      pieChart.setHoverMouse(localMouseX, localMouseY);
      pieChart.display(data, delayToleranceMinutes);
    } else {
      background(245);
      fill(mutedText);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("No chart selected", width / 2, height / 2);
    }

    popMatrix();
    noClip();
  }

  // Detects home button click
  void handleMousePressed() {
    float bw = 118, bh = 36;
    float bx = width - bw - PADDING;
    float by = 18;
    if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
      homeFired = true;
    }
  }

  // Sets chart title in header
  String getChartTitle() {
    if (currentChart.equals("histogram")) return "Histogram";
    if (currentChart.equals("barchart")) return "Bar Chart";
    if (currentChart.equals("scatterplot")) return "Scatter Plot";
    if (currentChart.equals("piechart")) return "Pie Chart";
    return "Graph";
  }
  
  // Sets cart secondary title
  String getChartPanelTitle() {
    if (currentChart.equals("histogram")) return "Flights Per Hour";
    if (currentChart.equals("barchart")) return "Flights by Origin Airport";
    if (currentChart.equals("scatterplot")) return "Scheduled vs Actual Departure Time";
    if (currentChart.equals("piechart")) return "Flight Status Breakdown";
    return "Flight Data";
  }

  // Returns metrics primary tag
  String getPrimaryTag(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "No matching data";
    if (currentChart.equals("histogram")) return "Peak hour: " + formatHourLabel(metrics.peakHour);
    if (currentChart.equals("barchart")) return "Top origin: " + safeLabel(metrics.topOrigin, "N/A");
    if (currentChart.equals("scatterplot")) return "Avg delta: " + formatDelay(metrics.averageDelay);
    if (currentChart.equals("piechart")) return "Largest slice: " + getLargestPieLabel(metrics);
    return "Filtered results";
  }

  // Returns metrics secondary tag
  String getSecondaryTag(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "Adjust your search filters";
    if (currentChart.equals("histogram")) return str(metrics.activeHours) + " active hours";
    if (currentChart.equals("barchart")) return str(metrics.uniqueOrigins) + " origin airports";
    if (currentChart.equals("scatterplot")) return str(metrics.scatterPoints) + " plotted flights";
    if (currentChart.equals("piechart")) return formatPercent(metrics.onTimeSliceRate) + " on-time";
    return str(metrics.totalFlights) + " flights";
  }

  // Returns the big headline value shown in the hero card
  String getHeroValue(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "No data in view";
    if (currentChart.equals("histogram")) return formatHourLabel(metrics.peakHour);
    if (currentChart.equals("barchart")) return safeLabel(metrics.topOrigin, "N/A");
    if (currentChart.equals("scatterplot")) return formatDelay(metrics.averageDelay);
    if (currentChart.equals("piechart")) return getLargestPieLabel(metrics);
    return str(metrics.totalFlights) + " flights";
  }

  // Returns the explanatory sub-line below the hero value
  String getHeroSubline(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "Try widening the filters from the search screen.";
    if (currentChart.equals("histogram")) {
      return pluralize(metrics.peakHourCount, "flight", "flights") + " in the busiest hour";
    }
    if (currentChart.equals("barchart")) {
      return pluralize(metrics.topOriginCount, "flight", "flights") + " • " + formatPercent(metrics.topOriginShare);
    }
    if (currentChart.equals("scatterplot")) {
      return formatPercent(metrics.onTimeRate) + " on time or early";
    }
    if (currentChart.equals("piechart")) {
      return formatPercent(getLargestPieRate(metrics)) + " of classified flights";
    }
    return pluralize(metrics.totalFlights, "flight", "flights");
  }

  // Returns a list of SidebarGroup objects to display
  ArrayList<SidebarGroup> buildSidebarGroups(ScreenMetrics metrics) {
    ArrayList<SidebarGroup> groups = new ArrayList<SidebarGroup>();

    // Each chart gets a different set of side metrics so the panel stays relevant instead of showing one generic summary
    // Histogram sidebar
    if (currentChart.equals("histogram")) {
      groups.add(new SidebarGroup(
        "Departure distribution",
        new MetricTile[] {
          new MetricTile("Peak departure hour", formatHourLabel(metrics.peakHour), accent),
          new MetricTile("Peak hour volume", pluralize(metrics.peakHourCount, "flight", "flights"), textColor),
          new MetricTile("Quietest active hour", formatHourLabel(metrics.quietHour), textColor),
          new MetricTile("Active hours", str(metrics.activeHours) + " hours", textColor)
        }
      ));

      groups.add(new SidebarGroup(
        "Coverage and concentration",
        new MetricTile[] {
          new MetricTile("Flights shown", pluralize(metrics.totalFlights, "flight", "flights"), textColor),
          new MetricTile("Valid scheduled times", pluralize(metrics.validScheduledFlights, "record", "records"), accent),
          new MetricTile("Average per active hour", metrics.activeHours > 0 ? nf((float) metrics.validScheduledFlights / metrics.activeHours, 0, 1) + " flights" : "0.0 flights", textColor),
          new MetricTile("Evening departures", formatPercent(metrics.eveningRate), warningCol)
        }
      ));
      return groups;
    }
    
    // Bar chart sidebar
    if (currentChart.equals("barchart")) {
      groups.add(new SidebarGroup(
        "Airport concentration",
        new MetricTile[] {
          new MetricTile("Busiest origin", safeLabel(metrics.topOrigin, "N/A"), accent),
          new MetricTile("Flights from top origin", pluralize(metrics.topOriginCount, "flight", "flights") + " • " + formatPercent(metrics.topOriginShare), textColor),
          new MetricTile("Top 3 origins share", formatPercent(metrics.topThreeOriginShare), warningCol),
          new MetricTile("Top 5 origins share", formatPercent(metrics.topFiveOriginShare), warningCol)
        }
      ));

      groups.add(new SidebarGroup(
        "Breadth of origins",
        new MetricTile[] {
          new MetricTile("Unique origins", str(metrics.uniqueOrigins) + " airports", textColor),
          new MetricTile("Average flights per origin", metrics.uniqueOrigins > 0 ? nf(metrics.averageFlightsPerOrigin, 0, 1) + " flights" : "0.0 flights", textColor),
          new MetricTile("Top origin lead", metrics.uniqueOrigins > 1 ? str(max(0, metrics.topOriginCount - metrics.secondOriginCount)) + " flights" : "Only origin in view", accent),
          new MetricTile("Flights shown", pluralize(metrics.totalFlights, "flight", "flights"), textColor)
        }
      ));
      return groups;
    }

    // Scatter plot sidebar
    if (currentChart.equals("scatterplot")) {
      groups.add(new SidebarGroup(
        "Departure punctuality",
        new MetricTile[] {
          new MetricTile("Flights plotted", pluralize(metrics.scatterPoints, "flight", "flights"), accent),
          new MetricTile("Average departure delta", formatDelay(metrics.averageDelay), textColor),
          new MetricTile("On-time or early", formatPercent(metrics.onTimeRate), successCol),
          new MetricTile("Delayed departures", formatPercent(metrics.delayedRate), warningCol)
        }
      ));

      groups.add(new SidebarGroup(
        "Data coverage",
        new MetricTile[] {
          new MetricTile("Timed coverage", formatPercent(metrics.timedCoverageRate), accent),
          new MetricTile("Worst late departure", metrics.maxDelay == Integer.MIN_VALUE ? "N/A" : formatDelay(metrics.maxDelay), dangerCol),
          new MetricTile("Earliest departure gain", metrics.minDelay == Integer.MAX_VALUE ? "N/A" : formatDelay(metrics.minDelay), successCol),
          new MetricTile("Cancelled excluded", pluralize(metrics.cancelledFlights, "flight", "flights"), textColor)
        }
      ));
      return groups;
    }
    
    // Pie chart sidebar
    if (currentChart.equals("piechart")) {
      groups.add(new SidebarGroup(
        "Status breakdown",
        new MetricTile[] {
          new MetricTile("On-time", pluralize(metrics.onTimeFlights, "flight", "flights") + " • " + formatPercent(metrics.onTimeSliceRate), successCol),
          new MetricTile("Late", pluralize(metrics.delayedFlights, "flight", "flights") + " • " + formatPercent(metrics.lateSliceRate), warningCol),
          new MetricTile("Cancelled", pluralize(metrics.cancelledFlights, "flight", "flights") + " • " + formatPercent(metrics.cancelledRate), dangerCol)
        }
      ));

      groups.add(new SidebarGroup(
        "Overall stats",
        new MetricTile[] {
          new MetricTile("Largest segment", getLargestPieLabel(metrics), accent),
          new MetricTile("Classified flights", pluralize(metrics.classifiedFlights, "flight", "flights"), textColor),
          new MetricTile("Operational departures", pluralize(metrics.onTimeFlights + metrics.delayedFlights, "flight", "flights"), textColor),
          new MetricTile("Cancellation burden", formatPercent(metrics.cancelledRate), dangerCol)
        }
      ));
      return groups;
    }

    groups.add(new SidebarGroup(
      "Filtered summary",
      new MetricTile[] {
        new MetricTile("Flights shown", pluralize(metrics.totalFlights, "flight", "flights"), accent)
      }
    ));
    return groups;
  }

  // Converts a 0-23 hour integer to a display string
  String formatHourLabel(int hour) {
    if (hour < 0 || hour > 23) return "N/A";
    return nf(hour, 2) + ":00-" + nf(hour, 2) + ":59";
  }

  // Formats a delay in minutes
  String formatDelay(int minutes) {
    if (minutes == Integer.MIN_VALUE || minutes == Integer.MAX_VALUE) return "N/A";
    if (minutes > 0) return "+" + minutes + " min";
    if (minutes < 0) return str(minutes) + " min";
    return "0 min";
  }

  // Converts a 0.0–1.0 fraction to a percentage string
  String formatPercent(float value) {
    return nf(value * 100.0, 0, 1) + "%";
  }

  // Returns null if the string is null or empty
  String cleanValue(String value) {
    if (value == null) return null;
    String trimmed = trim(value);
    return trimmed.length() == 0 ? null : trimmed;
  }

  // Used to avoid displaying blank strings in UI labels
  String safeLabel(String value, String fallback) {
    if (value == null || value.length() == 0) return fallback;
    return value;
  }

  // Makes string noun plural
  String pluralize(int value, String singular, String plural) {
    return value == 1 ? "1 " + singular : str(value) + " " + plural;
  }

  // Returns the label of whichever pie slice is largest
  String getLargestPieLabel(ScreenMetrics metrics) {
    float best = metrics.onTimeSliceRate;
    String label = "On-time";
    if (metrics.lateSliceRate > best) {
      best = metrics.lateSliceRate;
      label = "Late";
    }
    if (metrics.cancelledRate > best) {
      label = "Cancelled";
    }
    return label;
  }

  // Returns the rate value of the largest pie slice
  float getLargestPieRate(ScreenMetrics metrics) {
    float best = metrics.onTimeSliceRate;
    if (metrics.lateSliceRate > best) best = metrics.lateSliceRate;
    if (metrics.cancelledRate > best) best = metrics.cancelledRate;
    return best;
  }

  // Holds the label, value, and colour for one metric tile in the sidebar
  class MetricTile {
    String label, value;
    color valueColor;

    MetricTile(String label, String value, color valueColor) {
      this.label = label;
      this.value = value;
      this.valueColor = valueColor;
    }
  }

  // Groups a set of MetricTiles under a shared section heading
  class SidebarGroup {
    String title;
    MetricTile[] tiles;

    SidebarGroup(String title, MetricTile[] tiles) {
      this.title = title;
      this.tiles = tiles;
    }
  }

}
