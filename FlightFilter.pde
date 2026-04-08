class FlightFilter {
  ArrayList<Flight> filter(ArrayList<Flight> allFlights, FilterCriteria criteria) {
    ArrayList<Flight> result = new ArrayList<Flight>();
    if (allFlights == null || criteria == null) return result;

    int toleranceMinutes = max(0, criteria.toleranceMinutes);

    for (int i = 0; i < allFlights.size(); i++) {
      Flight f = allFlights.get(i);

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

  boolean matchesScheduledTimeRange(Flight f, int startMinutes, int endMinutes) {
    int sched = f.getScheduledDepartureMinutes();
    if (sched < 0) return false;
    return sched >= startMinutes && sched <= endMinutes;
  }

  boolean matchesCarrier(Flight f, String selectedCarrier) {
    if (selectedCarrier == null || selectedCarrier.equals("Any carrier")) return true;
    return selectedCarrier.equals(trim(f.carrier));
  }

  boolean matchesState(String flightState, String selectedState, String anyLabel) {
    if (selectedState == null || selectedState.equals(anyLabel)) return true;
    return selectedState.equals(trim(flightState));
  }

  boolean matchesDistanceBand(Flight f, String selectedBand) {
    if (selectedBand == null || selectedBand.equals("Any distance")) return true;

    if (selectedBand.equals("Under 500 mi")) return f.distance > 0 && f.distance < 500;
    if (selectedBand.equals("500 - 1000 mi")) return f.distance >= 500 && f.distance <= 1000;
    if (selectedBand.equals("1001 - 1500 mi")) return f.distance >= 1001 && f.distance <= 1500;
    if (selectedBand.equals("1501+ mi")) return f.distance >= 1501;
    return true;
  }

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

  boolean matchesCancelledAndDiverted(Flight f, boolean includeCancelled, boolean includeDiverted) {
    if (f.cancelled == 1 && !includeCancelled) return false;
    if (f.diverted == 1 && !includeDiverted) return false;
    return true;
  }

  boolean matchesDepartureStatus(Flight f, int toleranceMinutes, boolean onlyDelayed, boolean onlyOnTime) {
    if (!onlyDelayed && !onlyOnTime) return true;
    if (f.cancelled == 1) return false;

    if (onlyDelayed) return f.isDelayedDeparture(toleranceMinutes);
    if (onlyOnTime) return f.isOnTimeOrEarlyDeparture(toleranceMinutes);
    return true;
  }
}
