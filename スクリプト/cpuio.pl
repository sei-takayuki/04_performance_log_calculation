#!/usr/bin/perl

use strict;
use warnings;

#tukaikata
#./cpuio.pl starttime1[HH:MM:SS] endtime1[HH:MM:SS] starttime2{HH:MM:SS] endtime2[HH:MM:SS]

# Logfile no PATH,filename wo sitei
my $sarfile = '/home/sasaki/scripts/sar-u3.txt';
my $iofile = '/home/sasaki/scripts/iostat_140103.txt';

our $start_time = $ARGV[0];
our $end_time = $ARGV[1];
our $start_time2 = $ARGV[2];
our $end_time2 = $ARGV[3];

if (@ARGV == 4){

open my $sarfh, '<', $sarfile
  or die qq{Can't open file: "$sarfile": $!};

our $cpu_infos = [];

while (my $cpuline = <$sarfh>){
        next if $. == 1;
        chomp $cpuline;
        my @rec = split /\s+/, $cpuline;

        my $cpu_info = {};
        $cpu_info->{time} = $rec[0];
        $cpu_info->{user} = $rec[3];

        push @$cpu_infos, $cpu_info;
}

close $sarfh;

# sarの結果を指定時刻のもののみに切り出し、$cpu_infos_cut配列リファレンスに追記する
my $cpu_infos_cut = [];
my $i = 0;
my $total;

foreach our $cpu_info2 (@$cpu_infos) {
	if ($cpu_info2->{time} ge $start_time && $cpu_info2->{time} le $end_time) {
		$i++;
		$cpu_info2->{count} = $i;
		$total += $cpu_info2->{user};		
        	$cpu_info2->{user_total} = $total;
		push @$cpu_infos_cut, $cpu_info2;
	}
}
		

open my $iofh, '<',$iofile
  or die qq{Can't open file: "$iofile": $!};

our $io_infos = [];
our $io_info ={};

while (my $ioline = <$iofh>){
        chomp $ioline;
        if ($ioline =~ /^Time:\s+(\d{2}:\d{2}:\d{2})/) {
		$io_info ={};
		my @rec3 = split(/\s+/, $ioline);
            	$io_info->{time2} = $rec3[1];
        }
        elsif ($ioline =~ /^sda\s/) {
     		my @rec2 = split /\s+/, $ioline;

                $io_info->{avgqu_sz} = $rec2[8];
		$io_info->{util} = $rec2[11];

		push @$io_infos, $io_info;
        }

}

close $iofh;

# iostatの結果を指定時刻のもののみに切り出し、$io_infos_cut配列リファレンスに追記する
my $io_infos_cut = [];
my $i2 = 0;
my $total2;
my $total3;

foreach my $io_info2 (@$io_infos) {
	if ($io_info2->{time2} ge $start_time2 && $io_info2->{time2} le $end_time2) {
		$i2++;
		$total2 += $io_info2->{avgqu_sz};		
		$total3 += $io_info2->{util};		
		push @$io_infos_cut, $io_info2;
	}
}



# ２つの配列をマージする
my $cpu_io_infos;
push @$cpu_io_infos, +{%{$cpu_infos_cut->[$_]}, %{$io_infos_cut->[$_]}} for 0..$#$cpu_infos_cut;


#CSV形式で出力する

my @headers = qw/time %user time2 avgqu_sz %util/;

print join(',', @headers) . "\n";

foreach my $cpu_io_info (@$cpu_io_infos) {
	my $count = $cpu_io_info->{count};
	my $time = $cpu_io_info->{time};
	my $user = $cpu_io_info->{user};
	my $user_total = $cpu_io_info->{user_total};
	my $time2 = $cpu_io_info->{time2};
	my $avgqu_sz = $cpu_io_info->{avgqu_sz};
	my $util = $cpu_io_info->{util};

        print join(',', $count, $time, $user, $user_total, $time2, $avgqu_sz, $util) . "\n";
}

my @headers2 = qw/count %user_avg  count2 avgqu_sz_avg %util_avg/;

print join(',', @headers2) . "\n";

print join(',', $i , my $avg=$total/$i, $i2 , my $avg2=$total2/$i2, my $avg3=$total3/$i2);
}
else{ 
	print 'starttime1 endtime1 starttime2 endtime2';
}
