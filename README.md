# froogle
Analytics for personal finances

## Usage ##

set ENV variable `FROOGLE_DATA_FILE_PATH` to a text file that adheres to the below format

optionally set `FROOGLE_USER_PRIMARY` and `FROOGLE_USER_SECONDARY` to the two names used for shared expenses (defaults: `Chris` and `ZZ`)

run `froogle help` to view options

## Data Format

One transaction per line, fields separated by `;` (spaces around the separators are optional, blank lines are ignored):

**DATE** ; **TYPE** ; **AMOUNT** ; **CATEGORY** ; **DETAILS** ; **NECESSITY** ; **OWE ZZ** ; **SETTLED**

`IN` and `TRF` lines only have the first five fields. **NECESSITY**, **OWE ZZ** and **SETTLED** are for `OUT` lines.

## Fields

- **DATE** (r): `YYYY-MM-DD`
- **TYPE** (r): `IN` (income), `OUT` (expense) or `TRF` (transfer)
- **AMOUNT** (r): a number, 0 or more, e.g. `54.66`
- **CATEGORY** (r): a category code for the line's type, see below
- **DETAILS** (o): free text; if empty, `list` and `zz` show the category name instead and `details` omits the description
- **NECESSITY** (r for `OUT`): `1/2/3`, shown in reports as frivolous, unnecessary and necessary
  - `1` = unnecessary and does not align with goals (e.g., McDonald's)
  - `2` = unnecessary but aligns with goals or can be otherwise justified (e.g., home improvement, self-improvement, gifts, hobbies)
  - `3` = necessary (e.g., rent, gas, groceries)
- **OWE ZZ** (o): positive for Chris owes ZZ, negative for ZZ owes Chris -- keywords HALF or -HALF can be used to indicate 50% split -- note that 50% split means 100% of the value in AMOUNT is owed, as AMOUNT only considers what was paid myself
- **SETTLED**: `0/1`, required when **OWE ZZ** is set, empty otherwise

## Examples

- `2024-09-01 ; OUT ; 54.66 ; GRC ; ; 3`
- `2024-09-01 ; OUT ; 102.55 ; PET ; Dog food for coli ; 3 ; 102.55 ; 0`
- `2024-09-02 ; OUT ; 40.00 ; DNG ; Dinner ; 2 ; HALF ; 0`
- `2024-09-01 ; IN ; 5000 ; SAL ; UWO income`
- `2024-09-03 ; TRF ; 1200 ; PAS ; Mortgage principal`

## Categories

Expenses (`OUT`):

- **GRC** - Groceries
- **DNG** - Dining
- **REC** - Recreation/Entertainment/Leisure
- **HOS** - Housing (rent, utilities, insurance, interest portion of mortgage, property tax)
- **SRV** - Services (phone, internet, etc.)
- **HOM** - Home (home improvement, household supplies, decor)
- **TRP** - Transportation (gas, repair, insurance)
- **PET** - Pets
- **CLT** - Clothing
- **HLT** - Health (includes medicine, self care)
- **GFT** - Gifts
- **SLF** - Self Improvement (education, gym)
- **TOY** - Toys/Hobbies (music gear, headphones, frisbee etc)
- **OTH** - Other

Income (`IN`):

- **SAL** - Salary
- **BON** - Bonus
- **SAV** - Savings
- **GFT** - Gifts
- **OTH** - Other

Transfers (`TRF`):

- **PAS** - Purchase Asset (e.g., principal portion of mortgage)
- **SAS** - Sell Asset

## Compile to binary

[PAR::Packer](https://metacpan.org/pod/pp) can be used to bundle the source files into a portable exectuable.

A wrapper script to simplify this process is found in `bin/bundle`.
