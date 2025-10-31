package Froogle::Constants;

use strict;
use warnings;

use Exporter 'import';
use Froogle::Utils::File ();
use Froogle::UserErrorHandler ();

use constant ENVIRONMENT => ($ENV{FROOGLE_ENV} // 'development');

use constant DATA_FILE_PATH => (ENVIRONMENT eq 'development') ? Froogle::Utils::File::path_from_project_root('test/data.txt') : ($ENV{FROOGLE_DATA_FILE_PATH}) ;

Froogle::UserErrorHandler::raise('NO_DATA_FILE') unless DATA_FILE_PATH && -e DATA_FILE_PATH;

use constant COMMAND_DIRECTORY => Froogle::Utils::File::path_from_application_root('Commands');

use constant FILE_KEY_MAPPING => qw(date type amount category desc necessity owe_zz settled);

use constant DEFAULT_COMMAND => 'overview';

# Transaction Types
use constant TRANSACTION_TYPE_INCOME => 'IN';
use constant TRANSACTION_TYPE_EXPENSE => 'OUT';
use constant TRANSACTION_TYPE_TRANSFER => 'TRF';

# Necessity Levels
use constant NECESSITY_FRIVOLOUS => '1';
use constant NECESSITY_UNNECESSARY => '2';
use constant NECESSITY_NECESSARY => '3';

# Special Values
use constant SPECIAL_VALUE_HALF => 'HALF';
use constant SPECIAL_VALUE_NEGATIVE_HALF => '-HALF';

# Category Codes for Transfers
use constant CATEGORY_PURCHASE_ASSET => 'PAS';
use constant CATEGORY_SELL_ASSET => 'SAS';

# Formatting Constants
use constant CURRENCY_FORMAT_WIDTH => 10;
use constant CATEGORY_TEXT_WIDTH => 36;
use constant DESCRIPTION_TEXT_WIDTH => 30;
use constant SEPARATOR_LENGTH_STANDARD => 60;
use constant SEPARATOR_LENGTH_CATEGORIES => 98;

# Field Indices (for parsing transaction lines)
use constant FIELD_INDEX_DATE => 0;
use constant FIELD_INDEX_TYPE => 1;
use constant FIELD_INDEX_AMOUNT => 2;
use constant FIELD_INDEX_CATEGORY => 3;
use constant FIELD_INDEX_DESC => 4;
use constant FIELD_INDEX_NECESSITY => 5;
use constant FIELD_INDEX_OWE_ZZ => 6;
use constant FIELD_INDEX_SETTLED => 7;

# User Names (configurable via environment)
use constant USER_NAME_PRIMARY => ($ENV{FROOGLE_USER_PRIMARY} // 'Chris');
use constant USER_NAME_SECONDARY => ($ENV{FROOGLE_USER_SECONDARY} // 'ZZ');

use constant OUT_CATEGORY_CODES => {
    'GRC' => 'Groceries',
    'DNG' => 'Dining',
    'REC' => 'Recreation/Entertainment/Leisure',
    'HOS' => 'Housing',
    'SRV' => 'Services',
    'HOM' => 'Home',
    'TRP' => 'Transportation',
    'PET' => 'Pets',
    'CLT' => 'Clothing',
    'HLT' => 'Health',
    'GFT' => 'Gifts',
    'SLF' => 'Self Improvement',
    'TOY' => 'Toys/Hobbies',
    'OTH' => 'Other',
};

use constant IN_CATEGORY_CODES => {
    'SAL' => 'Salary',
    'BON' => 'Bonus',
    'SAV' => 'Savings',
    'GFT' => 'Gifts',
    'OTH' => 'Other',
};

use constant TRF_CATEGORY_CODES => {
    'PAS' => 'Purchase Asset',
    'SAS' => 'Sell Asset',
};

use constant COMBINED_CATEGORY_CODES => {
    %{+OUT_CATEGORY_CODES},
    %{+IN_CATEGORY_CODES},
    %{+TRF_CATEGORY_CODES},
};

use constant NECESSITY_CODES => {
    "1" => "Frivolous",
    "2" => "Unnecessary", 
    "3" => "Necessary"
};

our @EXPORT_OK = qw(
    DATA_FILE_PATH
    FILE_KEY_MAPPING
    OUT_CATEGORY_CODES
    IN_CATEGORY_CODES
    TRF_CATEGORY_CODES
    COMBINED_CATEGORY_CODES
    NECESSITY_CODES
    ENVIRONMENT
    TRANSACTION_TYPE_INCOME
    TRANSACTION_TYPE_EXPENSE
    TRANSACTION_TYPE_TRANSFER
    NECESSITY_FRIVOLOUS
    NECESSITY_UNNECESSARY
    NECESSITY_NECESSARY
    SPECIAL_VALUE_HALF
    SPECIAL_VALUE_NEGATIVE_HALF
    CATEGORY_PURCHASE_ASSET
    CATEGORY_SELL_ASSET
    CURRENCY_FORMAT_WIDTH
    CATEGORY_TEXT_WIDTH
    DESCRIPTION_TEXT_WIDTH
    SEPARATOR_LENGTH_STANDARD
    SEPARATOR_LENGTH_CATEGORIES
    FIELD_INDEX_DATE
    FIELD_INDEX_TYPE
    FIELD_INDEX_AMOUNT
    FIELD_INDEX_CATEGORY
    FIELD_INDEX_DESC
    FIELD_INDEX_NECESSITY
    FIELD_INDEX_OWE_ZZ
    FIELD_INDEX_SETTLED
    USER_NAME_PRIMARY
    USER_NAME_SECONDARY
);

1;
