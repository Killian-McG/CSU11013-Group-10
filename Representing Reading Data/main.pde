Histogram histogram;


ArrayList<Flight> flights;

void setup() {
  size(1200, 600);
  textSize(16);
  
  histogram = new Histogram();
  flights = new ArrayList<Flight>();
 
  Table table = loadTable("TestData.csv", "header");
  for (TableRow row : table.rows()) {
    Flight f = new Flight(row);
    flights.add(f);
    
  }
}


void draw() {
  background(255);
  fill(0);
  histogram.display();
}
  
