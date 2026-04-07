class ScreenManager {

  SearchScreen searchScreen;
  DataScreen   dataScreen;
  FlightFilter flightFilter;
  ArrayList<Flight> allFlights;
  ArrayList<Flight> activeFlights;
  int activeDelayToleranceMinutes = 0;
  String currentChart = "histogram";

  boolean onSearch = true;

  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;
    activeFlights = allFlights;

    flightFilter = new FlightFilter();
    searchScreen = new SearchScreen(allFlights, flightFilter);
    dataScreen   = new DataScreen();
    dataScreen.setActiveFlights(activeFlights);
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
    activeDelayToleranceMinutes = searchScreen.getSelectedDelayTolerance();
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(activeDelayToleranceMinutes);
    dataScreen.setChart(chartKey);
    onSearch = false;
  }

  void goToSearch() {
    activeFlights = allFlights;
    activeDelayToleranceMinutes = 0;
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(activeDelayToleranceMinutes);
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
