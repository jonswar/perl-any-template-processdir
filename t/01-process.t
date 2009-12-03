#!perl -w
use Any::Template::ProcessDir;
use Cwd qw(realpath);
use File::Copy::Recursive qw(dircopy);
use File::Slurp;
use File::Temp qw(tempdir);
use Test::More tests => 8;

my $root_dir =
  tempdir( 'template-any-processdir-XXXX', TMPDIR => 1, CLEANUP => 1 );
my $source_dir = "$root_dir/source";
dircopy( "t/source", $source_dir );
my $dest_dir = "$root_dir/dest";

my $pd = Any::Template::ProcessDir->new(
    source_dir   => $source_dir,
    dest_dir     => $dest_dir,
    process_text => sub { return uc( $_[0] ) }
);
$pd->process_dir();

is( read_file("$dest_dir/foo"),     "THIS IS FOO.SRC\n",     "foo.src" );
is( read_file("$dest_dir/bar/baz"), "THIS IS BAR/BAZ.SRC\n", "bar/baz.src" );

is( read_file("$dest_dir/fop.txt"), "this is fop.txt\n", "fop.txt" );
is( read_file("$dest_dir/bar/bap.txt"), "this is bar/bap.txt\n",
    "bar/bap.txt" );

is( scalar( find_wanted( sub { -f }, $dest_dir ) ), 4, "4 files generated" );

unlink( "$source_dir/foo", "$source_dir/bar/bap.txt" );
write_file( "$dest_dir/bar/baz", "overwrote" );
$pd->process_dir();

is( read_file("$dest_dir/bar/baz"), "OVERWROTE\n",       "bar/baz.src" );
is( read_file("$dest_dir/fop.txt"), "this is fop.txt\n", "fop.txt" );

is( scalar( find_wanted( sub { -f }, $dest_dir ) ), 2, "2 files generated" );
