// MAIN AUTHORS: Calvin and Matthew - Week 1


// MAIN
//   Entry point for processing sketch
//   Loads CSV once, builds flight objects
//   Gives control to ScreenManager

import processing.event.MouseEvent;

ArrayList<Flight> allFlights;
ScreenManager screenManager;

// Load the dataset once at startup and prepare the first screen
void setup() {
  size(1200, 650);
  textSize(16);

  allFlights = new ArrayList<Flight>();
  Table table = loadTable("data/flights.csv", "header");

  // Turns each CSV row into a Flight object
  for (TableRow row : table.rows()) {
    allFlights.add(new Flight(row));
  }

  screenManager = new ScreenManager(allFlights);
}

// ScreenManager decides which screen should be active
void draw() {
  background(255);
  screenManager.display();
}

// Input Handlers:

void mouseWheel(MouseEvent event) {
  screenManager.handleMouseWheel(event.getCount());
}

void mousePressed() {
  screenManager.handleMousePressed();
}

void mouseMoved() {
  screenManager.handleMouseMoved();
}

void mouseDragged() {
  screenManager.handleMouseDragged();
}

void mouseReleased() {
  screenManager.handleMouseReleased();
}
