// MAIN AUTHOR: Killian - Week 4

// FILTER CRITERIA
//    Data holder for user search criteria
class FilterCriteria {
  // Search variables with placeholder values:
  
  int startMinutes = 0;
  int endMinutes = 1439;

  boolean includeCancelled = false;
  boolean includeDiverted = false;
  boolean onlyDelayed = false;
  boolean onlyOnTime = false;

  int toleranceMinutes = 0;

  String selectedCarrier = "Any carrier";
  String selectedOriginState = "Any origin state";
  String selectedDestinationState = "Any destination state";
  String selectedDistanceBand = "Any distance";
  String selectedTimeBucket = "Any departure";
}
