#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
name (CFTimeInterval ti)
{
  CFTimeZoneRef tz = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, ti);
  char buf[64];
  CFStringGetCString (CFTimeZoneGetName (tz), buf, sizeof (buf),
    kCFStringEncodingUTF8);
  printf ("offset %6d -> '%s'\n", (int) ti, buf);
}

int main (void)
{
  name (0.0);
  name (5 * 3600);
  name (-5 * 3600);
  name (5 * 3600 + 30 * 60);
  name (-(5 * 3600 + 30 * 60));
  name (30 * 60);
  return 0;
}
