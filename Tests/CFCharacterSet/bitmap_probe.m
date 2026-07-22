#include "CoreFoundation/CFCharacterSet.h"
#include "CoreFoundation/CFData.h"
#include "../CFTesting.h"

int main (void)
{
  CFCharacterSetRef s;
  CFDataRef d;
  const UInt8 *p;

  /* BMP-only set {'A'} (0x41): byte = 0x41>>3 = 8, bit = 0x41&7 = 1. */
  s = CFCharacterSetCreateWithCharactersInString (NULL, CFSTR("A"));
  d = CFCharacterSetCreateBitmapRepresentation (NULL, s);
  PASS_CF(CFDataGetLength (d) == 8192, "BMP bitmap is 8192 bytes.");
  p = CFDataGetBytePtr (d);
  PASS_CF((p[8] & (1 << 1)) != 0, "The bit for 'A' is set (LSB order).");
  PASS_CF((p[8] & ~(1 << 1)) == 0, "Only the bit for 'A' is set in its byte.");
  CFRelease (d);
  CFRelease (s);

  /* Supplementary set {0x1F600}: low 16 bits = 0xF600. */
  s = CFCharacterSetCreateWithCharactersInRange (NULL, CFRangeMake (0x1F600, 1));
  d = CFCharacterSetCreateBitmapRepresentation (NULL, s);
  PASS_CF(CFDataGetLength (d) == 8192 + 1 + 8192,
    "A supplementary set adds a plane byte and a plane bitmap.");
  p = CFDataGetBytePtr (d);
  PASS_CF(p[8192] == 1, "The supplementary plane number byte is 1.");
  PASS_CF((p[8193 + (0xF600 >> 3)] & (1 << (0xF600 & 7))) != 0,
    "The bit for U+1F600 is set in the plane-1 bitmap.");
  CFRelease (d);
  CFRelease (s);

  return 0;
}
