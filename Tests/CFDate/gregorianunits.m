#include "CoreFoundation/CFDate.h"
#include "../CFTesting.h"

/* CFAbsoluteTimeGetWeekOfYear (ISO 8601 week) and
   CFAbsoluteTimeGetDifferenceAsGregorianUnits.  Times are built directly as
   offsets from the reference date so the test does not depend on the
   Gregorian-to-absolute-time conversion. */

int main (void)
{
  double day = 86400.0;

  PASS_CF (CFAbsoluteTimeGetWeekOfYear (0.0, NULL) == 1,
    "2001-01-01 is in week 1.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (6 * day, NULL) == 1,
    "2001-01-07 is in week 1.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (7 * day, NULL) == 2,
    "2001-01-08 is in week 2.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (14 * day, NULL) == 3,
    "2001-01-15 is in week 3.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (364 * day, NULL) == 1,
    "2001-12-31 belongs to week 1 of the following year.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (1460 * day, NULL) == 53,
    "2004-12-31 is in week 53.");
  PASS_CF (CFAbsoluteTimeGetWeekOfYear (1461 * day, NULL) == 53,
    "2005-01-01 belongs to week 53 of the previous year.");

  {
    CFOptionFlags ymd = kCFGregorianUnitsYears | kCFGregorianUnitsMonths
      | kCFGregorianUnitsDays;
    CFGregorianUnits u;

    u = CFAbsoluteTimeGetDifferenceAsGregorianUnits (803 * day, 0.0, NULL, ymd);
    PASS_CF (u.years == 2 && u.months == 2 && u.days == 14,
      "2003-03-15 minus 2001-01-01 is 2 years 2 months 14 days.");

    u = CFAbsoluteTimeGetDifferenceAsGregorianUnits (0.0, 803 * day, NULL, ymd);
    PASS_CF (u.years == -2 && u.months == -2 && u.days == -14,
      "The reverse difference is negated.");
  }

  {
    CFOptionFlags all = kCFGregorianUnitsYears | kCFGregorianUnitsMonths
      | kCFGregorianUnitsDays | kCFGregorianUnitsHours
      | kCFGregorianUnitsMinutes | kCFGregorianUnitsSeconds;
    CFAbsoluteTime a1 = 45 * day + 6 * 3600 + 30 * 60 + 20;
    CFAbsoluteTime a2 = 9 * day + 4 * 3600 + 5;
    CFGregorianUnits u;

    u = CFAbsoluteTimeGetDifferenceAsGregorianUnits (a1, a2, NULL, all);
    PASS_CF (u.years == 0 && u.months == 1 && u.days == 5 && u.hours == 2
      && u.minutes == 30 && u.seconds == 15.0,
      "A full component difference is broken down correctly.");
  }

  return 0;
}
