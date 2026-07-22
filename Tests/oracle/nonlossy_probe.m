#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>

static void
enc (const char *label, const UniChar *c, CFIndex n)
{
  CFStringRef s = CFStringCreateWithCharacters (NULL, c, n);
  CFDataRef d = CFStringCreateExternalRepresentation (NULL, s,
    kCFStringEncodingNonLossyASCII, 0);
  const UInt8 *p;
  CFIndex i, len;

  printf ("enc %-10s: ", label);
  if (d == NULL) { printf ("(null)\n"); return; }
  p = CFDataGetBytePtr (d);
  len = CFDataGetLength (d);
  printf ("'");
  for (i = 0; i < len; i++) printf ("%c", p[i] >= 32 && p[i] < 127 ? p[i] : '.');
  printf ("'  [");
  for (i = 0; i < len; i++) printf ("%02x ", p[i]);
  printf ("]\n");
}

static void
dec (const char *bytes)
{
  CFStringRef s = CFStringCreateWithBytes (NULL, (const UInt8 *) bytes,
    strlen (bytes), kCFStringEncodingNonLossyASCII, false);
  CFIndex i, len;

  printf ("dec '%s' -> ", bytes);
  if (s == NULL) { printf ("(null)\n"); return; }
  len = CFStringGetLength (s);
  printf ("len=%ld: ", (long) len);
  for (i = 0; i < len; i++)
    printf ("U+%04X ", CFStringGetCharacterAtIndex (s, i));
  printf ("\n");
}

int main (void)
{
  UniChar eacute = 0x00E9, euro = 0x20AC, A = 0x0041, bs = 0x005C;
  UniChar nl = 0x000A, u80 = 0x0080, yuml = 0x00FF, amac = 0x0100;
  UniChar surr[] = { 0xD83D, 0xDE00 };
  UniChar mixed[] = { 0x0041, 0x00E9, 0x0042 };

  enc ("eacute", &eacute, 1);
  enc ("euro", &euro, 1);
  enc ("A", &A, 1);
  enc ("backslash", &bs, 1);
  enc ("newline", &nl, 1);
  enc ("U+0080", &u80, 1);
  enc ("yuml", &yuml, 1);
  enc ("Amacron", &amac, 1);
  enc ("surrogate", surr, 2);
  enc ("mixed", mixed, 3);

  dec ("\\351");
  dec ("\\u20ac");
  dec ("\\u20AC");
  dec ("\\\\");
  dec ("A\\351B");
  dec ("\\ud83d\\ude00");
  return 0;
}
