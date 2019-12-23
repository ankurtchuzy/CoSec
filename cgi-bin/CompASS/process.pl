#! /root/localperl/bin/perl -w
print "Content-Type: text/html\n\n";

#importing modules
use CGI(':standard');
use Cwd qw(cwd);
use lib "/usr/share/perl5/";
use WWW::Mechanize();


$status = "failed"; #initial job status
$time = localtime(); #getting time
$name_one = param ("name_one"); #getting name of first state
$name_two = param ("name_two"); #getting name of first state
$first = $name_one; #original name
$second = $name_two; #original name
$task_name = $name_one."_vs_".$name_two;
#$down_file = $task_name.".txt";

$heading; #variable to store error message
$additional;#variable to store error message
$dir = cwd; #current working directory

#Checking username in stored profiles

$username = param ("username");
$flag = 0;
$pro = $dir."../../CoSec/database/profiles.csv";
open (PRO,'<',"$pro") or die;
@values;

foreach (<PRO>)
	{
	@values = split(',',$_);
	if ($values[0] eq $username){$flag = 1; $name = $values[2]; last;}
	}
close PRO;

if ($flag == 0)
	{
	$heading = "This username is not registered";
	$additional = "If you forgot your username then contact the admins with your registered email";
	$error = "invalid username";
	goto end;
	}


#web crawler to give pdb file to STRIDE and printing output in assigned.txt

#For first state

$pdbfile = param ("state_one");
my $mech = WWW::Mechanize->new;
my $url = 'http://webclu.bio.wzw.tum.de/cgi-bin/stride/stridecgi.py';
$mech->post($url);
$mech->form_name( 'stride' );
$mech->field('paste_field',$pdbfile);
$mech->click( 'action' );

#creating file to store STRIDE output for the first pdb

$stride_output = $dir."/temp_files/state1.txt";
open (STRI1,'>',"$stride_output");
print STRI1 $mech->text();
close (STRI1);


#For second state

$pdbfile = param ("state_two");
my $mech = WWW::Mechanize->new;
my $url = 'http://webclu.bio.wzw.tum.de/cgi-bin/stride/stridecgi.py';
$mech->post($url);
$mech->form_name( 'stride' );
$mech->field('paste_field',$pdbfile);
$mech->click( 'action' );

#creating file to store STRIDE output for the first pdb

$stride_output = $dir."/temp_files/state2.txt";
open (STRI2,'>',"$stride_output");
print STRI2 $mech->text();
close (STRI2);


	
#extracting secondary structure information from STRIDE files

#For first state 

$st1 = $dir."/temp_files/state1.txt";
open(ST1, '<' ,$st1) or die $!;


#reading state1.txt file

$state1;
$state1_seq;
foreach (<ST1>)
	{
	if ($_ =~ /STR\s{7}(.{50})/) {$state1 = $state1.$1}
	if ($_ =~ /SEQ  \d+\s+(\w+)\s+\d+/) {$state1_seq = $state1_seq.$1}
	}

$len = length($state1_seq); #Length of protein

$state1 = substr($state1,0,$len); #removing extra blanks at the ends

$state1 =~ tr/ /C/;   #converting spaces(\s) to coils(C)
close (ST1);


#For second state 

$st2 = $dir."/temp_files/state2.txt";
open(ST2, '<' ,$st2) or die $!;


#reading state2.txt file

$state2;
$state2_seq;
foreach (<ST2>)
	{
	if ($_ =~ /STR\s{7}(.{50})/) {$state2 = $state2.$1}
	if ($_ =~ /SEQ  \d+\s+(\w+)\s+\d+/) {$state2_seq = $state2_seq.$1}
	}

$len = length($state2_seq); #Length of protein

$state2 = substr($state2,0,$len); #removing extra blanks at the ends

$state2 =~ tr/ /C/;   #converting spaces(\s) to coils(C)
close (ST2);


#checking for invalid inputs

if ($state1_seq eq "" or $state2_seq eq "")

{
	$heading = "Invalid input";
	$additional = "Are you sure the inputs were right?";
	$error = "invalid input";
	goto end;
}

#calculation of scores

