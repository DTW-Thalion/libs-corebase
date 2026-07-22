#include "CoreFoundation/CFCharacterSet.h"
#include "CoreFoundation/CFData.h"
#include "../CFTesting.h"

int main (void)
{
  CFCharacterSetRef bmp, supp, rebuilt;
  CFDataRef bitmap;

  bmp = CFCharacterSetCreateWithCharactersInString (NULL, CFSTR("abc"));
  PASS_CF(CFCharacterSetHasMemberInPlane (bmp, 0),
    "A basic multilingual plane set has a member in plane 0.");
  PASS_CF(!CFCharacterSetHasMemberInPlane (bmp, 1),
    "A basic multilingual plane set has no member in plane 1.");
  CFRelease (bmp);

  supp = CFCharacterSetCreateWithCharactersInRange (NULL,
    CFRangeMake (0x1F600, 1));
  PASS_CF(CFCharacterSetHasMemberInPlane (supp, 1),
    "A supplementary set has a member in plane 1.");
  CFRelease (supp);

  bmp = CFCharacterSetCreateWithCharactersInString (NULL, CFSTR("aeiou"));
  bitmap = CFCharacterSetCreateBitmapRepresentation (NULL, bmp);
  PASS_CF(bitmap != NULL,
    "CFCharacterSetCreateBitmapRepresentation returns data.");
  rebuilt = CFCharacterSetCreateWithBitmapRepresentation (NULL, bitmap);
  PASS_CF(rebuilt != NULL && CFEqual (rebuilt, bmp),
    "A character set round-trips through its bitmap representation.");
  if (rebuilt != NULL)
    CFRelease (rebuilt);
  if (bitmap != NULL)
    CFRelease (bitmap);
  CFRelease (bmp);

  return 0;
}
