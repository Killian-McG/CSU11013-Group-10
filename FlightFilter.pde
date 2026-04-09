// MAIN AUTHOR: Killian - Week 3

// FLIGHT FILTER
//  Applies users search filters to full flight list

class FlightFilter {
  // Main filter pass used by both the live preview and the final chart screen
  ArrayList<Flight> filter(ArrayList<Flight> allFlights, FilterCriteria criteria) {
    ArrayList<Flight> result = new ArrayList<Flight>();
    if (allFlights == null || criteria == null) return result;

    int toleranceMinutes = max(0, criteria.toleranceMinutes);

    for (int i = 0; i < allFlights.size(); i++) {
      Flight f = allFlights.get(i);

      // Separate filter check for each search filter
      if (!matchesScheduledTimeRange(f, criteria.startMinutes, criteria.endMinutes)) continue;
      if (!matchesCarrier(f, criteria.selectedCarrier)) continue;
      if (!matchesState(f.originStateAbr, criteria.selectedOriginState, "Any origin state")) continue;
      if (!matchesState(f.destinationStateAbr, criteria.selectedDestinationState, "Any destination state")) continue;
      if (!matchesDistanceBand(f, criteria.selectedDistanceBand)) continue;
      if (!matchesTimeBucket(f, criteria.selectedTimeBucket)) continue;
      if (!matchesCancelledAndDiverted(f, criteria.includeCancelled, criteria.includeDiverted)) continue;
      if (!matchesDepartureStatus(f, toleranceMinutes, criteria.onlyDelayed, criteria.onlyOnTime)) continue;

      result.add(f);
    }

    return result;
  }

  // Returns true if the flight's scheduled departure time falls within
  // the time window selected on the time slider
  boolean matchesScheduledTimeRange(Flight f, int startMinutes, int endMinutes) {
    int sched = f.getScheduledDepartureMinutes();
    if (sched < 0) return false;
    return sched >= startMinutes && sched <= endMinutes;
  }

  // Returns true if the flight's carrier code matches the selected carrier
  boolean matchesCarrier(Flight f, String selectedCarrier) {
    if (selectedCarrier == null || selectedCarrier.equals("Any carrier")) return true;
    return selectedCarrier.equals(trim(f.carrier));
  }

  // Generic state check used for both origin and destination state filters
  boolean matchesState(String flightState, String selectedState, String anyLabel) {
    if (selectedState == null || selectedState.equals(anyLabel)) return true;
    return selectedState.equals(trim(flightState));
  }

  // Returns true if the flight's distance falls within the chosen distance band
  boolean matchesDistanceBand(Flight f, String selectedBand) {
    if (selectedBand == null || selectedBand.equals("Any distance")) return true;

    if (selectedBand.equals("Under 500 mi")) return f.distance > 0 && f.distance < 500;
    if (selectedBand.equals("500 - 1000 mi")) return f.distance >= 500 && f.distance <= 1000;
    if (selectedBand.equals("1001 - 1500 mi")) return f.distance >= 1001 && f.distance <= 1500;
    if (selectedBand.equals("1501+ mi")) return f.distance >= 1501;
    return true;
  }

  // Returns true if the flight departs in the selected time bucket
  boolean matchesTimeBucket(Flight f, String selectedBucket) {
    if (selectedBucket == null || selectedBucket.equals("Any departure")) return true;

    int sched = f.getScheduledDepartureMinutes();
    if (sched < 0) return false;
    int hour = sched / 60;

    if (selectedBucket.equals("Early Morning (00-05)")) return hour >= 0 && hour <= 5;
    if (selectedBucket.equals("Morning (06-11)")) return hour >= 6 && hour <= 11;
    if (selectedBucket.equals("Afternoon (12-16)")) return hour >= 12 && hour <= 16;
    if (selectedBucket.equals("Evening (17-20)")) return hour >= 17 && hour <= 20;
    if (selectedBucket.equals("Night (21-23)")) return hour >= 21 && hour <= 23;
    return true;
  }
  
  // Returns true if the flights cancelled/diverted status is allowed by the
  // current filter settings.
  boolean matchesCancelledAndDiverted(Flight f, boolean includeCancelled, boolean includeDiverted) {
    if (f.cancelled == 1 && !includeCancelled) return false;
    if (f.diverted == 1 && !includeDiverted) return false;
    return true;
  }

  // Returns true if the flights departure status matches the delayed/on-time filter
  boolean matchesDepartureStatus(Flight f, int toleranceMinutes, boolean onlyDelayed, boolean onlyOnTime) {
    if (!onlyDelayed && !onlyOnTime) return true;
    // Cancelled flights do not have a meaningful departure status, so they drop out here
    if (f.cancelled == 1) return false;

    if (onlyDelayed) return f.isDelayedDeparture(toleranceMinutes);
    if (onlyOnTime) return f.isOnTimeOrEarlyDeparture(toleranceMinutes);
    return true;
  }
}
