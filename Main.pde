ArrayList<Flight> flights;

DataScreen  dataScreen;

Histogram   histogram;
BarChart    barChart;
ScatterPlot scatterPlot;
PieChart    pieChart;

Button      testButton;
CheckBox    testCheckBox;
Dropdown    testDropdown;
TimeSlider  testTimeSlider;


void setup() {
  size(1200, 600);
  textSize(16);
  
  flights = new ArrayList<Flight>();
 
  Table table = loadTable("data/flights2k.csv", "header");
  for (TableRow row : table.rows()) {
    Flight f = new Flight(row);
    flights.add(f);
    
  }
  
  dataScreen  = new DataScreen();
  
  histogram   = new Histogram();
  barChart    = new BarChart();
  scatterPlot = new ScatterPlot();
  pieChart    = new PieChart(width / 2, height / 2, 300);
  
  testButton     = new Button(50, 50, 160, 44, "Click Me");
  testCheckBox   = new CheckBox(50, 130, 24, "Enable Feature");
  testDropdown   = new Dropdown(50, 220, 200, 36, "Choose Option",
                     new String[]{"Option A", "Option B", "Option C", "Option D"});
  testTimeSlider = new TimeSlider(50, 400, 500, "Departure Time");
}


void draw() {
  background(255);
  
  dataScreen.setChart("histogram");
  dataScreen.display();

  //histogram.display();

  //barChart.drawbarchart();

  //scatterPlot.drawScatterPlot();

  //pieChart.display(flights);

  //testButton.display();
  //fill(0); textSize(14); textAlign(LEFT, TOP);
  //text("Hovered: " + testButton.hovered, 50, 110);

  //testCheckBox.display();
  //fill(0); textSize(14); textAlign(LEFT, TOP);
  //text("Checked: " + testCheckBox.isChecked(), 50, 170);

  //testDropdown.display();
  //fill(0); textSize(14); textAlign(LEFT, TOP);
  //text("Selected: " + testDropdown.getSelected(), 50, 280);

  //testTimeSlider.display();
  //fill(0); textSize(14); textAlign(LEFT, TOP);
  //text("Time: " + testTimeSlider.getTime()
  //  + "  Hour: " + testTimeSlider.getHour()
  //  + "  Min: "  + testTimeSlider.getMinute()
  //  + "  Total mins: " + testTimeSlider.getTotalMinutes(),
  //  50, 440);
}



void mousePressed() {
  
  //if (testButton.isClicked()) { println("Button clicked!"); }

  //if (testCheckBox.isMouseOver()) testCheckBox.setChecked(!testCheckBox.isChecked());

  //testDropdown.handleMousePressed();

  //testTimeSlider.handleMousePressed();
}

void mouseMoved() {
  //testDropdown.handleMouseMoved();
}

void mouseDragged() {
  //testDropdown.handleMouseDragged();

  //testTimeSlider.handleMouseDragged();
}

void mouseReleased() {
  //testTimeSlider.handleMouseReleased();
}

void keyPressed() {
  // barChart.keyPressed();
}

  
