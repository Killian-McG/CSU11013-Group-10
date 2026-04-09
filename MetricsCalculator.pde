// MAIN AUTHOR: Killian - Week 4

// MetricsCalculator
//    Computes the summary numbers in the sidebar beside each chart
class MetricsCalculator {
  
  // Accepts the filtered flight list and the user-chosen delay tolerance
  // Returns a fully populated ScreenMetrics object.
  ScreenMetrics computeMetrics(ArrayList<Flight> data, int delayToleranceMinutes) {
    ScreenMetrics metrics = new ScreenMetrics();
    metrics.quietHour = -1;
    metrics.peakHour = -1;
    metrics.maxDelay = Integer.MIN_VALUE;
    metrics.minDelay = Integer.MAX_VALUE;

    java.util.HashMap<String, Integer> carrierCounts = new java.util.HashMap<String, Integer>();
    java.util.HashMap<String, Integer> originCounts = new java.util.HashMap<String, Integer>();
    java.util.HashMap<String, Integer> destinationCounts = new java.util.HashMap<String, Integer>();

    // Hourly bucket array
    int[] hourCounts = new int[24];
    
    // Accumulators for computing averages later
    int totalDelay = 0;
    int delaySamples = 0;
    int totalDistance = 0;
    int distanceSamples = 0;
    int eveningFlights = 0;

    for (int i = 0; i < data.size(); i++) {
      Flight f = data.get(i);
      metrics.totalFlights++;

      // Count the broad totals first so every chart is working from the same base numbers
      addCount(carrierCounts, cleanValue(f.carrier));
      addCount(originCounts, cleanValue(f.origin));
      addCount(destinationCounts, cleanValue(f.destination));

      if (f.distance > 0) {
        totalDistance += f.distance;
        distanceSamples++;
      }

      int sched = f.getScheduledDepartureMinutes();
      if (sched >= 0) {
        // Hour metrics come from scheduled departure, not actual departure
        metrics.validScheduledFlights++;
        int hour = sched / 60;
        hourCounts[hour]++;
        if (hour >= 17 && hour <= 20) {
          eveningFlights++;
        }
      }

      if (f.cancelled == 1) {
        metrics.cancelledFlights++;
        continue;
      }
      if (f.diverted == 1) {
        metrics.divertedFlights++;
      }

      int delay = f.getDepartureDelayMinutes();
      if (delay == Integer.MIN_VALUE) {
        continue;
      }

      metrics.validTimedFlights++;
      metrics.scatterPoints++;
      totalDelay += delay;
      delaySamples++;

      if (delay > metrics.maxDelay) {
        metrics.maxDelay = delay;
      }
      if (delay < metrics.minDelay) {
        metrics.minDelay = delay;
      }

      if (f.isDelayedDeparture(delayToleranceMinutes)) {
        metrics.delayedFlights++;
      } else if (f.isOnTimeOrEarlyDeparture(delayToleranceMinutes)) {
        metrics.onTimeFlights++;
      }
    }

    // Creates summary fields from the accumulators
    metrics.classifiedFlights = metrics.onTimeFlights + metrics.delayedFlights + metrics.cancelledFlights;
    metrics.uniqueOrigins = originCounts.size();
    metrics.uniqueDestinations = destinationCounts.size();
    metrics.averageDistance = distanceSamples > 0 ? round((float) totalDistance / distanceSamples) : 0;
    metrics.averageDelay = delaySamples > 0 ? round((float) totalDelay / delaySamples) : 0;
    metrics.averageFlightsPerOrigin = metrics.uniqueOrigins > 0 ? (float) metrics.totalFlights / metrics.uniqueOrigins : 0;

    metrics.topCarrier = getTopKey(carrierCounts);
    metrics.topCarrierCount = getCount(carrierCounts, metrics.topCarrier);
    metrics.topOrigin = getTopKey(originCounts);
    metrics.topOriginCount = getCount(originCounts, metrics.topOrigin);
    metrics.secondOriginCount = getNthLargestValue(originCounts, 2);
    metrics.topOriginShare = metrics.totalFlights > 0 ? (float) metrics.topOriginCount / metrics.totalFlights : 0;
    metrics.topThreeOriginShare = metrics.totalFlights > 0 ? (float) getTopNTotal(originCounts, 3) / metrics.totalFlights : 0;
    metrics.topFiveOriginShare = metrics.totalFlights > 0 ? (float) getTopNTotal(originCounts, 5) / metrics.totalFlights : 0;

    metrics.onTimeRate = metrics.validTimedFlights > 0 ? (float) metrics.onTimeFlights / metrics.validTimedFlights : 0;
    metrics.delayedRate = metrics.validTimedFlights > 0 ? (float) metrics.delayedFlights / metrics.validTimedFlights : 0;
    metrics.timedCoverageRate = metrics.totalFlights > 0 ? (float) metrics.validTimedFlights / metrics.totalFlights : 0;
    metrics.eveningRate = metrics.validScheduledFlights > 0 ? (float) eveningFlights / metrics.validScheduledFlights : 0;

    metrics.onTimeSliceRate = metrics.classifiedFlights > 0 ? (float) metrics.onTimeFlights / metrics.classifiedFlights : 0;
    metrics.lateSliceRate = metrics.classifiedFlights > 0 ? (float) metrics.delayedFlights / metrics.classifiedFlights : 0;
    metrics.cancelledRate = metrics.classifiedFlights > 0 ? (float) metrics.cancelledFlights / metrics.classifiedFlights : 0;

    metrics.peakHourCount = 0;
    metrics.quietHourCount = Integer.MAX_VALUE;

    // Scan the hourly buckets once to find the busiest and quietest active hours
    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > 0) {
        metrics.activeHours++;
      }
      if (hourCounts[h] > metrics.peakHourCount) {
        metrics.peakHourCount = hourCounts[h];
        metrics.peakHour = h;
      }
      if (hourCounts[h] > 0 && hourCounts[h] < metrics.quietHourCount) {
        metrics.quietHourCount = hourCounts[h];
        metrics.quietHour = h;
      }
    }

    if (metrics.quietHourCount == Integer.MAX_VALUE) {
      metrics.quietHourCount = 0;
    }
    return metrics;
  }

  // Increments the count for <key> in the map by 1
  void addCount(java.util.HashMap<String, Integer> map, String key) {
    if (key == null || key.length() == 0) return;
    Integer current = map.get(key);
    map.put(key, current == null ? 1 : current + 1);
  }

  // Returns the count stored for <key>
  int getCount(java.util.HashMap<String, Integer> map, String key) {
    if (key == null || !map.containsKey(key)) return 0;
    return map.get(key);
  }

  // Finds and returns the key with the highest count in the map
  String getTopKey(java.util.HashMap<String, Integer> map) {
    String bestKey = null;
    int bestCount = -1;
    for (String key : map.keySet()) {
      int value = map.get(key);
      if (value > bestCount) {
        bestCount = value;
        bestKey = key;
      }
    }
    return bestKey;
  }

  // Returns the Nth largest value in the map
  int getNthLargestValue(java.util.HashMap<String, Integer> map, int rank) {
    if (map.size() == 0 || rank < 1) return 0;
    int[] values = new int[map.size()];
    int index = 0;
    for (String key : map.keySet()) {
      values[index++] = map.get(key);
    }
    values = sort(values);
    int pos = values.length - rank;
    return pos < 0 ? 0 : values[pos];
  }

  // Returns the combined flight count of the top N entries in the map
  int getTopNTotal(java.util.HashMap<String, Integer> map, int n) {
    int[] values = new int[map.size()];
    int index = 0;
    for (String key : map.keySet()) {
      values[index++] = map.get(key);
    }
    values = sort(values);
    int total = 0;
    for (int i = values.length - 1; i >= 0 && n > 0; i--) {
      total += values[i];
      n--;
    }
    return total;
  }

  // Error checking/Data cleaning
  String cleanValue(String value) {
    if (value == null) return null;
    String trimmed = trim(value);
    return trimmed.length() == 0 ? null : trimmed;
  }
}