if ($state1_seq eq $state2_seq)
	{
	#converting strings to array
	@ini = split('',$state1);
	@fin = split('',$state2);
	
	#Differing score
	
	$score=0;
	$itr=0;
	@diff;
	@marker;
	foreach (@ini)
		{
		if ($_ ne $fin[$itr]) {$score++; push(@diff,"*");}
		else {push(@diff," ")}
		
		#adding dots in marker string
		$i=$itr+1;
		if ($i%10 == 0){push(@marker,".");}
		else {push(@marker," ");}
		
		$itr++;
		}
	$diff = join('',@diff);
	$marker = join('',@marker); #marker string
	$score = ($score/$len)*100;
	
	#Outputs in file with username_timetag
	$timetag = time();
	$out_file = $username."-".$timetag.".txt";
	
	#creating output file 
	$out = $dir."../../CoSec/results/compass/".$out_file;
	
	#output file creation
	open(OUT, '>',$out) or die $!;
	
	$status = "successful"; #job status successful
	$error = "none"; #no error
	
	#alignment of state names
	$name_one = "            ".$name_one; #adding blank spaces at end
	$name_one = substr($name_one,-10); #taking first 10 character
	
	$name_two = "            ".$name_two; #adding blank spaces at end
	$name_two = substr($name_two,-10); #taking first 10 character
	
    #Outputs in result file with timetag
	
	print OUT "                                 CompASS\n";
	print OUT "               |Comp|are |A|ssigned |S|econdary |S|tructure\n\n";
	print OUT "Hey $name\n\nLength of protein : $len\nError message : $error\n\n";
	print OUT "The results for your task \"$task_name\" are:\n\n\n";
	
    print OUT " H Alpha helix\n G 3-10 helix\n I PI-helix\n E Extended conformation\n B or b Isolated bridge\n T Turn\n C Coil\n\n\n";
 	print OUT "************************************************************************\n";
	print OUT "***************************     ALIGNMENT     **************************\n";
	print OUT "************************************************************************\n\n\n";           
	for ($i=0 ; $i < $len ; $i=$i+60 )
		{
		print OUT ("            ",substr($marker,$i,60));
		print OUT ("\n$name_one: ",substr($state1,$i,60));
		print OUT ("  ",$i+60) if($i < $len-60);
		print OUT ("\n$name_two: ",substr($state2,$i,60),"\n");
		print OUT ("            ",substr($diff,$i,60),"\n");
		print OUT ("        AA: ",substr($state1_seq,$i,60),"\n\n\n");
		}
	
	print OUT "*************************************************************************\n";        
	print OUT "***************************       SCORE       ***************************\n";
	print OUT "*************************************************************************\n\n\n";
    printf OUT ("Total Differing score %5.2f%\n\n",$score);
	
		
	print OUT "Alpha helix content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/H//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/H//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/H//)/$len)*100)-((($state2 =~ tr/H//)/$len)*100)));
	
	print OUT "3-10 helix content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/G//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/G//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/G//)/$len)*100)-((($state2 =~ tr/G//)/$len)*100)));
	
	print OUT "PI-helix content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/I//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/I//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/I//)/$len)*100)-((($state2 =~ tr/I//)/$len)*100)));
	
	print OUT "Extended conformation content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/E//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/E//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/E//)/$len)*100)-((($state2 =~ tr/E//)/$len)*100)));
	
	print OUT "Isolated bridge content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/Bb//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/Bb//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/Bb//)/$len)*100)-((($state2 =~ tr/Bb//)/$len)*100)));
	
	print OUT "Turn content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/T//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/T//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/T//)/$len)*100)-((($state2 =~ tr/T//)/$len)*100)));
	
	print OUT "Coil content:\n\n";
	printf OUT ("$name_one         = %5.2f%\n",(($state1 =~ tr/C//)/$len)*100);
	printf OUT ("$name_two         = %5.2f%\n",(($state2 =~ tr/C//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($state1 =~ tr/C//)/$len)*100)-((($state2 =~ tr/C//)/$len)*100)));
	
	print OUT ("Task completed on $time\n");
	close (OUT);
	
	}
else
	{
	$heading = "Your inputs are not of the same protein , Try again with correct inputs";
	$additional = "Amino acid sequence did not match in given inputs";
	$error = "Protein sequence mismatch";
	print OUT "\nYour files are not of the same protein , Try again with correct files\n";
	goto end;
	}

#output on webpage

#color codes for characters
$H ="<font color=#000066>H</font>";
$G ="<font color=#0099CC>G</font>";
$I ="<font color=#66FFFF>I</font>";
$E ="<font color=#FF0000>E</font>";
$B ="<font color=#FF6600>B</font>";
$b ="<font color=#FF6600>b</font>";
$T ="<font color=#33FF00>T</font>";
$C ="<font color=#FFFF00>C</font>";


#repeated for assurance
@ini = split('',$state1);
@fin = split('',$state2);
$len = length($state2_seq);

#getting scores from result file

$res = $dir."../../CoSec/results/compass/".$out_file;

open(RES, '<' ,$res) or die $!;
@state1_percent;
@state2_percent;
@diff_percent;
foreach (<RES>)
	{
	if ($_ =~ /Total Differing score (.+)/){$diff_score = $1;}
	if ($_ =~ /$name_one         = (.+)/){push(@state1_percent,$1);}
	if ($_ =~ /$name_two         = (.+)/){push(@state2_percent,$1);}
	if ($_ =~ /Difference         = (.+)/){push(@diff_percent,$1);}
	}

#remove this code ,only for testing
$te = $dir."/temp_files/test.txt";
open(TE, '>' ,$te) or die $!;
print TE "$diff_score\n";
print TE "@state1_percent\n";
print TE "@state2_percent\n";
print TE "@diff_percent\n";
#remove this code ,only for testing


$l1="";
$l2="";
$ind=0;

foreach (@ini) 
	{
	$l1 = $l1."$H" if ($_ eq "H");
	$l1 = $l1."$G" if ($_ eq "G");
	$l1 = $l1."$I" if ($_ eq "I");
	$l1 = $l1."$E" if ($_ eq "E");
	$l1 = $l1."$B" if ($_ eq "B");
	$l1 = $l1."$b" if ($_ eq "b");
	$l1 = $l1."$T" if ($_ eq "T");
	$l1 = $l1."$C" if ($_ eq "C");
		
	
	$l2 = $l2."$H" if ($fin[$ind] eq "H");
	$l2 = $l2."$G" if ($fin[$ind] eq "G");
	$l2 = $l2."$I" if ($fin[$ind] eq "I");
	$l2 = $l2."$E" if ($fin[$ind] eq "E");
	$l2 = $l2."$B" if ($fin[$ind] eq "B");
	$l2 = $l2."$b" if ($fin[$ind] eq "b");
	$l2 = $l2."$T" if ($fin[$ind] eq "T");
	$l2 = $l2."$C" if ($fin[$ind] eq "C");
	
	$ind++;
	}


#webpage output
#________________________________________________________________________________________________________________________

print <<B1;
<!DOCTYPE html>
<html lang="en-US">
<head profile="CompASS"><title>CompASS</title>
<link rel="icon" 
      type="image/png" 
      href="../../CoSec/CompASS/Images/com_logo.png">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
* {
  box-sizing: border-box;
}

body {
  font-family: Arial;
  padding:50px; 
  padding-top: 20px;
  padding-right: 50px;
  padding-bottom: 20px;
  padding-left: 50px;
  background: rgb(180, 180, 180);
  min-width:1300px;
}

/* Header/Blog Title */
.header {
  padding:10px;
  text-align: center;
  background: white;
}

.header h1 {
  font-size:0px;
}

/* Style the top navigation bar */
.topnav {
  list-style-type: none;
  margin: 0;
  padding: 0;
  overflow: hidden;
  border-top: 7px solid #000033;
  background-color: rgb(243,243,243,0.9);
  position: -webkit-sticky; /* Safari */
  position: sticky;
  top: 0;
  
}

/* Style the topnav links */
.topnav a {
  float: left;
  display: block;
  color: #666;
  text-align: center;
  padding: 14px 16px;
  text-decoration: none;
  
}

/* Change color on hover */
.topnav a:hover {
  background-color: #000033;
  color: white;
}

/* Create two unequal columns that floats next to each other */
/* Left column */
.leftcolumn {   
  float: left;
  width: 75%;
}

/* Right column */
.rightcolumn {
  float: left;
  width: 25%;
  background-color: rgb(180, 180, 180);
  padding-left: 20px;
}

/* Add a card effect for articles */
.card {
  background-color: white;
  padding: 20px;
  margin-top: 25px;
}

/* Clear floats after the columns */
.row:after {
  content: "";
  display: table;
  clear: both;
}


/* Responsive layout - when the screen is less than 800px wide, make the two columns stack on top of each other instead of next to each other */
@media screen and (max-width: 800px) {
  .leftcolumn, .rightcolumn {   
    width: 100%;
    padding: 0;
  }
}

/* Responsive layout - when the screen is less than 400px wide, make the navigation links stack on top of each other instead of next to each other */
@media screen and (max-width: 400px) {
  .topnav a {
    float: none;
    width: 100%;
  }
  }
  
  /* Fake image */
.fakeimg {
  background-color: #aaa;
  width: 100%;
  padding: 20px;
}

.button {
  background-color:#32CD32;
  color: rgb(60, 60, 60);
  padding: 21px 5px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 20px;
  width: 100%;
  border-radius: 0px;
  cursor: pointer;
  border: 5px solid #e7e7e7;
  -webkit-transition-duration: 0.4s; /* Safari */
  transition-duration: 0.4s;
}
.button:hover {
  background-color: #555555;
  color: white;
  box-shadow: 0 12px 16px 0 rgba(0,0,0,0.24), 0 17px 50px 0 rgba(0,0,0,0.19);
}

.btn-group .button {
  color: white;
  border: 0px solid #e7e7e7;
  padding: 12px 12px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 18px;
  width: 100%;
  display: block;
  margin-top: 25px;
}
table {
  border-collapse: collapse;
  width: 100%;
}

th, td {
  
  border-top: 1px solid  #000099;
}

tr:hover {background-color:#f5f5f5;}

/* unvisited link */
a:link {
  color: #606060;
  text-decoration: none;
}

/* visited link */
a:visited {
  color: #606060;
  text-decoration: none;
}

/* mouse over link */
a:hover {
  color: #00FFFF;
  text-decoration: none;
}

/* selected link */
a:active {
  color: #00FFFF;
  text-decoration: none;
}

/* default table */
.defaulttable {
  display: table;
}
.defaulttable thead {
  display: table-header-group;
}
.defaulttable tbody {
  display: table-row-group;
}
.defaulttable tfoot {
  display: table-footer-group;
}
.defaulttable tbody>tr:hover,
.defaulttable tbody>tr {
  display: table-row;
}
.defaulttable tbody>tr:hover>td,
.defaulttable tbody>tr>td {
  display: table-cell;
}
.defaulttable,
.defaulttable tbody,
.defaulttable tbody>tr:hover,
.defaulttable tbody>tr,
.defaulttable tbody>tr:hover>td,
.defaulttable tbody>tr>td,
.defaulttable tbody>tr:hover>th,
.defaulttable tbody>tr>th,
.defaulttable thead>tr:hover>td,
.defaulttable thead>tr>td,
.defaulttable thead>tr:hover>th,
.defaulttable thead>tr>th,
.defaulttable tfoot>tr:hover>td,
.defaulttable tfoot>tr>td,
.defaulttable tfoot>tr:hover>th,
.defaulttable tfoot>tr>th {
  background: transparent;
  border: 0px solid #000;
  border-spacing: 0px;
  border-collapse: collapse;
  empty-cells: hide;
  padding: 0px;
  margin: 2px;
  outline: 0px;
  font-size: 100%;
  color: white;
  text-align: left;
  font-family: Arial;
  caption-side: top;
  -webkit-border-radius: 0px;
  -moz-border-radius: 0px;
  border-radius: 0px;
  -webkit-background-clip: padding-box;
  -moz-background-clip: padding;
  background-clip: padding-box;
}

</style>
</head>
<body>

<div class="header">
<img src = "../../CoSec/CompASS/Images/compass.png" style='height: 100%; width: 100%; object-fit: contain'/>
</div>

<div class="topnav">
  <a href="../../CoSec/CompASS/CompASS.html">Home</a>
  <a href="../../CoSec/CoSec.html">CoSec</a>
  <a href="../../CoSec/CompASS/about.html">About</a>
  <a href="../../CoSec/CompASS/CompASS_ReadME.pdf">ReadME</a>
  <a href="../../CoSec/CompASS/references.html">References</a>
  <a href="../../CoSec/contact.html">Contact</a>
  <a href="../../CoSec/CompASS/faq.html">FAQs</a>
  <a href="../../CoSec/new_user.html" style="float:right">Register</a>
</div>

<div class="row">
	<div class="leftcolumn">
		<div class="card">
B1
		print "<center><h2>Hello $name !</h2></center>";
		print "<h4>Results of comparison between $first and $second are here. Your job completed on $time</h4>";
        print "<p>Length of protein : $len amino acids</p>";		
print <<B2;		
		
	</div>
	</div>
	<div class="rightcolumn"></center>
	<div class="card">
      <center><h2>Download Result</h2>
B2
	    print "<a href = '../../CoSec/results/compass/$out_file' download = '$task_name.txt' ><button class=\"button\" >DOWNLOAD</button></a>";

print <<B3;	
      </div>
	</div>
</div>
<div class="row">
  <div class="leftcolumn">
    
    <div class="card">
      <center><h2>Alignment</h2></center><br>
	  <table cellpadding="13" style = "border-bottom: 1px solid #000099;">
      <tr><td> </td><td align='right'>$name_one :</td><td> First state</td>   <td align='right'>$name_two :</td><td> Second state</td><td> </td></tr>
	  <tr><td> </td><td align='right'>H :</td><td> Alpha helix</td>          <td align='right'>B or b :</td><td> Isolated bridge</td><td> </td></tr>
	  <tr><td> </td><td align='right'>G :</td><td> 3-10 helix</td>           <td align='right'>T :</td><td> Turn</td><td> </td></tr>
	  <tr><td> </td><td align='right'>I :</td><td> PI-helix</td>             <td align='right'>C :</td><td> Coil</td><td> </td></tr>
	  <tr><td> </td><td align='right'>E :</td><td> Extended conformation</td><td align='right'>* :</td><td> Difference</td><td> </td></tr>
	  </table>
	  <br><br><br><centre>
B3

	  print "<div style = 'width: 100%;margin-left: auto;margin-right: auto;'><pre>";
	  for ($i=0 ; $i < $len ; $i=$i+80 )
		{
		$li0=substr($marker,$i,80);
		$li1=substr($l1,(28*$i),(28*80));
		$li2=substr($l2,(28*$i),(28*80));
		$l3=substr($diff,$i,80);
		$l4=substr($state2_seq,$i,80);
		$num=$i+80; 
		$num = "" if($i > $len-80);
		print "<p style='font-size:125%;'>            <b>$li0</b><br>$name_one: <b>$li1</b> $num<br>$name_two: <b>$li2</b><br>            $l3<br>        AA: $l4</p><br><br>";
		}
		print "</pre></div></centre>";
	    print "</div>";

print <<B4;	  
  </div>
  <div class="rightcolumn">
B4
      	  
	  print "<div class=\"card\" style = \"background: linear-gradient(to bottom, #ff6600 0%, #ff0000 100%); color: white;\">";
      print "<center><h3>DIFFERING SCORE</h3>";
      print "<h1>$diff_score<h1></center></div>";
	  
print <<B5;
    <div class="card">
    <center><h3>Legends</h3></center>
      <div class="btn-group">
      <button class="button" style = "background-color: #000066;">Alpha helix</button>
	  <button class="button" style = "background-color: #0099CC;">3-10 helix</button>
	  <button class="button" style = "background-color: #66FFFF; color: black;">PI-helix</button>
	  <button class="button" style = "background-color: #FF0000;">Extended conformation</button>
	  <button class="button" style = "background-color: #FF6600;">Isolated bridge</button>
	  <button class="button" style = "background-color: #33FF00;">Turn</button>
	  <button class="button" style = "background-color: #FFFF00; color: black;">Coil</button>
	  </div>
    </div>
  </div>
</div>
B5


print"<div class= 'card' >";
     print" <center><h2>Scores</h2></center>";

      print "<h4><center>Total differing score : $diff_score</centre></h4><br>";
      	   
	  print "<div style = 'text-align: center;'>";
	  	 
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #000066 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>Alpha helix</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[0]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[0]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[0]</td></tr>";
	  print "</table>";
	  print "</div>";

	 
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #0099CC 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>3-10 helix</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[1]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[1]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[1]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #66FFFF 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>PI-helix</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[2]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[2]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[2]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  print "</div>";
	  
	  
	  
	  print "<div style = 'text-align: center;'>";
	  
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #FF0000 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>Extended conformation</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[3]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[3]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[3]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #FF6600 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>Isolated bridge</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[4]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[4]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[4]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #33FF00 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>Turn</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[5]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[5]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[5]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  
	  print "<div style = 'margin-left: 15px;margin-right: 15px; width: 25%;background: linear-gradient(to top, #ffffff 0%, #FFFF00 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3><font color= white>Coil</font></h3></center>";
	  
	  print "<table cellpadding='13'>";
      print "<tr><td>$name_one </td><td>$state1_percent[6]</td></tr>";
	  print "<tr><td>$name_two </td><td>$state2_percent[6]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[6]</td></tr>";
	  print "</table>";
	  print "</div></center>";
      print "<p><a href='../../CoSec/CompASS/about.html#scores' target='_blank'>Click here to know more about the scores</a></p> ";
	  print "</div>";
	  
	  
	  print "</div>";


print <<B6;
	  <div style ="background-color: #000033 ;padding: 20px;width:100%;margin-top: 25px;color: white"> 
	  <table class="defaulttable" style="width: 100%;">
     <tr><td> Copyright &#9400; 2019 Ayaluru Murali | Ankur Chaurasia | All Rights Reserved </td><td style =" float: right;"> Centre for Bioinformatics | Pondicherry University </td></tr>
	 <tr><td height="50" valign="bottom"> Header background image by <a href="https://pixabay.com/users/DavidZydd-985081/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2484170" target="_blank">David Zydd</a>, Webpage designing learned from <a href="https://www.w3schools.com/" target="_blank">w3schools</a>.</td></tr>
	 </table>
      </div>
  </div>
</body>
</html>
B6

#________________________________________________________________________________________________________________________

#printing job status in file if success

$stat = $dir."../../CoSec/database/job_logs_compass.csv";
open (STA,'>>',"$stat") or die;
print STA "\n$username,$task_name,$len,$time,$status,$error";

exit;


end:

#printing job status in file if failed

$stat = $dir."../../CoSec/database/job_logs_compass.csv";
open (STA,'>>',"$stat") or die;
print STA "\n$username,$task_name,$len,$time,$status,$error";

#Printing error messages on webpage

print <<B2;
<!DOCTYPE html>
<html lang="en-US">
<head profile="CompASS"><title>OOps Error!</title>
<link rel="icon" type="image/png" href="../../CoSec/CompASS/Images/com_logo.png">
<style>
body {
  font-family: Arial;
  padding-top: 10px;
  padding-right: 50px;
  padding-bottom: 20px;
  padding-left: 50px;
  background: rgb(180, 180, 180);
}
/* unvisited link */
a:link {
  color: rgb(0, 200, 210,0.5);
  text-decoration: none;
}

/* visited link */
a:visited {
  color: rgb(0, 200, 210,0.5);
  text-decoration: none;
}

/* mouse over link */
a:hover {
  color: grey;
  text-decoration: none;
}

/* selected link */
a:active {
  color: grey;
  text-decoration: none;
  }
</style>
</head>
<center>
<body>
B2
	print "<h1>OOps Error!</h1><h2>$heading</h2><p>$additional</p>";
	print "<img src=\"../../CoSec/CompASS/Images/com_toolmark.png\" alt=\"CompASS\" style=\"width: 35%;display: block; margin-left: auto; margin-right: auto;margin-top: 80px;\">";
	print "</body></center></html>";
