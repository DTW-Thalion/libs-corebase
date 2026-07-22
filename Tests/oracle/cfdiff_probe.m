#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
d (const char *label, CFAbsoluteTime a1, CFAbsoluteTime a2)
{
  CFOptionFlags all = kCFGregorianUnitsYears | kCFGregorianUnitsMonths
    | kCFGregorianUnitsDays | kCFGregorianUnitsHours
    | kCFGregorianUnitsMinutes | kCFGregorianUnitsSeconds;
  CFGregorianUnits u = CFAbsoluteTimeGetDifferenceAsGregorianUnits (a1, a2,
    NULL, all);
  printf ("%s: y=%d mo=%d d=%d h=%d m=%d s=%g\n", label,
    u.years, u.months, u.days, u.hours, u.minutes, u.seconds);
}

int main (void)
{
  double day = 86400.0;
  /* A: day borrow across February (28 days) */
  d ("A 2001-03-05 - 2001-02-20", 63 * day, 50 * day);
  /* B: day borrow across March, bigger gap */
  d ("B 2001-04-10 - 2001-02-25", 99 * day, 55 * day);
  /* C: minute/second borrow across midnight */
  d ("C min/sec borrow", 151 * day + 15 * 60 + 10,
    150 * day + 23 * 3600 + 45 * 60 + 20);
  /* D: year + month + day borrow (Nov 2001 -> Jan 2002) */
  d ("D 2002-01-05 - 2001-11-20", 369 * day, 323 * day);
  /* E: day borrow across a 31-day month (Dec -> Jan) */
  d ("E 2002-01-05 - 2001-12-20", 369 * day, 353 * day);
  return 0;
}
