#include "CoreFoundation/CFString.h"
#include "../CFTesting.h"

int main (void)
{
  CFStringRef s;
  UniChar ls[3] = { 'A', 0x2028, 'B' };                 /* A, line separator, B */
  CFIndex b, e, c;

  /* A newline-terminated line: begin, contents-end (before \n), end (after). */
  s = CFSTR("Hello\nWorld");
  CFStringGetLineBounds (s, CFRangeMake (0, 1), &b, &e, &c);
  PASS_CF(b == 0 && c == 5 && e == 6,
    "CFStringGetLineBounds bounds a newline-terminated line.");
  CFStringGetLineBounds (s, CFRangeMake (6, 1), &b, &e, &c);
  PASS_CF(b == 6 && c == 11 && e == 11,
    "CFStringGetLineBounds bounds the last, unterminated line.");

  /* CRLF counts as a single line terminator. */
  s = CFSTR("A\r\nB");
  CFStringGetLineBounds (s, CFRangeMake (0, 1), &b, &e, &c);
  PASS_CF(b == 0 && c == 1 && e == 3,
    "CFStringGetLineBounds treats CRLF as one terminator.");

  /* U+2028 breaks a line but not a paragraph. */
  s = CFStringCreateWithCharacters (NULL, ls, 3);
  CFStringGetLineBounds (s, CFRangeMake (0, 1), &b, &e, &c);
  PASS_CF(b == 0 && c == 1 && e == 2,
    "CFStringGetLineBounds breaks on a line separator.");
  CFStringGetParagraphBounds (s, CFRangeMake (0, 1), &b, &e, &c);
  PASS_CF(b == 0 && c == 3 && e == 3,
    "CFStringGetParagraphBounds does not break on a line separator.");
  CFRelease (s);

  /* A newline is a paragraph separator. */
  s = CFSTR("P1\nP2");
  CFStringGetParagraphBounds (s, CFRangeMake (0, 1), &b, &e, &c);
  PASS_CF(b == 0 && c == 2 && e == 3,
    "CFStringGetParagraphBounds bounds a newline-terminated paragraph.");

  return 0;
}
