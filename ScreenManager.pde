class ScreenManager {

  SearchScreen searchScreen;
  DataScreen dataScreen;
  Histogram histogram;
  BarChart barChart;
  ScatterPlot scatterPlot;
  PieChart pieChart;
  FlightFilter flightFilter;
  ArrayList<Flight> flights;
  ArrayList<Flight> allFlights;
  ArrayList<Flight> graphFlights;
  String currentChart = "histogram";

  boolean onSearch = true;

  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;
    graphFlights = allFlights;

    searchScreen = new SearchScreen();
    dataScreen = new DataScreen();
    flightFilter = new FlightFilter();
    histogram = new Histogram();
    barChart = new BarChart();
    scatterPlot = new ScatterPlot();
    pieChart = new PieChart(width/2, height/2, 260);
  }
  
  void setFlights(ArrayList<Flight> flights) {
  this.flights = flights;
}

  void handleMouseWheel(float amount) {
  if (onSearch) {
    searchScreen.handleMouseWheel(amount);
  } else {
    dataScreen.handleMouseWheel(amount);
  }
}

  void openGraphFromSearch() {
    currentChart = searchScreen.chartKeys[searchScreen.activeTab];
    graphFlights = searchScreen.buildFilteredFlightsFromCurrentSelections();
    flights = graphFlights;
    dataScreen.setChart(currentChart);
    onSearch = false;
  }

  void drawGraphScreen() {
    if (currentChart.equals("histogram")) {
      histogram.display(graphFlights);
    } else if (currentChart.equals("barchart")) {
      barChart.drawBarChart(graphFlights);
    } else if (currentChart.equals("scatterplot")) {
      scatterPlot.drawScatterPlot(graphFlights);
    } else if (currentChart.equals("piechart")) {
      pieChart.display(graphFlights);
    }
  }

  void display() {
    if (onSearch) {
      searchScreen.display();
      if (searchScreen.searchFired) {
        searchScreen.searchFired = false;
        goToData(searchScreen.pendingChartKey,
                 searchScreen.pendingStartMin,
                 searchScreen.pendingEndMin,
                 searchScreen.pendingIncludeCancelled,
                 searchScreen.pendingDelayTolerance);
      }
    } else {
      dataScreen.display();
      if (dataScreen.homeFired) {
        dataScreen.homeFired = false;
        goToSearch();
      }
    }
  }

  void goToData(String chartKey, int startMin, int endMin,
                boolean includeCancelled, int delayTolerance) {
    currentChart = chartKey;
    graphFlights = searchScreen.buildFilteredFlightsFromCurrentSelections();
    flights = graphFlights;
    dataScreen.setChart(chartKey);
    onSearch = false;
  }

  void goToSearch() {
    graphFlights = allFlights;
    flights = allFlights;
    onSearch = true;
  }

  void handleMousePressed() {
    if (onSearch) {
      searchScreen.handleMousePressed();
    } else {
      dataScreen.handleMousePressed();
    }
  }

  void handleMouseMoved() {
    if (onSearch) {
      searchScreen.handleMouseMoved();
    }
  }

  void handleMouseDragged() {
    if (onSearch) {
      searchScreen.handleMouseDragged();
    }
  }

  void handleMouseReleased() {
    if (onSearch) {
      searchScreen.handleMouseReleased();
    }
  }
}
