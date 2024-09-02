# froogle
Analytics for personal finances

## Format

**DATE** ; **IN/OUT** ; **AMOUNT** ; **CATEGORY** ; **DETAILS** ; **NECESSITY** ; **OWE ZZ** ; **SETTLED**

## Fields

- **DATE** (r): `YYYY-MM-DD`
- **IN/OUT** (r)
- **AMOUNT** (r)
- **CATEGORY** (r)
- **DETAILS** (o)
- **NECESSITY** (r): `1/2/3`
  - `1` = unnecessary and does not align with goals (e.g., McDonald's)
  - `2` = unnecessary but aligns with goals or can be otherwise justified (e.g., home improvement, self-improvement, gifts, hobbies)
  - `3` = necessary (e.g., rent, gas, groceries)
- **OWE ZZ** (o): negative for ZZ owe Chris
- **SETTLED** (o): `0/1`

For income (IN) only, `DATE` and `AMOUNT` are required.

## Examples

- `2024-09-01 ; OUT ; 54.66 ; GRC ; ; 3`
- `2024-09-01 ; OUT ; 102.55 ; PET ; Dog food for coli ; 3 ; 102.55 ; 0`
- `2024-09-01 ; IN ; 5000 ; ; UWO income`

## Categories

- **GRC** - Groceries
- **DNG** - Dining
- **ENT** - Entertainment/Leisure
- **HOS** - Housing (rent, utilities, insurance, interest portion of mortgage, property tax)
- **SRV** - Services (phone, internet, etc.)
- **HOM** - Home Improvement, household supplies
- **TRP** - Transportation (gas, repair, insurance)
- **PET** - Pets
- **CLT** - Clothing
- **HLT** - Health
- **GFT** - Gifts
- **SLF** - Self Improvement (education, gym)
- **MSC** - Miscellaneous
- **INC** - Income
- **SAV** - Savings
- **ASS** - Assets (principal portion of mortgage)

