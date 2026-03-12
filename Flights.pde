class Flight {
  String date;
  String carrier;
  int flightNum;
  String origin;
  String destination;
  int distance;

  Flight(TableRow row) {
    date = row.getString("FL_DATE");
    carrier = row.getString("MKT_CARRIER");
    flightNum = row.getInt("MKT_CARRIER_FL_NUM");
    origin = row.getString("ORIGIN");
    destination = row.getString("DEST");
    distance = row.getInt("DISTANCE");
  }

  String toString() {
    return date + "  " + carrier + flightNum + "  " + origin + " -> " + destination + "  " + distance + " miles";
  }
}
