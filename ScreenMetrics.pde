// MAIN AUTHOR: Killian - Week 4

// SCREEN METRICS
//   Defines variables for use on releveant metrics sidebar 

class ScreenMetrics {
  int totalFlights = 0, onTimeFlights = 0, delayedFlights = 0;
  int cancelledFlights = 0, cancelledExcluded = 0, divertedFlights = 0;
  int validTimedFlights = 0, validScheduledFlights = 0;
  int scatterPoints = 0, classifiedFlights = 0;
  int averageDelay = 0, maxDelay = Integer.MIN_VALUE, minDelay = Integer.MAX_VALUE;
  int averageDistance = 0, uniqueOrigins = 0, uniqueDestinations = 0;
  int topCarrierCount = 0, topOriginCount = 0, secondOriginCount = 0;
  int peakHour = -1, peakHourCount = 0, quietHour = -1, quietHourCount = 0, activeHours = 0;
  String topCarrier, topOrigin;
  float averageFlightsPerOrigin = 0, topOriginShare = 0;
  float topThreeOriginShare = 0, topFiveOriginShare = 0;
  float onTimeRate = 0, delayedRate = 0, timedCoverageRate = 0, eveningRate = 0;
  float onTimeSliceRate = 0, lateSliceRate = 0, cancelledRate = 0;
}
