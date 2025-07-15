package Froogle::Constants;

use strict;
use warnings;

use Exporter;
use Froogle::Utils::File;
use Froogle::ErrorHandler;

use constant ENVIRONMENT => ($ENV{FROOGLE_ENV} // 'development');

use constant DATA_FILE_PATH => (ENVIRONMENT eq 'development') ? path_from_project_root('test/data.txt') : ($ENV{BUDGET_DATA_FILE_PATH}) ;

Froogle::ErrorHandler::raise('NO_DATA_FILE') unless DATA_FILE_PATH && -e DATA_FILE_PATH;

use constant COMMAND_DIRECTORY => path_from_application_root('Commands');

use constant FILE_KEY_MAPPING => qw(date type amount category desc necessity owe_zz settled);

use constant OUT_CATEGORY_CODES => {
    'GRC' => 'Groceries',
    'DNG' => 'Dining',
    'ENT' => 'Entertainment/Leisure',
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

use constant ASS_CATEGORY_CODES => {
    'EQT' => 'Equities',
    'RLS' => 'Real Estate',
    'OTH' => 'Other'
};

use constant COMBINED_CATEGORY_CODES => {
    %{+OUT_CATEGORY_CODES},
    %{+IN_CATEGORY_CODES},
    %{+ASS_CATEGORY_CODES},
};

use constant NECESSITY_CODES => {
    "1" => "Frivolous",
    "2" => "Unnecessary", 
    "3" => "Necessary"
};

our @EXPORT_OK = qw(DATA_FILE_PATH FILE_KEY_MAPPING OUT_CATEGORY_CODES IN_CATEGORY_CODES ASS_CATEGORY_CODES COMBINED_CATEGORY_CODES NECESSITY_CODES);

1;
