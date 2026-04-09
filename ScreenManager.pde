// MAIN AUTHOR: Killian - Week 3

// SCREEN MANAGER
//    Acts as the top-level controller that decides which screen
//    is currently shown and routes all user-input events to it

class ScreenManager {

  // The two screens managed by this class
  SearchScreen searchScreen;
  DataScreen dataScreen;
  
  FlightFilter flightFilter;
  ArrayList<Flight> allFlights;
  ArrayList<Flight> activeFlights;
  String currentChart = "histogram";
  int delayToleranceMinutes = 0;

  boolean onSearch = true;

  // Constructor receives the full flight list, creates both screens,
  // and wires them up so they share the same data
  ScreenManager(ArrayList<Flight> allFlights) {
    this.allFlights = allFlights;
    this.activeFlights = allFlights;

    flightFilter = new FlightFilter();
    searchScreen = new SearchScreen(allFlights, flightFilter);
    dataScreen = new DataScreen();
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(delayToleranceMinutes);
  }

  // Routes mouse-wheel events to whichever screen is currently visible
  void handleMouseWheel(float amount) {
    if (onSearch) {
      searchScreen.handleMouseWheel(amount);
    } else {
      dataScreen.handleMouseWheel(amount);
    }
  }

  // Called every frame from the main draw loop
  // Draws the active screen and handles screen-switch signals
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

  // Switches to the data screen for the given chart type
  void goToData(String chartKey) {
    currentChart = chartKey;
    activeFlights = searchScreen.buildFilteredFlightsFromCurrentSelections();
    delayToleranceMinutes = searchScreen.getSelectedDelayTolerance();

    dataScreen.setChart(chartKey);
    dataScreen.setActiveFlights(activeFlights);
    dataScreen.setDelayToleranceMinutes(delayToleranceMinutes);
    onSearch = false;
  }

  // Switches to search screen
  void goToSearch() {
    onSearch = true;
  }

  // Mouse pressed event handler
  void handleMousePressed() {
    if (onSearch) {
      searchScreen.handleMousePressed();
    } else {
      dataScreen.handleMousePressed();
    }
  }

  // Mouse moved event handler
  void handleMouseMoved() {
    if (onSearch) {
      searchScreen.handleMouseMoved();
    }
  }

  // Mouse dragged event handler
  void handleMouseDragged() {
    if (onSearch) {
      searchScreen.handleMouseDragged();
    }
  }

  // Mouse released event handler
  void handleMouseReleased() {
    if (onSearch) {
      searchScreen.handleMouseReleased();
    }
  }
}
