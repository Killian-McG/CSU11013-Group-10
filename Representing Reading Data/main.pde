ArrayList<Flight> flights;

void setup() {
  size(1200, 600);
  textSize(16);

  flights = new ArrayList<Flight>();

  Table table = loadTable("TestData.csv", "header");

  for (TableRow row : table.rows()) {
    Flight f = new Flight(row);
    flights.add(f);
    println(f);
  }
}

void draw() {
  background(255);
  fill(0);
  int dataText = 30;
  for (int i = 0; i < flights.size(); i++) {
    text(flights.get(i).toString(), 20, dataText);
    dataText = dataText + 25;
  }
}
