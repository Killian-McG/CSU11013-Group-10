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

  int scheduledDepartureMinutes;
  int departureMinutes;

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

    scheduledDepartureMinutes = parseTimeToMinutes(scheduledDepartureTime);
    departureMinutes = parseTimeToMinutes(departureTime);
  }

  String toString() {
    return departureTime;
  }
}

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

int getDepartureDelayMinutes(Flight f) {
  int scheduled = parseTimeToMinutes(f.scheduledDepartureTime);
  int actual = parseTimeToMinutes(f.departureTime);
  if (scheduled < 0 || actual < 0) return Integer.MIN_VALUE;

  int diff = actual - scheduled;
  if (diff < -720) diff += 1440;
  else if (diff > 720) diff -= 1440;
  return diff;
}
