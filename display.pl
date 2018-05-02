#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Image::Magick;
use Switch::Plain;
use Term::ANSIColor;
use File::Util;

my ($img_path, $text_path, $offset) = @ARGV;
my $image = Image::Magick->new;
my $x = $image->Read($img_path);
my $f = File::Util->new;
my $text = $f->load_file($text_path);
my @lines = split /\n/, $text;
$offset = 10 if !$offset;

my $h = $image->Get('height');
my $w = $image->Get('width');

sub color_lookup {
    my (@pixel) = @_;
    my $color = int($pixel[0]*256);
    #sswitch ($color) {
    #    case '0': {return $p.'black'}
    #    case '129': {return $p.'blue'}
    #    case '138': {return $p.'cyan'}
    #    case '204': {return $p.'red'}
    #    case '178': {return $p.'magenta'}
    #    case '181': {return $p.'green'}
    #    case '240': {return $p.'yellow'}
    #    default : { say $color; return $p.'black'}
    #}
    
    if ($color == 0) {return 'reset'}
    if ($color <= 129) {return 'blue'}
    if ($color <= 138) {return 'cyan'}
    if ($color <= 178) {return 'magenta'}
    if ($color <= 181) {return 'green'}
    if ($color <= 204) {return 'red'}
    if ($color <= 240) {return 'yellow'}
    return 'reset';
}
my $l = -1 * int(($h/2 - scalar(@lines)) /2);
$l-- if scalar(@lines)%2;

for (my $y=0; $y<$h; $y=$y+2) {
    my $row = "";
    for (my $x=0; $x<$w; $x++) {
        my $row1 = color_lookup($image->GetPixel(x=>$x, y=>$y));
        my $row2 = color_lookup($image->GetPixel(x=>$x, y=>$y+1));
        $row .= colored("x", "$row1 on_$row2") if $row1 ne 'reset' && $row2 ne 'reset';
        $row .= colored("y", "reset $row2") if $row1 eq 'reset' && $row2 ne 'reset';
        $row .= colored("x", "reset on_black $row1") if $row1 ne 'reset' && $row2 eq 'reset';
        $row .= colored(" ", "$row1") if $row1 eq 'reset' && $row2 eq 'reset';
        #since colored has problems with unicode:
        $row =~ s/x/▀/;
        $row =~ s/y/▄/;
    }
    $row .= color('reset');
    $row .= " "x$offset . $lines[$l] if $l > -1 && exists $lines[$l];
    say $row;
    $l++;
}
