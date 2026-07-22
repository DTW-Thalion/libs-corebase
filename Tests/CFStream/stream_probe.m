#include <CoreFoundation/CFStream.h>
#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CFNumber.h>
#include <stdio.h>
#include <string.h>

static const char *
sname (CFStreamStatus s)
{
  switch (s)
    {
    case kCFStreamStatusNotOpen: return "NotOpen";
    case kCFStreamStatusOpening: return "Opening";
    case kCFStreamStatusOpen:    return "Open";
    case kCFStreamStatusReading: return "Reading";
    case kCFStreamStatusWriting: return "Writing";
    case kCFStreamStatusAtEnd:   return "AtEnd";
    case kCFStreamStatusClosed:  return "Closed";
    case kCFStreamStatusError:   return "Error";
    default: return "?";
    }
}

int
main (void)
{
  printf ("read typeID == write typeID? %d\n",
          CFReadStreamGetTypeID () == CFWriteStreamGetTypeID ());

  const char *data = "ABCDEFGHIJ"; /* 10 bytes */
  CFReadStreamRef r =
    CFReadStreamCreateWithBytesNoCopy (NULL, (const UInt8 *)data, 10,
                                       kCFAllocatorNull);
  printf ("R status before open: %s\n", sname (CFReadStreamGetStatus (r)));
  printf ("R hasBytes before open: %d\n", CFReadStreamHasBytesAvailable (r));
  CFReadStreamOpen (r);
  printf ("R status after open: %s\n", sname (CFReadStreamGetStatus (r)));
  printf ("R hasBytes after open: %d\n", CFReadStreamHasBytesAvailable (r));

  CFIndex avail = 0;
  const UInt8 *gb = CFReadStreamGetBuffer (r, 4, &avail);
  printf ("R GetBuffer(max4): ptr=%s avail=%ld first=%c\n",
          gb ? "nonNULL" : "NULL", (long)avail, gb ? gb[0] : '?');

  UInt8 b[4];
  CFIndex n = CFReadStreamRead (r, b, 4);
  printf ("R Read(4) after GetBuffer: n=%ld data=%.4s\n", (long)n, (char *)b);

  UInt8 big[64];
  CFIndex n2 = CFReadStreamRead (r, big, 64);
  printf ("R Read(rest): n=%ld status=%s hasBytes=%d\n", (long)n2,
          sname (CFReadStreamGetStatus (r)), CFReadStreamHasBytesAvailable (r));

  CFIndex n3 = CFReadStreamRead (r, big, 64);
  printf ("R Read(pastEnd): n=%ld status=%s\n", (long)n3,
          sname (CFReadStreamGetStatus (r)));

  CFStreamError re = CFReadStreamGetError (r);
  printf ("R error domain=%ld code=%ld\n", (long)re.domain, (long)re.error);
  printf ("R CopyProperty(unknown): %s\n",
          CFReadStreamCopyProperty (r, CFSTR ("bogus")) ? "nonNULL" : "NULL");
  CFReadStreamClose (r);
  printf ("R status after close: %s\n", sname (CFReadStreamGetStatus (r)));
  CFRelease (r);

  UInt8 fb[8];
  CFWriteStreamRef w = CFWriteStreamCreateWithBuffer (NULL, fb, 8);
  printf ("W status before open: %s\n", sname (CFWriteStreamGetStatus (w)));
  CFWriteStreamOpen (w);
  printf ("W status after open: %s canAccept=%d\n",
          sname (CFWriteStreamGetStatus (w)), CFWriteStreamCanAcceptBytes (w));
  CFIndex wn = CFWriteStreamWrite (w, (const UInt8 *)"ABCDEFGHIJ", 10);
  printf ("W Write(10 into 8): n=%ld status=%s canAccept=%d\n", (long)wn,
          sname (CFWriteStreamGetStatus (w)), CFWriteStreamCanAcceptBytes (w));
  CFIndex wn2 = CFWriteStreamWrite (w, (const UInt8 *)"XY", 2);
  printf ("W Write(2 when full): n=%ld\n", (long)wn2);
  printf ("W DataWritten prop (fixed buf): %s\n",
          CFWriteStreamCopyProperty (w, kCFStreamPropertyDataWritten)
            ? "nonNULL" : "NULL");
  CFStreamError we = CFWriteStreamGetError (w);
  printf ("W error domain=%ld code=%ld\n", (long)we.domain, (long)we.error);
  CFWriteStreamClose (w);
  printf ("W status after close: %s\n", sname (CFWriteStreamGetStatus (w)));
  CFRelease (w);

  CFWriteStreamRef wa = CFWriteStreamCreateWithAllocatedBuffers (NULL, NULL);
  printf ("WA status before open: %s\n", sname (CFWriteStreamGetStatus (wa)));
  CFWriteStreamOpen (wa);
  printf ("WA canAccept: %d\n", CFWriteStreamCanAcceptBytes (wa));
  CFWriteStreamWrite (wa, (const UInt8 *)"hello", 5);
  CFDataRef dw = CFWriteStreamCopyProperty (wa, kCFStreamPropertyDataWritten);
  printf ("WA DataWritten len=%ld\n", dw ? (long)CFDataGetLength (dw) : -1);
  if (dw)
    CFRelease (dw);
  CFRelease (wa);

  printf ("PROBE DONE\n");
  return 0;
}
