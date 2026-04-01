class FlightFilter {

  ArrayList<Flight> filter(ArrayList<Flight> all, int startMinutes, int endMinutes,
                           boolean includeCancelled, int delayToleranceMins) {
    ArrayList<Flight> result = new ArrayList<Flight>();

    for (int i = 0; i < all.size(); i++) {
      Flight f = all.get(i);

      if (f.cancelled == 1) {
        if (includeCancelled) result.add(f);
        continue;
      }

      int sched = f.scheduledDepartureMinutes;
      if (sched < 0) continue;
      if (sched < startMinutes || sched > endMinutes) continue;

      if (delayToleranceMins > 0) {
        int actual = f.departureMinutes;
        if (actual >= 0) {
          int delay = actual - sched;
          if (delay > delayToleranceMins) continue;
        }
      }

      result.add(f);
    }

    return result;
  }
}
