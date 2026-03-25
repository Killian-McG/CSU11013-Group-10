ArrayList<Flight> allFlights;
ArrayList<Flight> flights;
ScreenManager     screenManager;

void setup() {
  size(1200, 600);
  textSize(16);

  allFlights = new ArrayList<Flight>();
  Table table = loadTable("data/flights2k.csv", "header");
  for (TableRow row : table.rows()) {
    allFlights.add(new Flight(row));
  }

  flights       = allFlights;
  screenManager = new ScreenManager(allFlights);
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
