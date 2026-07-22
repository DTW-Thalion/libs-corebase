#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
show (CFTimeInterval ti)
{
  CFTimeZoneRef tz = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, ti);
  CFStringRef abbr = CFTimeZoneCopyAbbreviation (tz, 0.0);
  char n[64], a[64];
  CFStringGetCString (CFTimeZoneGetName (tz), n, sizeof (n),
    kCFStringEncodingUTF8);
  a[0] = 0;
  if (abbr)
    CFStringGetCString (abbr, a, sizeof (a), kCFStringEncodingUTF8);
  printf ("offset %6d -> name='%s' abbrev='%s'\n", (int) ti, n, a);
}

int main (void)
{
  show (0.0);
  show (5 * 3600);
  show (-5 * 3600);
  return 0;
}
