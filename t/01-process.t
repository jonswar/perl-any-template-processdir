#!perl -w
use Test::More tests => 1;
use Any::Template::ProcessDir;
use File::Temp qw(tempdir);
use Cwd qw(realpath);

my $source_dir = realpath("t/source");
my $dest_dir =
  tempdir( 'template-any-processdir-XXXX', TMPDIR => 1, CLEANUP => 1 );

my $pd = Any::Template::ProcessDir->new(
    source_dir   => '/path/to/source/dir',
    dest_dir     => '/path/to/dest/dir',
    process_text => sub {
        my $template = Any::Template->new( Backend => '...', String => $_[0] );
        $template->process( {...} );
    }
);
$pd->process_dir();
