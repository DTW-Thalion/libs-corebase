#include "CoreFoundation/CFNumber.h"
#include "../CFTesting.h"

int main (void)
{
  int i = 42;
  double d = 3.5;
  int a = 1, b = 2;
  CFNumberRef n, nf, na, nb;

  PASS_CF(CFNumberGetTypeID () != 0, "CFNumberGetTypeID is not zero.");

  n = CFNumberCreate (NULL, kCFNumberIntType, &i);
  PASS_CF(CFGetTypeID (n) == CFNumberGetTypeID (),
    "A number has the number type ID.");
  PASS_CF(!CFNumberIsFloatType (n), "An integer is not a float type.");
  PASS_CF(CFNumberGetByteSize (n) == 4,
    "CFNumberGetByteSize returns the size of an int.");

  nf = CFNumberCreate (NULL, kCFNumberDoubleType, &d);
  PASS_CF(CFNumberIsFloatType (nf), "A double is a float type.");
  PASS_CF(CFNumberGetByteSize (nf) == 8,
    "CFNumberGetByteSize returns the size of a double.");
  CFRelease (nf);
  CFRelease (n);

  na = CFNumberCreate (NULL, kCFNumberIntType, &a);
  nb = CFNumberCreate (NULL, kCFNumberIntType, &b);
  PASS_CF(CFNumberCompare (na, nb, NULL) == kCFCompareLessThan,
    "CFNumberCompare orders a smaller number first.");
  PASS_CF(CFNumberCompare (nb, na, NULL) == kCFCompareGreaterThan,
    "CFNumberCompare orders a larger number last.");
  PASS_CF(CFNumberCompare (na, na, NULL) == kCFCompareEqualTo,
    "Equal numbers compare equal.");
  CFRelease (na);
  CFRelease (nb);

  return 0;
}
