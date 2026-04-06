class FilterCriteria {
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
