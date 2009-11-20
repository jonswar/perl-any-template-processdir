use inc::Module::Install;

name 'Template-Any-ProcessDir';
abstract 'Process a directory of templates';
all_from 'lib/Template/Any/ProcessDir.pm';
author 'Jonathan Swartz <swartz@pobox.com>';

perl_version '5.006';

build_requires 'Test::Class' => 0;
build_requires 'Test::Most'  => 0;

# requires 'List::MoreUtils'           => '0.13';

license 'perl';

auto_install;

WriteAll;
