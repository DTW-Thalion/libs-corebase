#include "CoreFoundation/CFDate.h"
#include "../CFTesting.h"

int main (void)
{
  CFGregorianDate gd;
  CFGregorianDate g2;
  CFGregorianDate bad;
  CFGregorianUnits u;
  CFAbsoluteTime t;

  PASS_CF(CFDateGetTypeID () != 0, "CFDateGetTypeID is not zero.");

  gd.year = 2001;
  gd.month = 1;
  gd.day = 1;
  gd.hour = 0;
  gd.minute = 0;
  gd.second = 0.0;
  t = CFGregorianDateGetAbsoluteTime (gd, NULL);
  PASS_CF(t == 0.0, "2001-01-01 00:00 UTC is absolute time 0.");

  g2 = CFAbsoluteTimeGetGregorianDate (0.0, NULL);
  PASS_CF(g2.year == 2001 && g2.month == 1 && g2.day == 1,
    "Absolute time 0 is 2001-01-01.");

  PASS_CF(CFGregorianDateIsValid (gd,
      kCFGregorianUnitsYears | kCFGregorianUnitsMonths | kCFGregorianUnitsDays),
    "A well-formed Gregorian date is valid.");
  bad = gd;
  bad.month = 13;
  PASS_CF(!CFGregorianDateIsValid (bad, kCFGregorianUnitsMonths),
    "Month 13 is not valid.");

  PASS_CF(CFAbsoluteTimeGetDayOfWeek (0.0, NULL) == 1,
    "2001-01-01 is day of week 1 (Monday).");
  PASS_CF(CFAbsoluteTimeGetDayOfYear (0.0, NULL) == 1,
    "2001-01-01 is day of year 1.");

  u.years = 1;
  u.months = 0;
  u.days = 0;
  u.hours = 0;
  u.minutes = 0;
  u.seconds = 0;
  t = CFAbsoluteTimeAddGregorianUnits (0.0, NULL, u);
  g2 = CFAbsoluteTimeGetGregorianDate (t, NULL);
  PASS_CF(g2.year == 2002 && g2.month == 1 && g2.day == 1,
    "Adding one year to 2001-01-01 gives 2002-01-01.");

  return 0;
}
