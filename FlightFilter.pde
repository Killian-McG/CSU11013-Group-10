class FlightFilter {
  ArrayList<Flight> filter(ArrayList<Flight> all, FilterCriteria criteria) {
    ArrayList<Flight> result = new ArrayList<Flight>();

    if (all == null) return result;
    if (criteria == null) return result;

    for (int i = 0; i < all.size(); i++) {
      Flight f = all.get(i);

      if (!matchesScheduledTimeRange(f, criteria.startMinutes, criteria.endMinutes)) continue;
      if (!criteria.includeCancelled && f.cancelled == 1) continue;
      if (!criteria.includeDiverted && f.diverted == 1) continue;
      if (!matchesCarrier(f, criteria.selectedCarrier)) continue;
      if (!matchesState(f.originStateAbr, criteria.selectedOriginState, "Any origin state")) continue;
      if (!matchesState(f.destinationStateAbr, criteria.selectedDestinationState, "Any destination state")) continue;
      if (!matchesDistanceBand(f, criteria.selectedDistanceBand)) continue;
      if (!matchesTimeBucket(f, criteria.selectedTimeBucket)) continue;
      if (!matchesDepartureStatus(f, criteria.onlyDelayed, criteria.onlyOnTime, criteria.toleranceMinutes)) continue;

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
    if (selectedCarrier.equals("Any carrier")) return true;
    return valueMatches(f.carrier, selectedCarrier);
  }

  boolean matchesState(String stateValue, String selectedState, String anyLabel) {
    if (selectedState.equals(anyLabel)) return true;
    return valueMatches(stateValue, selectedState);
  }

  boolean matchesDistanceBand(Flight f, String band) {
    if (band.equals("Any distance")) return true;
    if (band.equals("Under 500 mi")) return f.distance < 500;
    if (band.equals("500 - 1000 mi")) return f.distance >= 500 && f.distance <= 1000;
    if (band.equals("1001 - 1500 mi")) return f.distance >= 1001 && f.distance <= 1500;
    if (band.equals("1501+ mi")) return f.distance >= 1501;
    return true;
  }

  boolean matchesTimeBucket(Flight f, String bucket) {
    if (bucket.equals("Any departure")) return true;
    int mins = f.getScheduledDepartureMinutes();
    if (mins < 0) return false;
    if (bucket.equals("Red-eye (00-05)")) return mins < 360;
    if (bucket.equals("Morning (06-11)")) return mins >= 360 && mins < 720;
    if (bucket.equals("Afternoon (12-16)")) return mins >= 720 && mins < 1020;
    if (bucket.equals("Evening (17-20)")) return mins >= 1020 && mins < 1260;
    if (bucket.equals("Night (21-23)")) return mins >= 1260;
    return true;
  }

  boolean matchesDepartureStatus(Flight f, boolean onlyDelayed, boolean onlyOnTime, int toleranceMinutes) {
    if (!onlyDelayed && !onlyOnTime) return true;
    if (f.cancelled == 1) return false;
    if (onlyDelayed) return f.isDelayedDeparture(toleranceMinutes);
    if (onlyOnTime) return f.isOnTimeOrEarlyDeparture(toleranceMinutes);
    return true;
  }

  boolean valueMatches(String a, String b) {
    if (a == null || b == null) return false;
    return trim(a).equals(trim(b));
  }
}
