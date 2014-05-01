#!/usr/bin/perl
# test line!
# tuptime - Report how long the system or other components has been running, count it between restarts.
# Copyright (C) 2013 - Ricardo F.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Time::Duration;
use Scalar::Util qw(looks_like_number);
#use diagnostics;

# Server List
my @servers = qw(server15 server16 server29);

# Directory for the variables
my $driftD = "/var/lib/tuptime/";
# Directory for the configuration file
my $confD = "/etc/tuptime/";
# Directory for stored uptime and stat files from remote servers
my $localD = "/usr/share/tuptime/";

# FILE1 asigned down to $procd/uptime
# FILE6 asigned down to $procd/stat
# File which store last value read from $procd/uptime
my (@driftD, @confD, @localD, @last_uptimeF, @sys_startsF, @total_timeF, @conf_fileF, @last_btimeF, @first_bootF) = ();
# For each server, create the path variables for tuptime
foreach (@servers) {
        push @driftD, $driftD . $_;
        push @confD, $confD . $_;
        push @localD, $localD . $_;
}
# File which store last value read from $procd/uptime
foreach (@driftD) {
        push @last_uptimeF, $_ . "/lastuptime"; # FILE2
}
# File which store the count of system starts
foreach (@driftD) {
        push @sys_startsF, $_ . "/sysstarts"; # FILE3
}
# File which stores the total amount of time since the program began
foreach (@driftD) {
        push @total_timeF, $_ . "/totaltime"; #FILE4
}
# File which store the configuration of tuptime
foreach (@confD) {
        push @conf_fileF, $_ . "/tuptime.conf"; #FILE5
}
# File which store last value read from /proc/stat
foreach (@driftD) {
        push @last_btimeF, $_ . "/lastbtime"; #FILE7
}
# File which store first boot date
foreach (@driftD) {
        push @first_bootF, $_ . "/firstboot"; #FILE8
}
# Some varibles used in the program, other in the subroutines
my ($uptime, $total, $prev_uptime, $prev_btime, $total_starts, $result_total, $temp_total, @param, @uptime_date, $tmp1, $first_boot) = '';



        foreach (@driftD, @confD)
        {
                if (-d "$_") {
                        printf("Exists: " . $_ . " - Don't do anything.\n");
                } else {
                        printf("Doesn't exist: " . $_ . " - Making! \n");
                        mkdir "$_", 655;
                }
        }


# Checking files
        foreach (@last_uptimeF, @last_btimeF, @total_timeF, @sys_startsF)
        {
                if (-e "$_" ) {
                       printf ("Exists: " . $_ . " - Don't do anything.\n");
                } else {
                        printf ("Doesn't exist: ". $_ . " - Making! \n");
                        open(FILE,"> $_") || return 1;
                        print FILE 0;
                        close FILE || return 1;
                }
        }


# Cheking the $conf_fileF
foreach (@conf_fileF) {
        if (-e "$_" ) {
                printf ("Exists: " . $_ . " - Don't do anything.\n");
        } else {
                printf ("Not exists: ". $_ . " - Making!\n");
                open(FILE5,"> $_") || return 1;
                print FILE5 "# tuptime configuration file\n# Usage: \n# Name:+MoreTime (in minutes)\n# or\n# Name:-LessTime (in minutes)\n# \n# Keep historical time in removed hardware:\n# Name:+Time:RM (Time = total time in minutes when the hardware was removered)\n# \nSystem:+0\n";
                close FILE5 || return 1;
        }
}

# LEFT OFF HERE --------------------------------------------------------------------

        # Cheking the $first_bootF
foreach (@first_bootF) {
        if (-e "$_" ) {
                printf ("Exists: " . $_ . " - Testing if is ok.\n");

                # Get first boot date
                open(FILE8,"< $_") || return 1;
                $first_boot = <FILE8>;
               close FILE8 || return 1;
        # If is empty, write the date
        if ($first_boot == 0) {
                # Go to the following else condition
                goto date_write;
        }

       } else {

        date_write:
        # Read date and write
        open(FILE6, "< $proc/stat") || return 1;
               ($tmp1) = grep( { m/btime/ } <FILE6>);
        close FILE6 || return 1;
        @uptime_date = split (' ', $tmp1, 2);

               printf ("Not exists: ". $first_bootF . " - Making!\n");
               open(FILE8,"> $first_bootF") || return 1;
               print FILE8 "$uptime_date[1]";
               close FILE8 || return 1;
        my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
               my ($sec, $min, $hour, $day,$month,$year) = (localtime($uptime_date[1]))[0,1,2,3,4,5,6];
        printf ("Saved first boot date: \t%02s:%02s:%02s   %02s-$months[$month]-%04s\n", $hour, $min, $sec, $day, ($year+1900));
       }
}
