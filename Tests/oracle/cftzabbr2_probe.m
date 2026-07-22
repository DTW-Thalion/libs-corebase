#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
show (CFTimeInterval ti)
{
  CFTimeZoneRef tz = CFTimeZoneCreateWithTimeIntervalFromGMT (NULL, ti);
  CFStringRef abbr = CFTimeZoneCopyAbbreviation (tz, 0.0);
  char a[64];
  a[0] = 0;
  if (abbr)
    CFStringGetCString (abbr, a, sizeof (a), kCFStringEncodingUTF8);
  printf ("offset %6d -> abbrev='%s'\n", (int) ti, a);
}

int main (void)
{
  show (5 * 3600 + 30 * 60);       /* +5:30 */
  show (-(5 * 3600 + 30 * 60));    /* -5:30 */
  show (30 * 60);                  /* +0:30 */
  show (10 * 3600);                /* +10:00 */
  show (9 * 3600 + 45 * 60);       /* +9:45 */
  return 0;
}
