import processing.event.MouseEvent;

ArrayList<Flight> allFlights;
ArrayList<Flight> flights;
ScreenManager     screenManager;

void setup() {
  size(1200, 650);
  textSize(16);

  allFlights = new ArrayList<Flight>();
  Table table = loadTable("data/flights100k.csv", "header");
  for (TableRow row : table.rows()) {
    allFlights.add(new Flight(row));
  }

  flights       = allFlights;
  screenManager = new ScreenManager(allFlights);
}

void mouseWheel(MouseEvent event) {
  screenManager.handleMouseWheel(event.getCount());
}

void draw() {
  background(255);
  screenManager.display();
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
