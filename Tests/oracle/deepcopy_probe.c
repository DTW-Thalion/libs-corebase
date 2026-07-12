/* Oracle probe: what does CFPropertyListCreateDeepCopy do with an invalid or
 * cyclic property list?  Each scenario runs in its own process (selected by
 * argv[1]) so a crash or hang in one does not hide the others.  A watchdog
 * thread kills the process if a scenario hangs.  Compiles against Apple
 * CoreFoundation (clang -framework CoreFoundation) and, being pure CF, also
 * under GNUstep corebase for an A/B comparison. */
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>

static void *
watchdog (void *arg)
{
  (void) arg;
  sleep (5);
  fprintf (stderr, "WATCHDOG: scenario hung, killing process\n");
  kill (getpid (), SIGKILL);
  return NULL;
}

static void
report (const char *name, CFPropertyListRef copy)
{
  if (copy == NULL)
    {
      printf ("RESULT %s: returned NULL\n", name);
    }
  else
    {
      printf ("RESULT %s: returned non-NULL, typeID=%lu",
              name, (unsigned long) CFGetTypeID (copy));
      if (CFGetTypeID (copy) == CFArrayGetTypeID ())
        printf (", array count=%ld", (long) CFArrayGetCount (copy));
      else if (CFGetTypeID (copy) == CFDictionaryGetTypeID ())
        printf (", dict count=%ld", (long) CFDictionaryGetCount (copy));
      printf ("\n");
      CFRelease ((CFTypeRef) copy);
    }
}

int
main (int argc, char **argv)
{
  pthread_t wd;
  const char *sc;

  setvbuf (stdout, NULL, _IONBF, 0);
  setvbuf (stderr, NULL, _IONBF, 0);
  if (argc < 2)
    return 2;
  sc = argv[1];
  pthread_create (&wd, NULL, watchdog, NULL);

  if (strcmp (sc, "valid") == 0)
    {
      int n = 1;
      CFNumberRef num = CFNumberCreate (NULL, kCFNumberIntType, &n);
      const void *vals[2] = { CFSTR ("a"), num };
      CFArrayRef arr = CFArrayCreate (NULL, vals, 2, &kCFTypeArrayCallBacks);

      printf ("START %s: array of [string, number]\n", sc);
      report (sc, CFPropertyListCreateDeepCopy (NULL, arr,
                                                kCFPropertyListImmutable));
    }
  else if (strcmp (sc, "badvalue") == 0)
    {
      /* A CFURL is not a valid property-list type. */
      CFURLRef u = CFURLCreateWithString (NULL, CFSTR ("http://example.com"),
                                          NULL);
      const void *vals[1] = { u };
      CFArrayRef arr = CFArrayCreate (NULL, vals, 1, &kCFTypeArrayCallBacks);

      printf ("START %s: array containing a CFURL\n", sc);
      report (sc, CFPropertyListCreateDeepCopy (NULL, arr,
                                                kCFPropertyListImmutable));
    }
  else if (strcmp (sc, "badkey") == 0)
    {
      /* A dictionary key must be a string in a property list. */
      int k = 42;
      CFNumberRef key = CFNumberCreate (NULL, kCFNumberIntType, &k);
      const void *keys[1] = { key };
      const void *vals[1] = { CFSTR ("v") };
      CFDictionaryRef d = CFDictionaryCreate (NULL, keys, vals, 1,
                                              &kCFTypeDictionaryKeyCallBacks,
                                              &kCFTypeDictionaryValueCallBacks);

      printf ("START %s: dictionary with a CFNumber key\n", sc);
      report (sc, CFPropertyListCreateDeepCopy (NULL, d,
                                                kCFPropertyListImmutable));
    }
  else if (strcmp (sc, "cyclic") == 0)
    {
      CFMutableArrayRef arr = CFArrayCreateMutable (NULL, 0,
                                                    &kCFTypeArrayCallBacks);
      CFArrayAppendValue (arr, arr);    /* the array contains itself */

      printf ("START %s: array containing itself\n", sc);
      report (sc, CFPropertyListCreateDeepCopy (NULL, arr,
                                                kCFPropertyListImmutable));
    }
  else
    {
      fprintf (stderr, "unknown scenario %s\n", sc);
      return 2;
    }

  return 0;
}
