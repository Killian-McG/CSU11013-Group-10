class ScreenManager {

  SearchScreen searchScreen;
  DataScreen dataScreen;
  FlightFilter flightFilter;
  ArrayList<Flight> allFlights;
  ArrayList<Flight> activeFlights;
  String currentChart = "histogram";
  int delayToleranceMinutes = 0;

  boolean onSearch = true;

  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;
    this.activeFlights = allFlights;

    flightFilter = new FlightFilter();
    searchScreen = new SearchScreen(allFlights, flightFilter);
    dataScreen = new DataScreen();
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(delayToleranceMinutes);
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
    currentChart = chartKey;
    activeFlights = searchScreen.buildFilteredFlightsFromCurrentSelections();
    delayToleranceMinutes = searchScreen.getSelectedDelayTolerance();

    dataScreen.setChart(chartKey);
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(delayToleranceMinutes);
    onSearch = false;
  }

  void goToSearch() {
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
