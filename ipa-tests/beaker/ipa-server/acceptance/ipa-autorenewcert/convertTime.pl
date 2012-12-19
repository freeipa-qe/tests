#!/usr/bin/perl
our $seconds=$ARGV[0]+0; 
if ($seconds lt 0 ){
    print "-1";
}else{
    $string=convert_time($seconds);
    print "$string";
}

sub convert_time { 
    # this function is from: http://neilang.com/entries/converting-seconds-into-a-readable-format-in-perl/
    # my change: add years
    my $time = shift; 
    my $prefix="";
    my $suffix="";

    my $years = int($time / (86400*365) ); 
    $time -= ($years * 86400 * 365); 
    my $days = int($time / 86400); 
    $time -= ($days * 86400); 
    my $hours = int($time / 3600); 
    $time -= ($hours * 3600); 
    my $minutes = int($time / 60); 
    my $seconds = $time % 60; 
  
    $years = $years < 1 ? '' : $years .' Year '; 
    $days = $days < 1 ? '' : $days .' Day(s) '; 
    $hours = $hours < 1 ? '' : $hours .' h '; 
    $minutes = $minutes < 1 ? '' : $minutes . ' m '; 
    $time = $prefix.$years. $days . $hours . $minutes . $seconds . ' s'. $suffix; 
    return $time; 
}

