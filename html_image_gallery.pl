#!/usr/bin/perl
# make sure, that the path of perl is right (try: which perl)

##################################################################################
#
# html_image_gallery: A simple HTML image gallery generator
#
# Copyright (C) 2017  Harald Schütt

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# History:
#   V1.0 Mar 2017 by Harald Schütt
		
# Usage:
#   Copy this script into the directory with your photos/images or in
#   your directory for executables (e.g. ~/bin). Change to the directory
#   with the photos/images and run the script.
# . The script will generate the file index.html (the image gallery).
   

# Enjoy,
# Harald Schütt
#
##################################################################################

use strict;
use warnings;

use POSIX 'strftime';
use Getopt::Std;

sub helpusg {
print <<HELPMSG;
usage: $0 [options] [directory]

options:
    -o output file
        Name output file with this name instead of default "index.html"
    -t title
        HTML page with this heading 1 title. Default: "html_image_gallery"
    -f filetype of images for the gallery
        Specify filetypes of source files for the gallery. Default: "jpg jpeg"
        Possible suffixes: jpg jpeg gif png svg bmp tiff ...    
    -e embed as
        Specify the HTML tag for embeding the images/photos. Default: "img"
        Possible values: img object
    -b HTML background color
        Specify a background color for the image gallery. Default: "Gainsboro"
        Possible values: Color Name e.g. "Gainsboro" or HEX value e.g. "#DCDCDC"    
    -h help
        Show this text and exit
HELPMSG
exit;
}

sub get_pic_files {
  # darrenpmeyer 2012-12-03 - gets list of image files
  # based on extensions pased as a list of scalars
  # allows extenions to be any case or mixture of cases
  my @files;
  # concatenate regex and use join() to build a file suffix list
  # e.g. for the default \.(jpg|jpeg)$
  my $ok_file_re = '\.('.join('|',@_).')$';
  $ok_file_re = qr/$ok_file_re/i;
  # final regex for default (?^i:\.(jpg|jpeg)$)

  foreach (<*>) {
    next unless ( -f $_ && $_ =~ $ok_file_re );
    next if /^favicon\./;  # skips handling the favicon; a little naively

# fill array @files with push() function; add the current element $_ (Perl default variable)
    push @files, $_;
  }
  return @files;
}

my %options;

print "html_image_gallery by Harald Schütt\n";
print "This script is distributed under the terms of the GNU General Public License v2.0 or later.\n\n";

# get command line parameters, fill hash %options by reference
getopts("ho:t:f:e:b:",\%options);

# help usage function unless no options or explicit option -h
helpusg() unless (%options);
helpusg() if $options{h};

# set values from parameters or use default values
my $output      = $options{o} || "index.html";
my $title       = $options{t} || "html_image_gallery";
my $filetype    = $options{f} || "jpg jpeg";
my $embedas     = $options{e} || "img";
my $background  = $options{b} || "#DCDCDC";
my $dir = shift || ".";
chdir $dir || die "Cannot change to $dir.\n";

# possible image extensions (jpg, gif, svg, png, ...)
#- my @pics = (<*.jpg>,<*.gif>);
# darrenpmeyer: better, less naive extension handling

# get file list back from function get_pic_files()
my @pics = get_pic_files(split(' ',$filetype));

# no matching files to search pattern found?
unless (@pics) { print "Nothing to do in '$dir'\n"; exit; }

# check whether file exists or not
# if there is a correspondent file, rename it
if (-e $output) { 
  rename $output, $output.".bak"; 
  print "I saved the old $output as $output.bak\n"; 
  }

open (PAGE, ">$output") || die "Problem: Can't write to filename $output\n";

# create the index page
print PAGE qq*
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<style>
h1 {text-align:center;}
h3 {text-align:center;}
h5 {text-align:center;}
img {
    display: block;
    margin: 0 auto;
}
.page {
      display: block;
      margin: 0 auto;
      width: 80%;
}
</style>
</head>
<body bgcolor=$background>
<h1>$title</h1>
*;
@pics = sort { ( $a =~ /(\d+)/ )[0] <=> ( $b =~ /(\d+)/ )[0] } @pics;

foreach $_ (@pics) {
  print "$_\n";

# embed image/photo as?
  if($embedas eq 'img') {
            print PAGE qq*<img src="$_" alt="$_" width="80%"><br>\n*;
            }
  elsif($embedas eq 'object') {
            print PAGE qq*<object type="image/svg+xml" data="$_" class="page"></object><br>\n*;
            }
  else { print PAGE qq*<img src="$_" alt="$_" width="80%"><br>\n*; }
}
my $ts = strftime('%a %d. %b %Y %H:%M %Z', localtime);
print PAGE qq*<h3>created at: $ts</h3>\n*;
print PAGE qq*<h5>by $0</h5>\n*;
print PAGE qq*</body></html>*;

close PAGE;
