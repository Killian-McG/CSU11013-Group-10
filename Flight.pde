// MAIN AUTHORS: Killian and Cameron - Week 1

// FLIGHT
//    Assigns named fields in csv to variables so the rest of the program can use them
class Flight {
  
  // Data fields from csv
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
  
  // Precomputed commonly used values
  int scheduledDepartureMinutes;
  int departureMinutes;

  // Constructor called once per row in CSV file
  // Saves values from csv as variables
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
    arrivalTime = row.getString("ARR_TIME");
    cancelled = row.getInt("CANCELLED");
    diverted = row.getInt("DIVERTED");
    distance = row.getInt("DISTANCE");

    // Conversions, which are used in different classes many times
    scheduledDepartureMinutes = parseTimeToMinutes(scheduledDepartureTime);
    departureMinutes = parseTimeToMinutes(departureTime);
  }

  int getScheduledDepartureMinutes() {
    return scheduledDepartureMinutes;
  }

  int getDepartureMinutes() {
    return departureMinutes;
  }

  // Scheduled Departure time error checking
  boolean hasValidScheduledDeparture() {
    return scheduledDepartureMinutes >= 0;
  }

  // Departure time error checking
  boolean hasValidDepartureTime() {
    return departureMinutes >= 0;
  }

  // Returns delay minutes
  int getDepartureDelayMinutes() {
    if (scheduledDepartureMinutes < 0 || departureMinutes < 0) return Integer.MIN_VALUE;

    // Flights around midnight can look wildly early/late unless we wrap the difference back into a sane range
    int diff = departureMinutes - scheduledDepartureMinutes;
    if (diff < -720) diff += 1440;
    else if (diff > 720) diff -= 1440;
    return diff;
  }

  // Returns true if the flight departed more than toleranceMinutes 
  boolean isDelayedDeparture(int toleranceMinutes) {
    int delay = getDepartureDelayMinutes();
    if (delay == Integer.MIN_VALUE) return false;
    return delay > max(0, toleranceMinutes);
  }

  // Returns true if the flight departed within the tolerance window
  boolean isOnTimeOrEarlyDeparture(int toleranceMinutes) {
    int delay = getDepartureDelayMinutes();
    if (delay == Integer.MIN_VALUE) return false;
    return delay <= max(0, toleranceMinutes);
  }

  String toString() {
    return departureTime;
  }
}

// Converts time values to minutes
int parseTimeToMinutes(String s) {
  if (s == null) return -1;
  s = trim(s);
  if (s.length() == 0) return -1;

  if (s.indexOf(':') != -1) {
    String[] parts = split(s, ':');
    if (parts.length >= 2) {
      try {
        int h = Integer.parseInt(parts[0]);
        int m = Integer.parseInt(parts[1]);
        if (h >= 0 && h < 24 && m >= 0 && m < 60) return h * 60 + m;
      } catch (Exception e) {
      }
    }
    return -1;
  }

  // Strip any non-digit characters that might appear in the data.
  String digits = "";
  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    if (c >= '0' && c <= '9') digits += c;
  }
  if (digits.length() == 0) return -1;

  try {
    int hhmm = Integer.parseInt(digits);
    int h = hhmm / 100;
    int m = hhmm % 100;
    if (h < 0 || h > 23 || m < 0 || m > 59) return -1;
    return h * 60 + m;
  } catch (Exception e) {
    return -1;
  }
}

// Returns departure delay in minutes
int getDepartureDelayMinutes(Flight f) {
  if (f == null) return Integer.MIN_VALUE;
  return f.getDepartureDelayMinutes();
}
