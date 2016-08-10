use base "installedtest";
use strict;
use testapi;
use freeipa;

sub run {
    my $self = shift;
    $self->console_login(user=>'root');
    # clear browser data so we don't go back to the 'admin' login
    assert_script_run 'rm -rf /root/.mozilla';
    type_string "startx /usr/bin/firefox\n";
    assert_screen "firefox";
    start_webui("test1", "batterystaple");
    assert_and_click "freeipa_webui_actions";
    assert_and_click "freeipa_webui_reset_password_link";
    wait_still_screen 3;
    type_string "batterystaple";
    wait_still_screen 1;
    send_key "tab";
    send_key "tab";
    wait_still_screen 1;
    type_string "loremipsum";
    wait_still_screen 1;
    send_key "tab";
    wait_still_screen 1;
    type_string "loremipsum";
    wait_still_screen 1;
    assert_and_click "freeipa_webui_reset_password_button";
    wait_still_screen 2;
    # log out
    assert_and_click "freeipa_webui_user_menu";
    assert_and_click "freeipa_webui_logout";
    wait_still_screen 3;
    # close browser, back to console
    send_key "ctrl-q";
    # we don't get back to a prompt instantly and keystrokes while X
    # is still shutting down are swallowed, so wait_still_screen before
    # finishing (and handing off to freeipa_client_postinstall)
    wait_still_screen 5;
    # check we can kinit with changed password
    assert_script_run 'printf "loremipsum" | kinit test1';
    # change password via CLI (back to batterystaple, as that's what
    # freeipa_client test expects)
    assert_script_run 'dnf -y --nogpgcheck install freeipa-admintools';
    assert_script_run 'printf "batterystaple\nbatterystaple" | ipa user-mod test1 --password';
    # check we can kinit again
    assert_script_run 'printf "batterystaple" | kinit test1';
    # we just stay here - freeipa_client will pick right up
}

sub test_flags {
    # without anything - rollback to 'lastgood' snapshot if failed
    # 'fatal' - whole test suite is in danger if this fails
    # 'milestone' - after this test succeeds, update 'lastgood'
    # 'important' - if this fails, set the overall state to 'fail'
    return {};
}

1;
