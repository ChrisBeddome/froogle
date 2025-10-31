package Froogle::Constants;

use strict;
use warnings;

use Exporter 'import';
use Froogle::Utils::File ();
use Froogle::UserErrorHandler ();

use constant ENVIRONMENT => ($ENV{FROOGLE_ENV} // 'development');

use constant DATA_FILE_PATH => (ENVIRONMENT eq 'development') ? Froogle::Utils::File::path_from_project_root('test/data.txt') : ($ENV{BUDGET_DATA_FILE_PATH}) ;

Froogle::UserErrorHandler::raise('NO_DATA_FILE') unless DATA_FILE_PATH && -e DATA_FILE_PATH;

use constant COMMAND_DIRECTORY => Froogle::Utils::File::path_from_application_root('Commands');

use constant FILE_KEY_MAPPING => qw(date type amount category desc necessity owe_zz settled);

use constant DEFAULT_COMMAND => 'overview';

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

our @EXPORT_OK = qw(DATA_FILE_PATH FILE_KEY_MAPPING OUT_CATEGORY_CODES IN_CATEGORY_CODES TRF_CATEGORY_CODES COMBINED_CATEGORY_CODES NECESSITY_CODES ENVIRONMENT);

1;
