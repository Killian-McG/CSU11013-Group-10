class ScreenManager {

  SearchScreen searchScreen;
  DataScreen dataScreen;
  FlightFilter flightFilter;
  ArrayList<Flight> allFlights;

  boolean onSearch = true;

  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;
    searchScreen = new SearchScreen();
    dataScreen = new DataScreen();
    flightFilter = new FlightFilter();
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
    flights = flightFilter.filter(allFlights, startMin, endMin, includeCancelled, delayTolerance);
    dataScreen.setChart(chartKey);
    onSearch = false;
  }

  void goToSearch() {
    flights = allFlights;
    onSearch = true;
  }

  void handleMousePressed() {
    if (onSearch) searchScreen.handleMousePressed();
    else dataScreen.handleMousePressed();
  }

  void handleMouseMoved() {
    if (onSearch) searchScreen.handleMouseMoved();
  }

  void handleMouseDragged() {
    if (onSearch) searchScreen.handleMouseDragged();
  }

  void handleMouseReleased() {
    if (onSearch) searchScreen.handleMouseReleased();
  }
}
