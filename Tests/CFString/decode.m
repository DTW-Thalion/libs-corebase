#include "CoreFoundation/CFString.h"
#include "../CFTesting.h"

/* CFStringCreateWithBytes decoding for the byte encodings backed by
   GSUnicodeFromEncoding. */

static CFStringRef
decode (const UInt8 *bytes, CFIndex len, CFStringEncoding enc)
{
  return CFStringCreateWithBytes (NULL, bytes, len, enc, false);
}

int main (void)
{
  UniChar ec = 0x00E9;
  CFStringRef eacute = CFStringCreateWithCharacters (NULL, &ec, 1);

  UInt8 ascii[] = { 0x41 };
  UInt8 utf8[] = { 0xC3, 0xA9 };
  UInt8 u16be[] = { 0x00, 0x41 };
  UInt8 u16le[] = { 0x41, 0x00 };
  UInt8 u32be[] = { 0x00, 0x00, 0x00, 0x41 };
  UInt8 u32le[] = { 0x41, 0x00, 0x00, 0x00 };
  UInt8 latin1[] = { 0xE9 };
  UInt8 nonlossy[] = { 0x5C, 0x33, 0x35, 0x31 };  /* \351 = octal 0351 */

  PASS_CFEQ (decode (ascii, 1, kCFStringEncodingASCII), CFSTR ("A"),
    "ASCII 0x41 decodes to A.");
  PASS_CFEQ (decode (utf8, 2, kCFStringEncodingUTF8), eacute,
    "UTF-8 C3 A9 decodes to U+00E9.");
  PASS_CFEQ (decode (u16be, 2, kCFStringEncodingUTF16BE), CFSTR ("A"),
    "UTF-16BE 00 41 decodes to A.");
  PASS_CFEQ (decode (u16le, 2, kCFStringEncodingUTF16LE), CFSTR ("A"),
    "UTF-16LE 41 00 decodes to A.");
  PASS_CFEQ (decode (u32be, 4, kCFStringEncodingUTF32BE), CFSTR ("A"),
    "UTF-32BE 00 00 00 41 decodes to A.");
  PASS_CFEQ (decode (u32le, 4, kCFStringEncodingUTF32LE), CFSTR ("A"),
    "UTF-32LE 41 00 00 00 decodes to A.");
  PASS_CFEQ (decode (latin1, 1, kCFStringEncodingISOLatin1), eacute,
    "ISO Latin 1 0xE9 decodes to U+00E9.");
  PASS_CFEQ (decode (nonlossy, 4, kCFStringEncodingNonLossyASCII), eacute,
    "Non-lossy ASCII \\351 decodes to U+00E9.");

  return 0;
}
