#include <CoreFoundation/CFAttributedString.h>
#include <CoreFoundation/CFString.h>
#include <stdio.h>

int
main (void)
{
  CFRange er;
  CFMutableAttributedStringRef m = CFAttributedStringCreateMutable (NULL, 0);
  CFAttributedStringReplaceString (m, CFRangeMake (0, 0), CFSTR ("abcdef"));
  CFAttributedStringBeginEditing (m);
  CFAttributedStringSetAttribute (m, CFRangeMake (0, 3), CFSTR ("k"),
                                  CFSTR ("v"));
  CFAttributedStringSetAttribute (m, CFRangeMake (3, 3), CFSTR ("k"),
                                  CFSTR ("v"));
  CFAttributedStringEndEditing (m);
  CFAttributedStringGetAttributes (m, 1, &er);
  printf ("after begin/end editing: GetAttributes(1) eff=(%ld,%ld)\n",
          (long)er.location, (long)er.length);
  printf ("PROBE DONE\n");
  CFRelease (m);
  return 0;
}
