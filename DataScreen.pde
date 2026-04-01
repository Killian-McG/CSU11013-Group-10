class DataScreen {
  final float PADDING = 18;
  final float HEADER_H = 78;
  final float CARD_RADIUS = 18;
  final float CARD_GAP = 18;
  final float SIDEBAR_W = 360;

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

  String currentChart = "histogram";
  boolean homeFired = false;

  Histogram histogram;
  BarChart barChart;
  ScatterPlot scatterPlot;
  PieChart pieChart;

  float sidebarScroll = 0;
  float sidebarTargetScroll = 0;
  float sidebarViewportX = 0;
  float sidebarViewportY = 0;
  float sidebarViewportW = 0;
  float sidebarViewportH = 0;
  float sidebarContentH = 0;

  DataScreen() {
    histogram = new Histogram();
    barChart = new BarChart();
    scatterPlot = new ScatterPlot();
    pieChart = new PieChart(width / 2, height / 2, 300);
  }

  void setChart(String chartName) {
    currentChart = chartName;
    sidebarScroll = 0;
    sidebarTargetScroll = 0;
  }

  void handleMouseWheel(float amount) {
    if (mouseX >= sidebarViewportX && mouseX <= sidebarViewportX + sidebarViewportW
        && mouseY >= sidebarViewportY && mouseY <= sidebarViewportY + sidebarViewportH) {
      sidebarTargetScroll += amount * 42;
    }
  }

  void display() {
    background(bgColor);

    ArrayList<Flight> activeFlights = getActiveFlights();
    ScreenMetrics metrics = computeMetrics(activeFlights);
    ArrayList<SidebarGroup> groups = buildSidebarGroups(metrics);

    drawHeader(metrics);

    float bodyY = HEADER_H + PADDING;
    float bodyH = height - bodyY - PADDING;
    float chartX = PADDING;
    float chartW = width - PADDING * 3 - SIDEBAR_W;
    float sidebarX = chartX + chartW + CARD_GAP;

    drawChartCard(chartX, bodyY, chartW, bodyH, activeFlights, metrics);
    drawSidebar(sidebarX, bodyY, SIDEBAR_W, bodyH, metrics, groups);
  }

  void drawHeader(ScreenMetrics metrics) {
    drawCard(0, 0, width, HEADER_H, 0);

    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(26);
    text(getChartTitle(), PADDING, 14);

    drawHomeButton();
  }

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

  void drawChartCard(float x, float y, float w, float h, ArrayList<Flight> data, ScreenMetrics metrics) {
    drawCard(x, y, w, h, CARD_RADIUS);

    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(19);
    text(getChartPanelTitle(), x + 22, y + 18);

    float tagY = y + 52;
    float tagX = x + 22;
    float firstW = measureTagWidth(getPrimaryTag(metrics));
    float secondW = measureTagWidth(getSecondaryTag(metrics));

    drawChartTag(tagX, tagY, getPrimaryTag(metrics), accentSoft, accent);
    if (tagX + firstW + 8 + secondW <= x + w - 22) {
      drawChartTag(tagX + firstW + 8, tagY, getSecondaryTag(metrics), color(248, 250, 254), textColor);
    }

    float frameX = x + 18;
    float frameY = y + 86;
    float frameW = w - 36;
    float frameH = h - 104;

    noStroke();
    fill(surfaceTint);
    rect(frameX, frameY, frameW, frameH, 16);

    drawGraph(frameX, frameY, frameW, frameH, data);
  }

  float measureTagWidth(String label) {
    textSize(10);
    return textWidth(label) + 22;
  }

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

  void drawSidebar(float x, float y, float w, float h, ScreenMetrics metrics, ArrayList<SidebarGroup> groups) {
    drawCard(x, y, w, h, CARD_RADIUS);

    fill(textColor);
    noStroke();
    textAlign(LEFT, TOP);
    textSize(18);
    text("Relevant metrics", x + 18, y + 18);

    sidebarViewportX = x + 14;
    sidebarViewportY = y + 54;
    sidebarViewportW = w - 28;
    sidebarViewportH = h - 68;

    float contentW = sidebarViewportW - 6;
    sidebarContentH = measureSidebarContentHeight(contentW, groups);
    float maxScroll = max(0, sidebarContentH - sidebarViewportH);

    sidebarTargetScroll = constrain(sidebarTargetScroll, 0, maxScroll);
    sidebarScroll = lerp(sidebarScroll, sidebarTargetScroll, maxScroll > 0 ? 0.22 : 0.32);
    if (abs(sidebarScroll - sidebarTargetScroll) < 0.4) {
      sidebarScroll = sidebarTargetScroll;
    }

    float clipW = sidebarViewportW - (maxScroll > 0 ? 12 : 0);

    clip(int(sidebarViewportX), int(sidebarViewportY), int(clipW), int(sidebarViewportH));
    pushMatrix();
    translate(0, -sidebarScroll);
    drawSidebarContent(sidebarViewportX, sidebarViewportY, clipW, metrics, groups);
    popMatrix();
    noClip();

    if (maxScroll > 0) {
      drawScrollbar(x + w - 12, sidebarViewportY, 6, sidebarViewportH, maxScroll);
    }
  }

  boolean needsScroll(float w, float h, ArrayList<SidebarGroup> groups) {
    float viewportH = h - 68;
    float contentH = measureSidebarContentHeight(w - 34, groups);
    return contentH > viewportH + 1;
  }

  float measureSidebarContentHeight(float w, ArrayList<SidebarGroup> groups) {
    float h = 128 + 18;
    for (int i = 0; i < groups.size(); i++) {
      SidebarGroup g = groups.get(i);
      h += 28 + g.tiles.length * 68 + 10;
    }
    h += 12;
    return h;
  }

  void drawSidebarContent(float x, float y, float w, ScreenMetrics metrics, ArrayList<SidebarGroup> groups) {
    float cy = y;
    cy = drawHeroCard(x, cy, w, metrics);
    cy += 18;
    for (int i = 0; i < groups.size(); i++) {
      cy = drawSidebarGroup(x, cy, w, groups.get(i));
      cy += 10;
    }
  }

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

  void drawScrollbar(float x, float y, float w, float h, float maxScroll) {
    noStroke();
    fill(scrollbarTrack);
    rect(x, y, w, h, 4);

    float thumbH = max(42, h * (h / sidebarContentH));
    float thumbY = y + (sidebarScroll / maxScroll) * (h - thumbH);

    fill(scrollbarThumb);
    rect(x, thumbY, w, thumbH, 4);
  }

  void drawCard(float x, float y, float w, float h, float radius) {
    noStroke();
    fill(20, 28, 45, 12);
    rect(x, y + 6, w, h, radius);

    fill(cardColor);
    stroke(cardStroke);
    strokeWeight(1);
    rect(x, y, w, h, radius);
  }

  void drawGraph(float gx, float gy, float gw, float gh, ArrayList<Flight> data) {
    clip(int(gx + 2), int(gy + 2), int(gw - 4), int(gh - 4));
    pushMatrix();

    float scaleX = gw / width;
    float scaleY = gh / height;
    float s = min(scaleX, scaleY);
    float scaledW = width * s;
    float scaledH = height * s;
    float offsetX = gx + (gw - scaledW) / 2.0;
    float offsetY = gy + (gh - scaledH) / 2.0;

    float localMouseX = (mouseX - offsetX) / s;
    float localMouseY = (mouseY - offsetY) / s;

    translate(offsetX, offsetY);
    scale(s);

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
      pieChart.display(data);
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

  void handleMousePressed() {
    float bw = 118, bh = 36;
    float bx = width - bw - PADDING;
    float by = 18;
    if (mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh) {
      homeFired = true;
    }
  }

  ArrayList<Flight> getActiveFlights() {
    if (flights == null) {
      return new ArrayList<Flight>();
    }
    return flights;
  }

  String getChartTitle() {
    if (currentChart.equals("histogram")) return "Hourly Departure Profile";
    if (currentChart.equals("barchart")) return "Origin Airport Ranking";
    if (currentChart.equals("scatterplot")) return "Departure Punctuality Scatter";
    if (currentChart.equals("piechart")) return "Flight Status Mix";
    return "Flight Data";
  }

  String getChartPanelTitle() {
    if (currentChart.equals("histogram")) return "Flights Per Hour";
    if (currentChart.equals("barchart")) return "Flights by Origin Airport";
    if (currentChart.equals("scatterplot")) return "Scheduled vs Actual Departure Time";
    if (currentChart.equals("piechart")) return "Flight Status Breakdown";
    return "Flight Data";
  }

  String getPrimaryTag(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "No matching data";
    if (currentChart.equals("histogram")) return "Peak hour: " + formatHourLabel(metrics.peakHour);
    if (currentChart.equals("barchart")) return "Top origin: " + safeLabel(metrics.topOrigin, "N/A");
    if (currentChart.equals("scatterplot")) return "Avg delta: " + formatDelay(metrics.averageDelay);
    if (currentChart.equals("piechart")) return "Largest slice: " + getLargestPieLabel(metrics);
    return "Filtered results";
  }

  String getSecondaryTag(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "Adjust your search filters";
    if (currentChart.equals("histogram")) return str(metrics.activeHours) + " active hours";
    if (currentChart.equals("barchart")) return str(metrics.uniqueOrigins) + " origin airports";
    if (currentChart.equals("scatterplot")) return str(metrics.scatterPoints) + " plotted flights";
    if (currentChart.equals("piechart")) return formatPercent(metrics.onTimeSliceRate) + " on-time";
    return str(metrics.totalFlights) + " flights";
  }

  String getHeroValue(ScreenMetrics metrics) {
    if (metrics.totalFlights == 0) return "No data in view";
    if (currentChart.equals("histogram")) return formatHourLabel(metrics.peakHour);
    if (currentChart.equals("barchart")) return safeLabel(metrics.topOrigin, "N/A");
    if (currentChart.equals("scatterplot")) return formatDelay(metrics.averageDelay);
    if (currentChart.equals("piechart")) return getLargestPieLabel(metrics);
    return str(metrics.totalFlights) + " flights";
  }

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

  ArrayList<SidebarGroup> buildSidebarGroups(ScreenMetrics metrics) {
    ArrayList<SidebarGroup> groups = new ArrayList<SidebarGroup>();

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

    if (currentChart.equals("piechart")) {
      groups.add(new SidebarGroup(
        "Status split",
        new MetricTile[] {
          new MetricTile("On-time", pluralize(metrics.onTimeFlights, "flight", "flights") + " • " + formatPercent(metrics.onTimeSliceRate), successCol),
          new MetricTile("Late", pluralize(metrics.delayedFlights, "flight", "flights") + " • " + formatPercent(metrics.lateSliceRate), warningCol),
          new MetricTile("Cancelled", pluralize(metrics.cancelledFlights, "flight", "flights") + " • " + formatPercent(metrics.cancelledRate), dangerCol)
        }
      ));

      groups.add(new SidebarGroup(
        "Outcome balance",
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

  ScreenMetrics computeMetrics(ArrayList<Flight> data) {
    ScreenMetrics metrics = new ScreenMetrics();
    metrics.quietHour = -1;
    metrics.peakHour = -1;
    metrics.maxDelay = Integer.MIN_VALUE;
    metrics.minDelay = Integer.MAX_VALUE;

    java.util.HashMap<String, Integer> carrierCounts = new java.util.HashMap<String, Integer>();
    java.util.HashMap<String, Integer> originCounts = new java.util.HashMap<String, Integer>();
    java.util.HashMap<String, Integer> destinationCounts = new java.util.HashMap<String, Integer>();

    int[] hourCounts = new int[24];
    int totalDelay = 0;
    int delaySamples = 0;
    int totalDistance = 0;
    int distanceSamples = 0;
    int eveningFlights = 0;

    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      metrics.totalFlights++;

      addCount(carrierCounts, cleanValue(f.carrier));
      addCount(originCounts, cleanValue(f.origin));
      addCount(destinationCounts, cleanValue(f.destination));

      if (f.distance > 0) {
        totalDistance += f.distance;
        distanceSamples++;
      }

      int sched = parseTimeToMinutes(f.scheduledDepartureTime);
      if (sched >= 0) {
        metrics.validScheduledFlights++;
        int hour = sched / 60;
        hourCounts[hour]++;
        if (hour >= 17 && hour <= 20) {
          eveningFlights++;
        }
      }

      if (f.cancelled == 1) {
        metrics.cancelledFlights++;
        continue;
      }
      if (f.diverted == 1) {
        metrics.divertedFlights++;
      }

      int delay = getDepartureDelayMinutes(f);
      if (delay == Integer.MIN_VALUE) {
        continue;
      }

      metrics.validTimedFlights++;
      metrics.scatterPoints++;
      totalDelay += delay;
      delaySamples++;

      if (delay > metrics.maxDelay) {
        metrics.maxDelay = delay;
      }
      if (delay < metrics.minDelay) {
        metrics.minDelay = delay;
      }

      if (delay > 0) {
        metrics.delayedFlights++;
      } else {
        metrics.onTimeFlights++;
      }
    }

    metrics.classifiedFlights = metrics.onTimeFlights + metrics.delayedFlights + metrics.cancelledFlights;
    metrics.uniqueOrigins = originCounts.size();
    metrics.uniqueDestinations = destinationCounts.size();
    metrics.averageDistance = distanceSamples > 0 ? round((float) totalDistance / distanceSamples) : 0;
    metrics.averageDelay = delaySamples > 0 ? round((float) totalDelay / delaySamples) : 0;
    metrics.averageFlightsPerOrigin = metrics.uniqueOrigins > 0 ? (float) metrics.totalFlights / metrics.uniqueOrigins : 0;

    metrics.topCarrier = getTopKey(carrierCounts);
    metrics.topCarrierCount = getCount(carrierCounts, metrics.topCarrier);
    metrics.topOrigin = getTopKey(originCounts);
    metrics.topOriginCount = getCount(originCounts, metrics.topOrigin);
    metrics.secondOriginCount = getNthLargestValue(originCounts, 2);
    metrics.topOriginShare = metrics.totalFlights > 0 ? (float) metrics.topOriginCount / metrics.totalFlights : 0;
    metrics.topThreeOriginShare = metrics.totalFlights > 0 ? (float) getTopNTotal(originCounts, 3) / metrics.totalFlights : 0;
    metrics.topFiveOriginShare = metrics.totalFlights > 0 ? (float) getTopNTotal(originCounts, 5) / metrics.totalFlights : 0;

    metrics.onTimeRate = metrics.validTimedFlights > 0 ? (float) metrics.onTimeFlights / metrics.validTimedFlights : 0;
    metrics.delayedRate = metrics.validTimedFlights > 0 ? (float) metrics.delayedFlights / metrics.validTimedFlights : 0;
    metrics.timedCoverageRate = metrics.totalFlights > 0 ? (float) metrics.validTimedFlights / metrics.totalFlights : 0;
    metrics.eveningRate = metrics.validScheduledFlights > 0 ? (float) eveningFlights / metrics.validScheduledFlights : 0;

    metrics.onTimeSliceRate = metrics.classifiedFlights > 0 ? (float) metrics.onTimeFlights / metrics.classifiedFlights : 0;
    metrics.lateSliceRate = metrics.classifiedFlights > 0 ? (float) metrics.delayedFlights / metrics.classifiedFlights : 0;
    metrics.cancelledRate = metrics.classifiedFlights > 0 ? (float) metrics.cancelledFlights / metrics.classifiedFlights : 0;

    metrics.peakHourCount = 0;
    metrics.quietHourCount = Integer.MAX_VALUE;

    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > 0) {
        metrics.activeHours++;
      }
      if (hourCounts[h] > metrics.peakHourCount) {
        metrics.peakHourCount = hourCounts[h];
        metrics.peakHour = h;
      }
      if (hourCounts[h] > 0 && hourCounts[h] < metrics.quietHourCount) {
        metrics.quietHourCount = hourCounts[h];
        metrics.quietHour = h;
      }
    }

    if (metrics.quietHourCount == Integer.MAX_VALUE) {
      metrics.quietHourCount = 0;
    }
    return metrics;
  }

  void addCount(java.util.HashMap<String, Integer> map, String key) {
    if (key == null || key.length() == 0) return;
    Integer current = map.get(key);
    map.put(key, current == null ? 1 : current + 1);
  }

  int getCount(java.util.HashMap<String, Integer> map, String key) {
    if (key == null || !map.containsKey(key)) return 0;
    return map.get(key);
  }

  String getTopKey(java.util.HashMap<String, Integer> map) {
    String bestKey = null;
    int bestCount = -1;
    for (String key : map.keySet()) {
      int value = map.get(key);
      if (value > bestCount) {
        bestCount = value;
        bestKey = key;
      }
    }
    return bestKey;
  }

  int getNthLargestValue(java.util.HashMap<String, Integer> map, int rank) {
    if (map.size() == 0 || rank < 1) return 0;
    int[] values = new int[map.size()];
    int index = 0;
    for (String key : map.keySet()) {
      values[index++] = map.get(key);
    }
    values = sort(values);
    int pos = values.length - rank;
    return pos < 0 ? 0 : values[pos];
  }

  int getTopNTotal(java.util.HashMap<String, Integer> map, int n) {
    int[] values = new int[map.size()];
    int index = 0;
    for (String key : map.keySet()) {
      values[index++] = map.get(key);
    }
    values = sort(values);
    int total = 0;
    for (int i = values.length - 1; i >= 0 && n > 0; i--) {
      total += values[i];
      n--;
    }
    return total;
  }

  String formatHourLabel(int hour) {
    if (hour < 0 || hour > 23) return "N/A";
    return nf(hour, 2) + ":00-" + nf(hour, 2) + ":59";
  }

  String formatDelay(int minutes) {
    if (minutes == Integer.MIN_VALUE || minutes == Integer.MAX_VALUE) return "N/A";
    if (minutes > 0) return "+" + minutes + " min";
    if (minutes < 0) return str(minutes) + " min";
    return "0 min";
  }

  String formatPercent(float value) {
    return nf(value * 100.0, 0, 1) + "%";
  }

  String cleanValue(String value) {
    if (value == null) return null;
    String trimmed = trim(value);
    return trimmed.length() == 0 ? null : trimmed;
  }

  String safeLabel(String value, String fallback) {
    if (value == null || value.length() == 0) return fallback;
    return value;
  }

  String pluralize(int value, String singular, String plural) {
    return value == 1 ? "1 " + singular : str(value) + " " + plural;
  }

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

  float getLargestPieRate(ScreenMetrics metrics) {
    float best = metrics.onTimeSliceRate;
    if (metrics.lateSliceRate > best) best = metrics.lateSliceRate;
    if (metrics.cancelledRate > best) best = metrics.cancelledRate;
    return best;
  }

  class MetricTile {
    String label, value;
    color valueColor;

    MetricTile(String label, String value, color valueColor) {
      this.label = label;
      this.value = value;
      this.valueColor = valueColor;
    }
  }

  class SidebarGroup {
    String title;
    MetricTile[] tiles;

    SidebarGroup(String title, MetricTile[] tiles) {
      this.title = title;
      this.tiles = tiles;
    }
  }

  class ScreenMetrics {
    int totalFlights = 0, onTimeFlights = 0, delayedFlights = 0;
    int cancelledFlights = 0, cancelledExcluded = 0, divertedFlights = 0;
    int validTimedFlights = 0, validScheduledFlights = 0;
    int scatterPoints = 0, classifiedFlights = 0;
    int averageDelay = 0, maxDelay = Integer.MIN_VALUE, minDelay = Integer.MAX_VALUE;
    int averageDistance = 0, uniqueOrigins = 0, uniqueDestinations = 0;
    int topCarrierCount = 0, topOriginCount = 0, secondOriginCount = 0;
    int peakHour = -1, peakHourCount = 0, quietHour = -1, quietHourCount = 0, activeHours = 0;
    String topCarrier, topOrigin;
    float averageFlightsPerOrigin = 0, topOriginShare = 0;
    float topThreeOriginShare = 0, topFiveOriginShare = 0;
    float onTimeRate = 0, delayedRate = 0, timedCoverageRate = 0, eveningRate = 0;
    float onTimeSliceRate = 0, lateSliceRate = 0, cancelledRate = 0;
  }
}
