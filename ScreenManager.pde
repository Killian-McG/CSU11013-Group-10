class ScreenManager {

  SearchScreen searchScreen;
  DataScreen   dataScreen;
  FlightFilter flightFilter;
  ArrayList<Flight> allFlights;
  String currentChart = "histogram";

  boolean onSearch = true;

  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;

    searchScreen = new SearchScreen();
    dataScreen   = new DataScreen();
    flightFilter = new FlightFilter();
  }

  void handleMouseWheel(float amount) {
    if (onSearch) {
      searchScreen.handleMouseWheel(amount);
    } else {
      dataScreen.handleMouseWheel(amount);
    }
  }

  void display() {
    if (onSearch) {
      searchScreen.display();
      if (searchScreen.searchFired) {
        searchScreen.searchFired = false;
        goToData(searchScreen.pendingChartKey);
      }
    } else {
      dataScreen.display();
      if (dataScreen.homeFired) {
        dataScreen.homeFired = false;
        goToSearch();
      }
    }
  }

  void goToData(String chartKey) {
    currentChart  = chartKey;
    flights       = searchScreen.buildFilteredFlightsFromCurrentSelections();
    dataScreen.setChart(chartKey);
    onSearch      = false;
  }

  void goToSearch() {
    flights  = allFlights;
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
