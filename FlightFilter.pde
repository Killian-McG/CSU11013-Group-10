class FlightFilter {

  ArrayList<Flight> filter(ArrayList<Flight> all, int startMinutes, int endMinutes,
                           boolean includeCancelled, int delayToleranceMins) {
    ArrayList<Flight> result = new ArrayList<Flight>();
    for (Flight f : all) {
      if (f.cancelled == 1) {
        if (!includeCancelled) continue;
        result.add(f);
        continue;
      }

      if (f.scheduledDepartureTime == null || f.scheduledDepartureTime.trim().equals("")) continue;

      try {
        int hhmm = int(f.scheduledDepartureTime.trim());
        int h = hhmm / 100;
        int m = hhmm % 100;
        int totalMin = h * 60 + m;
        if (totalMin < startMinutes || totalMin > endMinutes) continue;
      } catch (Exception e) {
        continue;
      }

      if (delayToleranceMins > 0 &&
          f.scheduledDepartureTime != null && f.departureTime != null &&
          !f.scheduledDepartureTime.trim().equals("") &&
          !f.departureTime.trim().equals("")) {
        try {
          int schedHHMM = int(f.scheduledDepartureTime.trim());
          int actHHMM = int(f.departureTime.trim());
          int schedMin = (schedHHMM / 100) * 60 + (schedHHMM % 100);
          int actMin = (actHHMM / 100) * 60 + (actHHMM % 100);
          int delay = actMin - schedMin;
          if (delay > delayToleranceMins) continue;
        } catch (Exception e) {
        }
      }

      result.add(f);
    }
    return result;
  }
}
