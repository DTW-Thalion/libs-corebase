#include "CoreFoundation/CFString.h"
#include "../CFTesting.h"

int main (void)
{
  UniChar chars[2] = { 0x0065, 0x0301 };        /* e + combining acute */
  CFStringRef s = CFStringCreateWithCharacters (NULL, chars, 2);
  CFRange r0 = CFStringGetRangeOfComposedCharactersAtIndex (s, 0);
  CFRange r1 = CFStringGetRangeOfComposedCharactersAtIndex (s, 1);

  PASS_CF(r0.location == 0 && r0.length == 2,
    "A base plus combining mark is one composed sequence at index 0.");
  PASS_CF(r1.location == 0 && r1.length == 2,
    "The combining mark resolves to the base sequence.");

  CFRelease (s);
  return 0;
}
