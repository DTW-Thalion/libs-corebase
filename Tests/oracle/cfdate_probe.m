#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static CFAbsoluteTime
mk (int y, int mo, int d, int h, int mi, int s)
{
  CFGregorianDate g;
  g.year = y; g.month = mo; g.day = d;
  g.hour = h; g.minute = mi; g.second = s;
  return CFGregorianDateGetAbsoluteTime (g, NULL);
}

static void
wk (int y, int mo, int d)
{
  CFAbsoluteTime at = mk (y, mo, d, 0, 0, 0);
  printf ("WeekOfYear %04d-%02d-%02d = %d  (dayOfYear=%d dayOfWeek=%d)\n",
    y, mo, d, (int) CFAbsoluteTimeGetWeekOfYear (at, NULL),
    (int) CFAbsoluteTimeGetDayOfYear (at, NULL),
    (int) CFAbsoluteTimeGetDayOfWeek (at, NULL));
}

static void
diff (const char *label, CFAbsoluteTime a1, CFAbsoluteTime a2)
{
  CFOptionFlags f = kCFGregorianUnitsYears | kCFGregorianUnitsMonths
    | kCFGregorianUnitsDays | kCFGregorianUnitsHours
    | kCFGregorianUnitsMinutes | kCFGregorianUnitsSeconds;
  CFGregorianUnits u = CFAbsoluteTimeGetDifferenceAsGregorianUnits (a1, a2,
    NULL, f);
  printf ("%s: y=%d mo=%d d=%d h=%d m=%d s=%g\n", label,
    u.years, u.months, u.days, u.hours, u.minutes, u.seconds);
}

int main (void)
{
  wk (2001, 1, 1); wk (2001, 1, 6); wk (2001, 1, 7); wk (2001, 1, 8);
  wk (2001, 1, 14); wk (2001, 1, 15); wk (2001, 12, 30); wk (2001, 12, 31);
  wk (2002, 1, 1); wk (2004, 1, 1); wk (2004, 12, 31); wk (2005, 1, 1);

  diff ("2003-03-15 minus 2001-01-01",
    mk (2003, 3, 15, 0, 0, 0), mk (2001, 1, 1, 0, 0, 0));
  diff ("2001-01-01 minus 2003-03-15",
    mk (2001, 1, 1, 0, 0, 0), mk (2003, 3, 15, 0, 0, 0));
  diff ("2001-02-15-06:30:20 minus 2001-01-10-04:00:05",
    mk (2001, 2, 15, 6, 30, 20), mk (2001, 1, 10, 4, 0, 5));
  return 0;
}
