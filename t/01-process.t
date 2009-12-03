#!perl -w
use Any::Template::ProcessDir;
use Cwd qw(realpath);
use File::Basename;
use File::Copy::Recursive qw(dircopy);
use File::Find::Wanted;
use File::Slurp;
use File::Temp qw(tempdir);
use Test::More tests => 10;

my $root_dir =
  tempdir( 'template-any-processdir-XXXX', TMPDIR => 1, CLEANUP => 1 );
my $source_dir = "$root_dir/source";
dircopy( "t/source", $source_dir );
my $dest_dir = "$root_dir/dest";

my $pd = Any::Template::ProcessDir->new(
    source_dir   => $source_dir,
    dest_dir     => $dest_dir,
    ignore_files => sub { basename( $_[0] ) =~ qr/^\./ },
    process_text => sub { return uc( $_[0] ) }
);
$pd->process_dir();

is( read_file("$dest_dir/foo"),     "THIS IS FOO.SRC\n",     "foo.src" );
is( read_file("$dest_dir/bar/baz"), "THIS IS BAR/BAZ.SRC\n", "bar/baz.src" );
is( read_file("$dest_dir/fop.txt"), "this is fop.txt\n",     "fop.txt" );
is( read_file("$dest_dir/bar/bap.txt"), "this is bar/bap.txt\n",
    "bar/bap.txt" );
ok( -f "$dest_dir/README", "README" );

my @dest_files = dest_files();
is( scalar(@dest_files), 5, "5 files generated" );

unlink( "$source_dir/foo.src", "$source_dir/bar/bap.txt" );
write_file( "$source_dir/bar/baz.src", "overwrote\n" );
$pd->process_dir();

is( read_file("$dest_dir/bar/baz"), "OVERWROTE\n",       "bar/baz.src" );
is( read_file("$dest_dir/fop.txt"), "this is fop.txt\n", "fop.txt" );
ok( -f "$dest_dir/README", "README" );

@dest_files = dest_files();
is( scalar(@dest_files), 3, "3 files generated" );

sub dest_files {
    return find_wanted( sub { -f }, $dest_dir );
}
