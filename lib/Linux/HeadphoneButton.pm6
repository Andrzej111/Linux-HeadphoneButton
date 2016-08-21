use v6;
unit class Linux::HeadphoneButton;
use Config::From 'config.json';

my $timer;
my $forbidden = Promise.in(0); # init with kept promise
my $click-counter;


my $CLICK-INTERVAL is from-config;
my %ACTIONS is from-config;
my $FORBIDDEN-INTERVAL = 2;
my $clicks-sequence = "";
my $MAX-N-CLICKS = 3;

sub fire-action {
    say $clicks-sequence;
    my $action = %ACTIONS{$clicks-sequence};
    $clicks-sequence = "";
    shell($action) given $action;
    say "OK";
}

sub possible-outcomes {
    [+] %ACTIONS.keys >>~~>> /$clicks-sequence/;
}
sub single-click {
    $clicks-sequence ~= "S";
    if possible-outcomes>1 {
        $click-counter = Promise.in($CLICK-INTERVAL);
        $click-counter.then({fire-action});
    } else {
        fire-action;
    }
}

sub long-click {
    $clicks-sequence ~= "L";
    if possible-outcomes>1 {
        $click-counter = Promise.in($CLICK-INTERVAL);
        $click-counter.then({fire-action});
    } else {
        fire-action;
    }
}

sub plugged {
    return if state-forbidden();
    say $timer.status.perl;
    if $timer.status eq "Planned" {
        single-click;
    } else {
        long-click;
    }
}
sub unplugged {
    $timer = Promise.in($CLICK-INTERVAL);
}

# frobidden state 2 seconds after plugging headphones in/out
# prevent whole headset unplugging -> plugging triggering click
sub state-forbidden {
    return $forbidden.status eq "Planned";
}
sub h_plugged {
    $clicks-sequence = "";
    $forbidden = Promise.in($FORBIDDEN-INTERVAL);
}
sub h_unplugged {
    $clicks-sequence = "";
    $forbidden = Promise.in($FORBIDDEN-INTERVAL);
}

our sub run( :$kill-after ) {
    my $listener = Proc::Async.new('acpi_listen');
    with $kill-after {
        start {
            Promise.in($kill-after).then({$listener.kill;});
        }
    }
    $listener.stdout.tap({ start {plugged()} if /<<plug>>/ and /MICROPHONE/ });
    $listener.stdout.tap({ start {unplugged()} if /<<unplug>>/ and /MICROPHONE/ });

    $listener.stdout.tap({ start {h_plugged()} if /<<plug>>/ and /HEADPHONE/ });
    $listener.stdout.tap({ start {h_unplugged()} if /<<unplug>>/ and /HEADPHONE/ });
    say "Starting...";
    my $promise = $listener.start;

    await $promise;
    say "Done.";
    return 0;
}

=begin pod

=head1 NAME

Linux::HeadphoneButton - fires commands when headphone microphone button is pressed

=head1 SYNOPSIS

  #config.json
  { 
  "CLICK-INTERVAL" : "1",
  "ACTIONS" : {
      "S" : "command to run when short clicked", 
      "SS" : "double short click",
      "L" : "run when long click"
      "LSL" : "long-short-long sequence"
      //...
      }
  }

  perl6 -Ilib/ bin/main.p6& disown
  
=head1 DESCRIPTION

Linux::HeadphoneButton listens with C<acpi_listen> for mic unplug - plug events
Creates sequence and runs command defined in config.json file

=head1 AUTHOR

Paweł Szulc <pawel_szulc@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
