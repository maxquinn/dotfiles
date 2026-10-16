#!/usr/bin/perl
# Rejoin lines that a program hard-wrapped to the pane's width, so text
# captured from a narrow pane reads normally in a wide editor. Used by
# scrollback.sh as a filter: scrollback-reflow.pl <columns> < in > out
#
# A break counts as a wrap when the next line's first word wouldn't have fit
# on the line before it. Blank lines, list items, box drawing, and lines that
# step out to a smaller indent are never joined.

use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

my $width = shift or die "usage: $0 <columns>\n";
my $slack = 4; # some programs wrap a few columns short of the edge

my $box  = qr/[\x{2500}-\x{257F}]/;
my $item = qr/^\s*(?:[-*+>•●○◦▪⎿]|\d+[.)])\s/;

sub indent { $_[0] =~ /^(\s*)/; length $1 }

sub wrapped {
  my ($prev, $next) = @_;
  return 0 if $prev !~ /\S/ || $next !~ /\S/;
  # Wider than the pane: already one line, rejoined by rex capture --unwrap
  return 0 if length($prev) > $width;
  return 0 if $prev =~ $box || $next =~ $box || $next =~ $item;
  return 0 if indent($next) < indent($prev);
  my ($word) = $next =~ /^\s*(\S+)/;
  return length($prev) + 1 + length($word) > $width - $slack;
}

my ($out, $prev);
while (my $line = <STDIN>) {
  chomp $line;
  if (defined $prev && wrapped($prev, $line)) {
    $out .= ' ' . ($line =~ s/^\s+//r);
  } else {
    print "$out\n" if defined $out;
    $out = $line;
  }
  $prev = $line;
}
print "$out\n" if defined $out;
