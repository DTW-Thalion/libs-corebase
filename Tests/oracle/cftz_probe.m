#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
name (const char *label, CFTimeZoneRef tz)
{
  char buf[64];
  if (tz == NULL) { printf ("%s: (null)\n", label); return; }
  CFStringGetCString (CFTimeZoneGetName (tz), buf, sizeof (buf),
    kCFStringEncodingUTF8);
  printf ("%s: name='%s' gmtoff=%d\n", label, buf,
    (int) CFTimeZoneGetSecondsFromGMT (tz, 0.0));
}

int main (void)
{
  CFTimeZoneRef z0 = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, 0.0);
  CFTimeZoneRef z5 = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, 5 * 3600);
  CFCalendarRef cal;

  name ("intervalGMT 0", z0);
  name ("intervalGMT +5h", z5);
  name ("byName GMT+00:00", CFTimeZoneCreateWithName (NULL,
    CFSTR ("GMT+00:00"), true));
  name ("byName GMT-05:00", CFTimeZoneCreateWithName (NULL,
    CFSTR ("GMT-05:00"), true));
  name ("byName GMT", CFTimeZoneCreateWithName (NULL, CFSTR ("GMT"), true));
  name ("byName UTC", CFTimeZoneCreateWithName (NULL, CFSTR ("UTC"), true));

  cal = CFCalendarCreateWithIdentifier (NULL, kCFGregorianCalendar);
  CFCalendarSetTimeZone (cal, z0);
  name ("calendar copyTZ", CFCalendarCopyTimeZone (cal));
  return 0;
}
