# froogle
Analytics for personal finances

## Usage ##

set ENV variable `BUDGET_DATA_FILE_PATH` to a text file that adheres to the below format

run `froogle help` to view options

## Data Format

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
- **OWE ZZ** (o): negative for ZZ owe Chris -- keywords HALF or -HALF can be used to indicate 50% split -- note that 50% split means 100% of the value in AMOUNT is owed, as AMOUNT only considers what was paid myself
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
- **HOM** - Home Improvement, household supplies, decor
- **TRP** - Transportation (gas, repair, insurance)
- **PET** - Pets
- **CLT** - Clothing
- **HLT** - Health (includes self care)
- **GFT** - Gifts
- **SLF** - Self Improvement (education, gym)
- **TOY** - Toys, hobbies (music gear, headphones, frisbee etc)
- **MSC** - Miscellaneous
- **INC** - Income
- **SAV** - Savings
- **ASS** - Assets (principal portion of mortgage)

## Compile to binary

[PAR::Packer](https://metacpan.org/pod/pp) can be used to bundle the source files into a portable exectuable.

A wrapper script to simplify this process is found in `bin/bundle`.
