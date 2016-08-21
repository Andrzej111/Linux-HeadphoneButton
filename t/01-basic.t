use v6;
use Test;
use-ok 'Linux::HeadphoneButton';
use Linux::HeadphoneButton;
subtest {
    is Linux::HeadphoneButton::run( :kill-after<3>) , 0;
}, "Basic func ok";
done-testing;
