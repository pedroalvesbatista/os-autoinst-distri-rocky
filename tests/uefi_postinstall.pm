use base "installedtest";
use strict;
use testapi;

sub run {
    my $self=shift;
    if (not( check_screen "root_console", 0)) {
        $self->root_console(tty=>3);
    }
    assert_screen "root_console";
    # this test shows if the system is booted with efi
    type_string 'reset; [ -d /sys/firmware/efi/ ]; echo $?';
    send_key "ret";
    assert_screen "console_command_success";
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
