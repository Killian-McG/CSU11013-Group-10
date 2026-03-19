Histogram histogram;


ArrayList<Flight> flights;

void setup() {
  size(1200, 600);
  textSize(16);
  
  histogram = new Histogram();
  
  flights = new ArrayList<Flight>();
  
  
  ArrayList<String> times = new ArrayList<String>();
  times.add("00:15");
  times.add("01:20");
  times.add("01:45");
  times.add("03:10");
  times.add("05:50");
  times.add("05:55");
  times.add("08:30");
  times.add("08:40");
  times.add("08:50");
  times.add("12:10");
  times.add("12:25");
  times.add("15:00");
  times.add("18:45");
  times.add("18:55");
  times.add("21:10");
  times.add("23:59");
  histogram.setData(times);

  Table table = loadTable("TestData.csv", "header");
  for (TableRow row : table.rows()) {
    Flight f = new Flight(row);
    flights.add(f);
    println(f);
  }
}


  //My section start

void draw() {
  background(255);
  fill(0);
  int dataText = 30;
  for (int i = 0; i < flights.size(); i++) {
    text(flights.get(i).toString(), 20, dataText);
    dataText = dataText + 25;
  }
}
  
  //MY SECTION END
