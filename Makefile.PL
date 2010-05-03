use inc::Module::Install;

name     'brause';
all_from 'lib/brause.pm';
author   q{Lenz Gschwendtner <norbu09@cpan.org>};
license  'perl';

build_requires 'Test::More';

requires 'common::sense';
requires 'Config::Tiny';
requires 'Getopt::Long';
requires 'IO::Socket::SSL';
requires 'Pod::Usage';
requires 'Test::More';
requires 'Template::Alloy';

auto_install;

WriteAll;

