PotionStorefront
--------------------------

PotionStorefront is a Cocoa framework that lets users buy software
from within a Mac application. It collects order information
and sends it off to [Potion Store](http://www.potionfactory.com/potionstore)
for final processing.


Features
--------

- Fetches latest pricing from a plist file on the web
- Autofill billing address using data from the Address Book
- Auto-detect credit card type as the user types in the credit card number
- Localside credit card number verification using the Luhn algorithm


Usage:
------

- Example product data file: http://www.potionfactory.com/files/thehitlist/store_products.plist
- Look at AppDelegate.m to see example usage.
- The delegate object needs to implement the following method to be notified
  of when the order completes successfully:

    - (void)orderDidFinishCharging:(PFOrder *)order;


Requirements
------------

- Mac OS X 10.5
