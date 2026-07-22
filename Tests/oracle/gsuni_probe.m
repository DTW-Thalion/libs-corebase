#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
hexrep (const char *label, CFStringRef s, CFStringEncoding enc)
{
  CFDataRef d = CFStringCreateExternalRepresentation (NULL, s, enc, '?');
  CFIndex i, n;
  const UInt8 *p;

  printf ("%-32s: ", label);
  if (d == NULL) { printf ("(null)\n"); return; }
  p = CFDataGetBytePtr (d);
  n = CFDataGetLength (d);
  for (i = 0; i < n; i++) printf ("%02x ", p[i]);
  printf ("(%ld bytes)\n", (long) n);
  CFRelease (d);
}

int main (void)
{
  CFStringRef A = CFSTR ("A");
  CFStringRef eacute = CFSTR ("é");
  UInt8 be[] = { 0x00, 0x41 };
  UInt8 le[] = { 0x41, 0x00 };
  UInt8 bom_be[] = { 0xFE, 0xFF, 0x00, 0x41 };
  UInt8 buf[16];
  CFIndex used, nconv;
  CFStringRef sbe, sle, sbom;

  hexrep ("extrep A UTF8", A, kCFStringEncodingUTF8);
  hexrep ("extrep A UTF16", A, kCFStringEncodingUTF16);
  hexrep ("extrep A UTF16BE", A, kCFStringEncodingUTF16BE);
  hexrep ("extrep A UTF16LE", A, kCFStringEncodingUTF16LE);
  hexrep ("extrep A UTF32", A, kCFStringEncodingUTF32);
  hexrep ("extrep A UTF32BE", A, kCFStringEncodingUTF32BE);
  hexrep ("extrep eacute ISOLatin1", eacute, kCFStringEncodingISOLatin1);
  hexrep ("extrep eacute ASCII", eacute, kCFStringEncodingASCII);
  hexrep ("extrep eacute NonLossyASCII", eacute, kCFStringEncodingNonLossyASCII);
  hexrep ("extrep A NonLossyASCII", A, kCFStringEncodingNonLossyASCII);

  sbe = CFStringCreateWithBytes (NULL, be, 2, kCFStringEncodingUTF16, false);
  sle = CFStringCreateWithBytes (NULL, le, 2, kCFStringEncodingUTF16, false);
  sbom = CFStringCreateWithBytes (NULL, bom_be, 4, kCFStringEncodingUTF16, false);
  printf ("WithBytes UTF16 {00 41} no-ext: U+%04X\n",
    sbe ? CFStringGetCharacterAtIndex (sbe, 0) : 0xFFFF);
  printf ("WithBytes UTF16 {41 00} no-ext: U+%04X\n",
    sle ? CFStringGetCharacterAtIndex (sle, 0) : 0xFFFF);
  printf ("WithBytes UTF16 {FE FF 00 41} no-ext: len=%ld U+%04X\n",
    sbom ? (long) CFStringGetLength (sbom) : -1,
    sbom ? CFStringGetCharacterAtIndex (sbom, 0) : 0xFFFF);

  used = 0;
  nconv = CFStringGetBytes (eacute, CFRangeMake (0, 1),
    kCFStringEncodingISOLatin1, 0, false, buf, sizeof (buf), &used);
  printf ("GetBytes eacute ISOLatin1: nconv=%ld used=%ld byte0=%02x\n",
    (long) nconv, (long) used, buf[0]);

  used = 0;
  nconv = CFStringGetBytes (eacute, CFRangeMake (0, 1),
    kCFStringEncodingASCII, '?', false, buf, sizeof (buf), &used);
  printf ("GetBytes eacute ASCII loss='?': nconv=%ld used=%ld byte0=%02x\n",
    (long) nconv, (long) used, buf[0]);

  used = 0;
  nconv = CFStringGetBytes (eacute, CFRangeMake (0, 1),
    kCFStringEncodingASCII, 0, false, buf, sizeof (buf), &used);
  printf ("GetBytes eacute ASCII loss=0: nconv=%ld used=%ld\n",
    (long) nconv, (long) used);

  used = 0;
  nconv = CFStringGetBytes (CFSTR ("ABCDE"), CFRangeMake (0, 5),
    kCFStringEncodingASCII, 0, false, buf, 3, &used);
  printf ("GetBytes ABCDE ASCII max=3: nconv=%ld used=%ld\n",
    (long) nconv, (long) used);

  used = 0;
  nconv = CFStringGetBytes (A, CFRangeMake (0, 1), kCFStringEncodingUTF16,
    0, false, buf, sizeof (buf), &used);
  printf ("GetBytes A UTF16 ext=false: nconv=%ld used=%ld b0=%02x b1=%02x\n",
    (long) nconv, (long) used, buf[0], buf[1]);

  used = 0;
  nconv = CFStringGetBytes (A, CFRangeMake (0, 1), kCFStringEncodingUTF16,
    0, true, buf, sizeof (buf), &used);
  printf ("GetBytes A UTF16 ext=true: nconv=%ld used=%ld b0=%02x b1=%02x b2=%02x b3=%02x\n",
    (long) nconv, (long) used, buf[0], buf[1], buf[2], buf[3]);

  return 0;
}
