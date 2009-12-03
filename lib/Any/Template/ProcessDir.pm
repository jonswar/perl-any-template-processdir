package Any::Template::ProcessDir;
use 5.006;
use File::Basename;
use File::Find::Wanted;
use File::Path qw(make_path remove_tree);
use File::Slurp qw(read_file write_file);
use File::Spec::Functions qw(catfile catdir);
use Moose;
use Moose::Util::TypeConstraints;
use strict;
use warnings;

our $VERSION = '0.02';

has 'dest_dir' => ( is => 'ro', required => 1 );
has 'dir_create_mode' => ( is => 'ro', isa => 'Int', default => oct(775) );
has 'file_create_mode' => ( is => 'ro', isa => 'Int', default => oct(444) );
has 'process_text' => ( is => 'ro', isa => 'CodeRef', required => 1 );
has 'ignore_files' => ( is => 'ro', isa => 'CodeRef', default => sub { 0 } );
has 'readme_filename'      => ( is => 'ro', default  => 'README' );
has 'source_dir'           => ( is => 'ro', required => 1 );
has 'template_file_suffix' => ( is => 'ro', default  => '.src' );

sub process_dir {
    my ($self) = @_;

    my $source_dir = $self->source_dir;
    my $dest_dir   = $self->dest_dir;
    remove_tree($dest_dir);
    die "could not remove '$dest_dir'" if -d $dest_dir;

    my $ignore_files = $self->ignore_files;
    my @source_files =
      find_wanted( sub { -f && !$ignore_files->($_) }, $source_dir );
    my $template_file_suffix = $self->template_file_suffix;

    foreach my $source_file (@source_files) {
        $self->generate_dest_file($source_file);
    }

    $self->generate_readme();
    $self->generate_source_symlink();
}

sub generate_dest_file {
    my ( $self, $source_file ) = @_;

    my $template_file_suffix = $self->template_file_suffix;
    my $template_file_regex =
      defined($template_file_suffix) ? qr/\Q$template_file_suffix\E$/ : qr/.|/;
    my $source_text = read_file($source_file);
    my $dest_text;

    substr( ( my $dest_file = $source_file ), 0, length( $self->source_dir ) ) =
      $self->dest_dir;

    if ( $source_file =~ $template_file_regex ) {
        $dest_file =
          substr( $dest_file, 0,
            -1 * length( $self->template_file_suffix || '' ) );
        $dest_text = $self->process_text->( $source_text, $self );
    }
    else {
        $dest_text = $source_text;
    }

    die "$dest_file already exists!" if -f $dest_file;

    make_path( dirname($dest_file) );
    chmod( $self->dir_create_mode(), dirname($dest_file) )
      if defined( $self->dir_create_mode() );

    write_file( $dest_file, $dest_text );
    chmod( $self->file_create_mode(), $dest_file )
      if defined( $self->file_create_mode() );
}

sub generate_readme {
    my $self = shift;

    my $readme_file = catfile( $self->dest_dir, $self->readme_filename );
    if ( defined($readme_file) ) {
        unlink($readme_file);
        write_file(
            $readme_file,
            "Files in this directory generated from "
              . $self->source_dir . ".\n",
            "Do not edit files here, as they will be overwritten. Edit the source instead!"
        );
    }
}

sub generate_source_symlink {
    my $self = shift;

    # Create symlink from dest dir back to source dir.
    #
    my $source_link = catdir( $self->dest_dir, "source" );
    unlink($source_link) if -e $source_link;
    symlink( $self->source_dir, $source_link );
}

1;

__END__

=pod

=head1 NAME

Any::Template::ProcessDir -- Process a directory of templates

=head1 SYNOPSIS

    use Any::Template::ProcessDir;

    my $pd = Any::Template::ProcessDir->new(
        source_dir   => '/path/to/source/dir',
        dest_dir     => '/path/to/dest/dir',
        process_text => sub {
            my $template = Any::Template->new( Backend => '...', String => $_[0] );
            $template->process({ ... });
        }
    );
    $pd->process_dir();
    
=head1 DESCRIPTION

Recursively processes a directory of templates, generating a parallel directory
of result files. Each file in the source directory may be template-processed,
copied, or ignored depending on its pathname.

=head1 CONSTRUCTOR

Required parameters:

=over

=item source_dir

Directory containing the template files.

=item dest_dir

Directory where you want to generate result files.

=item process_text

A code reference that takes a single argument, the template text, and returns
the result string. This can use Any::Template or another method altogether.

=back

Optional parameters:

=over

=item dir_create_mode

Permissions mode to use when creating destination directories. Defaults to
0775.

=item file_create_mode

Permissions mode to use when creating destination files. Defaults to 0444
(read-only), so that destination files are not accidentally edited.

=item ignore_files

Coderef which takes a full pathname and returns true if the file should be
ignored. By default, all files will be considered.

=item readme_filename

Name of a README file to generate in the destination directory - defaults to
"README".

=item template_file_suffix

Suffix of template files in source directory. Defaults to ".src". This will be
removed from the destination file name.

Any file in the source directory that does not have this suffix (or
L</ignore_file_suffix>) will simply be copied to the destination.

=back

=head1 METHODS

=over

=item process_dir

Process the directory. The destination directory will be removed completely and
recreated, to eliminate any old files from previous processing.

=back

=head1 AUTHOR

Jonathan Swartz

=head1 SEE ALSO

L<Any::Template>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2009 Jonathan Swartz.

Any::Template::ProcessDir is provided "as is" and without any express or
implied warranties, including, without limitation, the implied warranties of
merchantibility and fitness for a particular purpose.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
