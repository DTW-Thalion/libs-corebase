#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static CFCalendarRef cal;

static void
diff (const char *label, CFAbsoluteTime start, CFAbsoluteTime result)
{
  int y = 0, mo = 0, d = 0, h = 0, mi = 0, s = 0;
  CFCalendarGetComponentDifference (cal, start, result, 0, "yMdHms",
    &y, &mo, &d, &h, &mi, &s);
  printf ("%s: y=%d mo=%d d=%d h=%d m=%d s=%d\n", label, y, mo, d, h, mi, s);
}

int main (void)
{
  double day = 86400.0;
  CFTimeZoneRef gmt = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, 0.0);

  cal = CFCalendarCreateWithIdentifier (NULL, kCFGregorianCalendar);
  CFCalendarSetTimeZone (cal, gmt);

  diff ("fwd 2001-01-01 -> 2003-03-15", 0.0, 803 * day);
  diff ("bwd 2003-03-15 -> 2001-01-01", 803 * day, 0.0);
  diff ("full fwd", 9 * day + 4 * 3600 + 5, 45 * day + 6 * 3600 + 30 * 60 + 20);
  diff ("borrow Nov20 -> Jan5", 323 * day, 369 * day);
  diff ("day-only Feb20 -> Mar5", 50 * day, 63 * day);
  return 0;
}
