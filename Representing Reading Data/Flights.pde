class Flight {
  String date;
  String carrier;
  int flightNum;
  String origin;
  String originCityName;
  String originStateAbr;
  String destination;
  String destinationCityName;
  String destinationStateAbr;
  String scheduledDepartureTime;
  String departureTime;
  String scheduledArrivalTime;
  String arrivalTime;
  int cancelled;
  int diverted;
  int distance;

  Flight(TableRow row) {
    date = row.getString("FL_DATE");
    carrier = row.getString("MKT_CARRIER");
    flightNum = row.getInt("MKT_CARRIER_FL_NUM");
    origin = row.getString("ORIGIN");
    originCityName = row.getString("ORIGIN_CITY_NAME");
    originStateAbr = row.getString("ORIGIN_STATE_ABR");
    destination = row.getString("DEST");
    destinationCityName = row.getString("DEST_CITY_NAME");
    destinationStateAbr = row.getString("DEST_STATE_ABR");
    scheduledDepartureTime = row.getString("CRS_DEP_TIME");
    departureTime = row.getString("DEP_TIME");
    scheduledArrivalTime = row.getString("CRS_ARR_TIME");
    arrivalTime= row.getString("ARR_TIME");
    cancelled = row.getInt("CANCELLED");
    diverted = row.getInt("DIVERTED");
    distance = row.getInt("DISTANCE");
  }

  String toString() {
    return date + "  " + carrier + flightNum + "  " + origin + " -> " + destination + "  " + distance + " miles";
  }
}
