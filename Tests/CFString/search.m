#include "CoreFoundation/CFString.h"
#include "CoreFoundation/CFCharacterSet.h"
#include "../CFTesting.h"

int main (void)
{
  CFStringRef s = CFSTR("Hello, World");
  CFCharacterSetRef digits;
  CFRange r;
  Boolean found;

  PASS_CF(CFStringHasPrefix (s, CFSTR("Hello")),
    "CFStringHasPrefix matches a leading substring.");
  PASS_CF(!CFStringHasPrefix (s, CFSTR("World")),
    "CFStringHasPrefix rejects a non-prefix.");
  PASS_CF(CFStringHasPrefix (s, CFSTR("")),
    "The empty string is a prefix.");
  PASS_CF(CFStringHasSuffix (s, CFSTR("World")),
    "CFStringHasSuffix matches a trailing substring.");
  PASS_CF(!CFStringHasSuffix (s, CFSTR("Hello")),
    "CFStringHasSuffix rejects a non-suffix.");

  r = CFStringFind (s, CFSTR("o"), 0);
  PASS_CF(r.location == 4 && r.length == 1,
    "CFStringFind returns the first match.");
  r = CFStringFind (s, CFSTR("o"), kCFCompareBackwards);
  PASS_CF(r.location == 8 && r.length == 1,
    "CFStringFind with kCFCompareBackwards returns the last match.");
  r = CFStringFind (s, CFSTR("z"), 0);
  PASS_CF(r.location == kCFNotFound,
    "CFStringFind reports kCFNotFound for an absent substring.");
  r = CFStringFind (s, CFSTR("hello"), kCFCompareCaseInsensitive);
  PASS_CF(r.location == 0 && r.length == 5,
    "CFStringFind honours kCFCompareCaseInsensitive.");

  found = CFStringFindWithOptions (s, CFSTR("o"),
    CFRangeMake (5, CFStringGetLength (s) - 5), 0, &r);
  PASS_CF(found && r.location == 8,
    "CFStringFindWithOptions searches within the given range.");
  found = CFStringFindWithOptions (s, CFSTR("Hello"),
    CFRangeMake (0, CFStringGetLength (s)), kCFCompareAnchored, &r);
  PASS_CF(found && r.location == 0,
    "kCFCompareAnchored matches at the range start.");
  found = CFStringFindWithOptions (s, CFSTR("World"),
    CFRangeMake (0, CFStringGetLength (s)), kCFCompareAnchored, &r);
  PASS_CF(!found,
    "kCFCompareAnchored does not match away from the range start.");

  PASS_CF(CFStringCompare (CFSTR("abc"), CFSTR("abc"), 0) == kCFCompareEqualTo,
    "Equal strings compare equal.");
  PASS_CF(CFStringCompare (CFSTR("abc"), CFSTR("abd"), 0) == kCFCompareLessThan,
    "CFStringCompare orders by character.");
  PASS_CF(CFStringCompare (CFSTR("ABC"), CFSTR("abc"),
    kCFCompareCaseInsensitive) == kCFCompareEqualTo,
    "kCFCompareCaseInsensitive ignores case.");
  PASS_CF(CFStringCompare (CFSTR("file10"), CFSTR("file9"),
    kCFCompareNumerically) == kCFCompareGreaterThan,
    "kCFCompareNumerically orders embedded numbers.");

  digits = CFCharacterSetGetPredefined (kCFCharacterSetDecimalDigit);
  found = CFStringFindCharacterFromSet (CFSTR("abc123"), digits,
    CFRangeMake (0, 6), 0, &r);
  PASS_CF(found && r.location == 3,
    "CFStringFindCharacterFromSet finds the first set member.");
  found = CFStringFindCharacterFromSet (CFSTR("abcdef"), digits,
    CFRangeMake (0, 6), 0, &r);
  PASS_CF(!found,
    "CFStringFindCharacterFromSet reports no match when the set is absent.");

  return 0;
}
