package Froogle::Output::Overview;

use strict;
use warnings;

use feature 'say';
use Exporter 'import';

use Froogle::Constants ();
use Froogle::Output::Format ();

sub print_report {
    my %report = @_;
    my $width = Froogle::Constants::CURRENCY_FORMAT_WIDTH();

    say "";
    say Froogle::Output::Format::formatted_date_range($report{from}, $report{to});
    say "";
    say "Total Income:                   " . Froogle::Output::Format::format_currency($report{income}, $width);
    say "";
    say "Purchase Assets:                " . Froogle::Output::Format::format_currency($report{purchase_assets}, $width);
    say "Sell Assets:                    " . Froogle::Output::Format::format_currency($report{sell_assets}, $width);
    say "Net Transfers:                  " . Froogle::Output::Format::format_currency($report{net_transfers}, $width);
    say "";
    say "Necessary spending:             " . Froogle::Output::Format::format_currency($report{necessary_spending}, $width);
    say "Unnecessary spending:           " . Froogle::Output::Format::format_currency($report{unnecessary_spending}, $width);
    say "Frivolous spending:             " . Froogle::Output::Format::format_currency($report{frivolous_spending}, $width);
    say "Total Spending:                 " . Froogle::Output::Format::format_currency($report{total_spending}, $width);
    say "";
    say "Net                             " . Froogle::Output::Format::format_currency($report{net}, $width);
    say "";
}

our @EXPORT_OK = qw(print_report);

1;
