#include "CoreFoundation/CFString.h"
#include "../CFTesting.h"

/* CFStringCreateExternalRepresentation and its round-trip through
   CFStringCreateWithBytes with the external-representation flag set. */

static int
databytes (CFDataRef d, const UInt8 *expect, CFIndex n)
{
  const UInt8 *p;
  CFIndex i;

  if (d == NULL || CFDataGetLength (d) != n)
    return 0;
  p = CFDataGetBytePtr (d);
  for (i = 0; i < n; i++)
    if (p[i] != expect[i])
      return 0;
  return 1;
}

static int
roundtrip (CFStringRef s, CFStringEncoding enc)
{
  CFDataRef d = CFStringCreateExternalRepresentation (NULL, s, enc, 0);
  CFStringRef back;
  int ok;

  if (d == NULL)
    return 0;
  back = CFStringCreateWithBytes (NULL, CFDataGetBytePtr (d),
    CFDataGetLength (d), enc, true);
  ok = back != NULL && CFStringCompare (s, back, 0) == kCFCompareEqualTo;
  return ok;
}

int main (void)
{
  UniChar ec = 0x00E9;
  CFStringRef eacute = CFStringCreateWithCharacters (NULL, &ec, 1);
  CFStringRef A = CFSTR ("A");
  UInt8 a_utf8[] = { 0x41 };
  UInt8 a_u16be[] = { 0x00, 0x41 };
  UInt8 a_u16le[] = { 0x41, 0x00 };
  UInt8 a_u32be[] = { 0x00, 0x00, 0x00, 0x41 };
  UInt8 e_latin1[] = { 0xE9 };
  UInt8 e_nonlossy[] = { 0x5C, 0x33, 0x35, 0x31 };

  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, A, kCFStringEncodingUTF8, 0),
    a_utf8, 1), "External UTF-8 of A is 41.");
  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, A, kCFStringEncodingUTF16BE, 0),
    a_u16be, 2), "External UTF-16BE of A is 00 41.");
  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, A, kCFStringEncodingUTF16LE, 0),
    a_u16le, 2), "External UTF-16LE of A is 41 00.");
  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, A, kCFStringEncodingUTF32BE, 0),
    a_u32be, 4), "External UTF-32BE of A is 00 00 00 41.");
  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, eacute,
      kCFStringEncodingISOLatin1, 0), e_latin1, 1),
    "External ISO Latin 1 of U+00E9 is E9.");
  PASS_CF (databytes (
    CFStringCreateExternalRepresentation (NULL, eacute,
      kCFStringEncodingNonLossyASCII, 0), e_nonlossy, 4),
    "External non-lossy ASCII of U+00E9 is \\351.");

  PASS_CF (roundtrip (eacute, kCFStringEncodingUTF8),
    "UTF-8 external representation round-trips.");
  PASS_CF (roundtrip (eacute, kCFStringEncodingUTF16),
    "UTF-16 external representation round-trips.");
  PASS_CF (roundtrip (eacute, kCFStringEncodingUTF32),
    "UTF-32 external representation round-trips.");

  return 0;
}
