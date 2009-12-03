use inc::Module::Install;

name 'Any-Template-ProcessDir';
abstract 'Process a directory of templates';
all_from 'lib/Any/Template/ProcessDir.pm';
author 'Jonathan Swartz <swartz@pobox.com>';

perl_version '5.006';

build_requires 'Test::More' => 0;
build_requires 'File::Copy::Recursive' => 0;

requires 'File::Find::Wanted' => 0;
requires 'File::Path' => '2.07';
requires 'File::Slurp' => 0;
requires 'File::Spec' => '3.0';
requires 'Moose' => '0.66';

license 'perl';

auto_install;

WriteAll;
