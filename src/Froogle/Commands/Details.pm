package Froogle::Commands::Details;

use strict;
use warnings;

use Exporter 'import';

use Froogle::Utils::Data ();
use Froogle::Utils::Date ();
use Froogle::Constants ();
use Froogle::Output::Details ();

sub name {
    return "details";
}

sub applicable_options {
    return qw(from to necessity category);
}

sub applicable_transaction_types {
    return (Froogle::Constants::TRANSACTION_TYPE_EXPENSE());
}

sub defaults {
    return (
        to => Froogle::Utils::Date::get_today(),
        from => Froogle::Utils::Date::get_start_of_month()
    );
}

sub run {
    my ($class, $options) = @_;
    my @transactions = Froogle::Utils::Data::get_transactions(
        types => [applicable_transaction_types()],
        from => $options->{from},
        to => $options->{to},
        necessity => $options->{necessity},
        category => $options->{category},
    );

    Froogle::Output::Details::print_report(
        from => $options->{from},
        to => $options->{to},
        transactions => \@transactions,
    );
}

our @EXPORT_OK = qw(name run);

1;
