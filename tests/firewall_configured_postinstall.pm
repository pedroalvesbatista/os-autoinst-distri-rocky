use base "installedtest";
use strict;
use testapi;

sub run {
    my $self=shift;
    if (not( check_screen "root_console", 0)) {
        $self->root_console(tty=>3);
    }
    # this only succeeds if the firewall is running
    assert_script_run 'firewall-cmd --state';
    # these succeed if the specified service/port is allowed
    assert_script_run 'firewall-cmd --query-service ftp';
    assert_script_run 'firewall-cmd --query-port imap/tcp';
    assert_script_run 'firewall-cmd --query-port 1234/udp';
    assert_script_run 'firewall-cmd --query-port 47/tcp';
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
