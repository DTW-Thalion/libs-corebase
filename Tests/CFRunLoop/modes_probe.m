#include <CoreFoundation/CFRunLoop.h>
#include <CoreFoundation/CFDate.h>
#include <stdio.h>
#include <pthread.h>

static void printMode (const char *label, CFStringRef m)
{
  if (m == NULL)
    {
      printf ("%s = NULL\n", label);
      return;
    }
  char buf[256] = {0};
  CFStringGetCString (m, buf, sizeof buf, kCFStringEncodingUTF8);
  printf ("%s = '%s'\n", label, buf);
}

static void printAllModes (const char *label, CFRunLoopRef rl)
{
  CFArrayRef a = CFRunLoopCopyAllModes (rl);
  if (a == NULL)
    {
      printf ("%s = NULL array\n", label);
      return;
    }
  CFIndex n = CFArrayGetCount (a);
  printf ("%s count=%ld:", label, (long)n);
  for (CFIndex i = 0; i < n; i++)
    {
      char buf[256] = {0};
      CFStringGetCString (CFArrayGetValueAtIndex (a, i), buf, sizeof buf,
                          kCFStringEncodingUTF8);
      printf (" '%s'", buf);
    }
  printf ("\n");
  CFRelease (a);
}

static void *body (void *unused)
{
  CFRunLoopRef rl = CFRunLoopGetCurrent ();
  printf ("GetCurrent NULL? %d\n", rl == NULL);
  printf ("GetMain NULL? %d\n", CFRunLoopGetMain () == NULL);

  CFStringRef cur = CFRunLoopCopyCurrentMode (rl);
  printMode ("CopyCurrentMode(not running)", cur);
  if (cur)
    CFRelease (cur);

  printAllModes ("AllModes(fresh)", rl);

  CFRunLoopSourceContext c = {0};
  CFRunLoopSourceRef src = CFRunLoopSourceCreate (NULL, 0, &c);
  printf ("src Contains before add (default): %d\n",
          CFRunLoopContainsSource (rl, src, kCFRunLoopDefaultMode));
  CFRunLoopAddSource (rl, src, CFSTR ("myProbeMode"));
  printf ("src Contains after add (myProbeMode): %d\n",
          CFRunLoopContainsSource (rl, src, CFSTR ("myProbeMode")));
  printf ("src Contains (default, not added there): %d\n",
          CFRunLoopContainsSource (rl, src, kCFRunLoopDefaultMode));
  printAllModes ("AllModes(after add src to myProbeMode)", rl);
  CFRunLoopRemoveSource (rl, src, CFSTR ("myProbeMode"));
  printf ("src Contains after remove (myProbeMode): %d\n",
          CFRunLoopContainsSource (rl, src, CFSTR ("myProbeMode")));

  CFRunLoopObserverRef obs =
    CFRunLoopObserverCreate (NULL, kCFRunLoopAllActivities, false, 0, NULL, NULL);
  printf ("obs Contains before add: %d\n",
          CFRunLoopContainsObserver (rl, obs, kCFRunLoopDefaultMode));
  CFRunLoopAddObserver (rl, obs, kCFRunLoopDefaultMode);
  printf ("obs Contains after add (default): %d\n",
          CFRunLoopContainsObserver (rl, obs, kCFRunLoopDefaultMode));
  CFRunLoopRemoveObserver (rl, obs, kCFRunLoopDefaultMode);
  printf ("obs Contains after remove: %d\n",
          CFRunLoopContainsObserver (rl, obs, kCFRunLoopDefaultMode));

  CFRunLoopTimerRef t =
    CFRunLoopTimerCreate (NULL, CFAbsoluteTimeGetCurrent () + 1000, 0, 0, 0,
                          NULL, NULL);
  printf ("timer Contains before add: %d\n",
          CFRunLoopContainsTimer (rl, t, kCFRunLoopDefaultMode));
  CFRunLoopAddTimer (rl, t, kCFRunLoopDefaultMode);
  printf ("timer Contains after add (default): %d\n",
          CFRunLoopContainsTimer (rl, t, kCFRunLoopDefaultMode));
  CFRunLoopRemoveTimer (rl, t, kCFRunLoopDefaultMode);
  printf ("timer Contains after remove: %d\n",
          CFRunLoopContainsTimer (rl, t, kCFRunLoopDefaultMode));

  CFRunLoopAddCommonMode (rl, CFSTR ("myCommonMode"));
  printAllModes ("AllModes(after AddCommonMode myCommonMode)", rl);

  CFRunLoopSourceRef src2 = CFRunLoopSourceCreate (NULL, 0, &c);
  CFRunLoopAddSource (rl, src2, kCFRunLoopCommonModes);
  printf ("src2 Contains kCFRunLoopCommonModes after add: %d\n",
          CFRunLoopContainsSource (rl, src2, kCFRunLoopCommonModes));
  printf ("src2 Contains default (common member): %d\n",
          CFRunLoopContainsSource (rl, src2, kCFRunLoopDefaultMode));
  printf ("src2 Contains myCommonMode (common member): %d\n",
          CFRunLoopContainsSource (rl, src2, CFSTR ("myCommonMode")));
  CFRunLoopRemoveSource (rl, src2, kCFRunLoopCommonModes);
  printf ("src2 Contains common after remove: %d\n",
          CFRunLoopContainsSource (rl, src2, kCFRunLoopCommonModes));
  printf ("src2 Contains default after common remove: %d\n",
          CFRunLoopContainsSource (rl, src2, kCFRunLoopDefaultMode));

  printf ("PROBE DONE\n");
  return NULL;
}

int main (void)
{
  pthread_t th;
  pthread_create (&th, NULL, body, NULL);
  pthread_join (th, NULL);
  return 0;
}
