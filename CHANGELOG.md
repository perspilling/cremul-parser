# Changelog

## 0.8.0

Bumped to version 0.8.0 to indicate that it is getting close to finished as a 1.0 version.
 
- Corrected a bug in the regular expressions
- Added support for multiple CREMUL messages in a single file
- Changed CremulParser.msg attr to CremulParser.messages (an array) 

## 0.0.6

- Corrected a bug in CremulPaymentTx so that it is now able to handle empty FII segments.
- Corrected a bug in CremulNameAndAddress so that it is now also able to handle addresses in structured form.

## 0.0.5

- Refactored the ParserHelper to make it more DRY, and fixed a bug in CremulHeader regarding the parsing the 
optional NAD-element in the header. 
- Fixed a bug in CremulMoney which caused amounts with decimal mark to be parsed without the fractional part.
- Fixed a bug in CremulPaymentTx related to parsing the FII+OR segment when it contains a payer 
account holder name in addition to the account number.

## 0.0.4

Added support for files using a CNT:LIN symbol instead of CNT:LI as the standard says.

## 0.0.3

Added support for converting files to UTF-8 format on the fly.

## 0.0.2

Updated doc only.

## 0.0.1

Initial version