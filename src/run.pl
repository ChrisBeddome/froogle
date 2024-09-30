use warnings;
use strict;

# Add the directory of the current file to @INC
use Cwd;
use File::Basename;
use lib Cwd::abs_path(dirname(__FILE__));

use Froogle::Main;

Froogle::Main::run();

