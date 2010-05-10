use inc::Module::Install;

name     'brause';
all_from 'lib/Brause.pm';
author   q{Lenz Gschwendtner <norbu09@cpan.org>};
license  'perl';

build_requires 'Test::More';

requires 'common::sense';
requires 'Config::General';
requires 'Getopt::Long';
requires 'IO::Socket::SSL';
requires 'Pod::Usage';
requires 'Template::Alloy';
requires 'XML::Twig';
requires 'Mojo';

auto_install;

WriteAll;

