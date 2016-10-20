package packagetest;

use strict;

use base 'Exporter';
use Exporter;

use testapi;
our @EXPORT = qw/prepare_test_packages verify_installed_packages verify_updated_packages/;

# enable the openqa test package repositories and install the main
# test packages, remove python3-kickstart and install the fake one
sub prepare_test_packages {
    # remove python3-kickstart if installed (we don't use assert
    # here in case it's not)
    script_run 'dnf -y remove python3-kickstart', 180;
    # we seem to often lose keystrokes in the next command if we run
    # it too fast, let's wait for idle first
    wait_idle 20;
    # grab the test repo definitions
    assert_script_run 'curl -o /etc/yum.repos.d/openqa-testrepo-1.repo https://fedorapeople.org/groups/qa/openqa-repos/openqa-testrepo-1.repo';
    # install the test packages from repo1
    assert_script_run 'dnf -y --disablerepo=* --enablerepo=openqa-testrepo-1 install python3-kickstart';
}

# check our test packages installed correctly (this is a test that dnf
# actually does what it claims)
sub verify_installed_packages {
    validate_script_output 'rpm -q python3-kickstart', sub { $_ =~ m/^python3-kickstart-1.1.noarch$/ };
    assert_script_run 'rpm -V python3-kickstart';
}

# check updating the test packages and the fake python3-kickstart work
# as expected
sub verify_updated_packages {
    # we don't know what version of python3-kickstart we'll actually
    # get, so just check it's *not* the fake one
    validate_script_output 'rpm -q python3-kickstart', sub { $_ !~ m/^python3-kickstart-1-1.noarch$/ };
    assert_script_run 'rpm -V python3-kickstart';
}
