#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static CFCalendarRef cal;
static double day = 86400.0;

int main (void)
{
  CFTimeZoneRef gmt = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, 0.0);
  CFAbsoluteTime at;
  int y, mo, d;
  CFRange r;
  CFAbsoluteTime start;
  CFTimeInterval ti;
  CFStringRef ident;
  char buf[64];

  cal = CFCalendarCreateWithIdentifier (NULL, kCFGregorianCalendar);
  CFCalendarSetTimeZone (cal, gmt);

  ident = CFCalendarGetIdentifier (cal);
  CFStringGetCString (ident, buf, sizeof (buf), kCFStringEncodingUTF8);
  printf ("identifier='%s'\n", buf);
  printf ("firstWeekday(default)=%ld\n", (long) CFCalendarGetFirstWeekday (cal));
  printf ("minDaysInFirstWeek(default)=%ld\n",
    (long) CFCalendarGetMinimumDaysInFirstWeek (cal));

  CFCalendarSetFirstWeekday (cal, 2);
  printf ("firstWeekday(set 2)=%ld\n", (long) CFCalendarGetFirstWeekday (cal));
  CFCalendarSetMinimumDaysInFirstWeek (cal, 4);
  printf ("minDays(set 4)=%ld\n",
    (long) CFCalendarGetMinimumDaysInFirstWeek (cal));

  at = 0.0;
  CFCalendarComposeAbsoluteTime (cal, &at, "yMd", 2003, 3, 15);
  printf ("compose 2003-03-15 -> %ld days\n", (long) (at / day));

  y = mo = d = 0;
  CFCalendarDecomposeAbsoluteTime (cal, 803 * day, "yMd", &y, &mo, &d);
  printf ("decompose 803d -> y=%d mo=%d d=%d\n", y, mo, d);

  at = 45 * day;                 /* 2001-02-15 */
  CFCalendarAddComponents (cal, &at, 0, "M", 1);
  printf ("2001-02-15 + 1 month -> %ld days\n", (long) (at / day));

  CFCalendarGetTimeRangeOfUnit (cal, kCFCalendarUnitMonth, 45 * day,
    &start, &ti);
  printf ("timeRange(month, 2001-02-15): start=%ldd interval=%ldd\n",
    (long) (start / day), (long) (ti / day));

  r = CFCalendarGetMaximumRangeOfUnit (cal, kCFCalendarUnitDay);
  printf ("maxRange(day)={%ld,%ld}\n", (long) r.location, (long) r.length);
  r = CFCalendarGetMinimumRangeOfUnit (cal, kCFCalendarUnitDay);
  printf ("minRange(day)={%ld,%ld}\n", (long) r.location, (long) r.length);

  r = CFCalendarGetRangeOfUnit (cal, kCFCalendarUnitDay, kCFCalendarUnitMonth,
    45 * day);
  printf ("rangeOfUnit(day in month, Feb)={%ld,%ld}\n",
    (long) r.location, (long) r.length);
  r = CFCalendarGetRangeOfUnit (cal, kCFCalendarUnitDay, kCFCalendarUnitMonth,
    63 * day);
  printf ("rangeOfUnit(day in month, Mar)={%ld,%ld}\n",
    (long) r.location, (long) r.length);

  printf ("ordinality(day in month, 2001-02-15)=%ld\n",
    (long) CFCalendarGetOrdinalityOfUnit (cal, kCFCalendarUnitDay,
      kCFCalendarUnitMonth, 45 * day));
  printf ("ordinality(day in year, 2001-02-15)=%ld\n",
    (long) CFCalendarGetOrdinalityOfUnit (cal, kCFCalendarUnitDay,
      kCFCalendarUnitYear, 45 * day));
  printf ("ordinality(month in year, 2001-02-15)=%ld\n",
    (long) CFCalendarGetOrdinalityOfUnit (cal, kCFCalendarUnitMonth,
      kCFCalendarUnitYear, 45 * day));

  return 0;
}
