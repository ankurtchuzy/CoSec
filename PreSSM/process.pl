#! C:\xampp\perl\bin\perl.exe
print "Content-Type: text/html\n\n";

#importing modules
use CGI(':standard');
use Cwd qw(cwd);
use lib "/usr/share/perl5";
use WWW::Mechanize();


$status = "failed"; #initial job status
$time = localtime(); #getting time
$task_name = param ("task");#getting task name
$heading; #variable to store error message
$additional;#variable to store error message
$dir = cwd; #current working directory

#Checking username in stored profiles
$username = param ("username");
$flag = 0;
$pro =$dir."/database/profiles.csv";
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

#Creating file to store user input for prediction

$pre =$dir."/temp_files/prediction.txt";
open(PRE,'>',$pre) or die $!;

$prediction = param ("prediction");
print PRE $prediction;
close (PRE);

#global variables for input from predicted files
$pred_str;
$pred_seq;

#determining the method used by user for secondary structue prediction
	
$met = $dir."/temp_files/prediction.txt";
open(MET, '<' , $met ) or die $!;

$method;
foreach (<MET>)
	{
	$cache = $_;
	$cache =~ tr/?/c/;   #converting ? to coils(c) in case of nspa file
	if ($cache =~ /Pred: (\w+)/)          {$method = "PSIPRED";last;}
	if ($cache =~ /Sec.Cons.\s+(\w+)/)    {$method = "NSPA";last;}
	if ($cache =~ /Struc \d+\s+(\w+) \d+/){$method = "CFSSP";last;}
	}

	#if method is PSIPRED
    
if ($method eq "PSIPRED")
	{
	$ps = $dir."/temp_files/prediction.txt";
	open(PS, '<' , $ps ) or die $!;

	#reading predicted file

	$psipred;
	$psi_seq;
	foreach (<PS>)
		{
		if ($_ =~ /Pred: (\w+)/) {$psipred = $psipred.$1;}
		if ($_ =~ /  AA: (\w+)/) {$psi_seq = $psi_seq.$1;}
		}
	close (PS);
	$pred_str = $psipred;
	$pred_seq = $psi_seq;
	}
	
	#if method is nspa

elsif ($method eq "NSPA")
	{
	#extracting secondary structure data from nspa file
	$ns = $dir."/temp_files/prediction.txt";
	open(NS, '<' , $ns ) or die $!;

	#extract the job name in nspa file from 5th line
	$job_name;
	foreach (<NS>)
	{
	if ($_ =~ /(\w+)\s{1,7}\w+/){$jobname = $1; last;}
	}
	close (NS);
		
	#reading predicted file
	
	open(NS, '<' , $ns ) or die $!;

	$nspa;
	$nsp_seq;
	$line = 1;
	
	foreach (<NS>)
		{
		$temp = $_;
		$temp =~ tr/?/c/;   #converting ? to coils(c)
		if ($temp =~ /Sec.Cons.\s+(\w+)/) {$nspa = $nspa.$1}
		if ($_ =~ /$jobname\s+(\w+)/) {$nsp_seq = $nsp_seq.$1;}
		$line++;
		}
	$nspa = uc($nspa);  #converting to upper case
	close (NS);
	$pred_str = $nspa;
	$pred_seq = $nsp_seq;
	
	if (length($pred_str)!=length($pred_seq))
		{
		$heading = "It seems you did not copy the right alignment";
	    $additional = "Refer to <a href='#'>README</a> for more details";
		$error = "length mismatch";
		goto end;
		}
	}
	
	#if method is chou fasman
	
elsif ($method eq "CFSSP")
	{
	$cf = $dir."/temp_files/prediction.txt";
	open(CF, '<' , $cf ) or die $!;

	#reading predicted file

	$choufas;
	$chou_seq;
	foreach (<CF>)
		{
		if ($_ =~ /Struc \d+\s+(\w+) \d+/) {$choufas = $choufas.$1;}
		if ($_ =~ /Query \d+\s+(\w+) \d+/) {$chou_seq = $chou_seq.$1;}
		}
	$choufas =~ tr/T/C/;   #converting turns(T) to coils(C)
	close (CF);
	$pred_str = $choufas;
	$pred_seq = $chou_seq;
	}
	
	#if no method detected
else	
	{
	$heading = "Are you sure you have got the right inputs ?";
	$additional = "Refer to ReadME for more details";
	$error = "method detection failed";
	goto end;
	}

#web crawler to give locally stored pdb file to STRIDE and printing output in assigned.txt

$pdbfile = param ("pdbfile");
my $mech = WWW::Mechanize->new;
my $url = 'http://webclu.bio.wzw.tum.de/cgi-bin/stride/stridecgi.py';
$mech->post($url);
$mech->form_name( 'stride' );
$mech->field('paste_field',$pdbfile);
$mech->click( 'action' );

#creating file to store STRIDE output
$stride_output = $dir."/temp_files/assigned.txt";
open (STRI,'>',"$stride_output");
print STRI $mech->text();
close (STRI);
	
#extracting secondary structure information from STRIDE file

$st = $dir."/temp_files/assigned.txt";
open(ST, '<' ,$st) or die $!;

$len = length($pred_seq); #Length of amino acid

#reading assigned.txt file

$stride;
$str_seq;
foreach (<ST>)
	{
	if ($_ =~ /STR\s{7}(.{50})/) {$stride = $stride.$1}
	if ($_ =~ /SEQ  \d+\s+(\w+)\s+\d+/) {$str_seq = $str_seq.$1}
	}

$stride = substr($stride,0,$len); #removing extra blanks at the ends
$stride =~ tr/ /C/;   #converting spaces(\s) to coils(C)
$stride =~ tr/T/C/;   #converting turns(T) to coils(C)
$stride =~ tr/G/H/;   #converting 3 10 helix(G) to alpha-helix(H)
$stride =~ tr/I/H/;   #converting PI-helix(I) to alpha-helix(H)
$stride =~ tr/Bb/EE/; #converting Bridge(B or b) to Strand(E)
	
	$assig_str = $stride;
	$assig_seq = $str_seq;

close (ST);



#calculation of scores

if ($pred_seq eq $assig_seq)
	{
	#converting strings to array
	@pre = split('',$pred_str);
	@asg = split('',$assig_str);
	
	#matching score
	
	$score=0;
	$contra=0;
	$itr=0;
	@match;
	@marker;
	foreach (@pre)
		{
		if ($_ eq $asg[$itr]) {$score++; push(@match,"*");}
		else {
			if ($_ eq 'H' && $asg[$itr] eq 'E'){$contra++;push(@match,"|");}
			elsif ($_ eq 'E' && $asg[$itr] eq 'H'){$contra++;push(@match,"|");}
			else {push(@match," ");}
			 }
			 
		#adding dots in marker string
		$i=$itr+1;
		if ($i%10 == 0){push(@marker,".");}
		else {push(@marker," ");}
		
		$itr++;
		}
	$match = join('',@match);
	$marker = join('',@marker); #marker string
	$score = ($score/$len)*100;
	$contra = ($contra/$len)*100;

	#Outputs in file with username_timetag
	$timetag = time();
	$out_file = $username."-".$timetag.".txt";
	
	#creating output file 
	$out = $dir."/results/".$out_file;
	
	#output file creation
	open(OUT, '>',$out) or die $!;
	
	$status = "successful"; #job status successful
	$error = "none"; #no error
	
	#Message in output file
	
	print OUT "                               PreSSM\n";
	print OUT "            |Pre|dicted |S|econdary |S|tructure |M|atching\n\n";
	print OUT "Hey $name\n\nMethod used for prediction : $method\nLength of protein : $len\nError message : $error\n\n";
	print OUT "The results for your task \"$task_name\" are:\n\n";
	print OUT " H helix\n B sheet\n C coil\n\n";
	print OUT "********************************************************************\n";
	print OUT "*************************     ALIGNMENT     ************************\n";
	print OUT "********************************************************************\n\n\n";           
	for ($i=0 ; $i < $len ; $i=$i+60 )
		{
		print OUT ("        ",substr($marker,$i,60));
		print OUT ("\n  Pred: ",substr($pred_str,$i,60));
		print OUT ("  ",$i+60) if($i < $len-60);
		print OUT ("\nAssign: ",substr($assig_str,$i,60),"\n");
		print OUT ("        ",substr($match,$i,60),"\n");
		print OUT ("    AA: ",substr($pred_seq,$i,60),"\n\n\n");
		}
	
	print OUT "********************************************************************\n";        
	print OUT "*************************       SCORES      ************************\n";
	print OUT "********************************************************************\n\n\n";
	            
	printf OUT ("Total match score   :%5.2f%\n",$score);
	printf OUT ("Contradiction score :%5.2f%\n\n",$contra);
	
	print OUT "Helix content :\n\n";
	printf OUT ("Prediction         = %5.2f%\n",(($pred_str =~ tr/H//)/$len)*100);
	printf OUT ("3D structure       = %5.2f%\n",(($assig_str =~ tr/H//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($pred_str =~ tr/H//)/$len)*100)-((($assig_str =~ tr/H//)/$len)*100)));
	
	print OUT "Strand content:\n\n";
	printf OUT ("Prediction         = %5.2f%\n",(($pred_str =~ tr/E//)/$len)*100);
	printf OUT ("3D structure       = %5.2f%\n",(($assig_str =~ tr/E//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($pred_str =~ tr/E//)/$len)*100)-((($assig_str =~ tr/E//)/$len)*100)));
	
	print OUT "Coil content  :\n\n";
	printf OUT ("Prediction         = %5.2f%\n",(($pred_str =~ tr/C//)/$len)*100);
	printf OUT ("3D structure       = %5.2f%\n",(($assig_str =~ tr/C//)/$len)*100);
	printf OUT ("Difference         = %5.2f%\n\n",abs(((($pred_str =~ tr/C//)/$len)*100)-((($assig_str =~ tr/C//)/$len)*100)));
	
	#print ("Task completed on $time\n");
	print OUT ("Task completed on $time\n");
	close (OUT);
		
	}
else
	{
	$heading = "Your inputs are not of the same protein , Try again with correct inputs";
	$additional = "Amino acid sequence did not match in given inputs";
	$error = "sequence match fail";
	print OUT "\nYour files are not of the same protein , Try again with correct files\n";
	goto end;
	}

#output on webpage

#color codes for characters
$H ="<font color=#0000CC>H</font>";
$E ="<font color=#FF0000>E</font>";
$C ="<font color=#FFFF00>C</font>";

#repeated for assurance
@pre = split('',$pred_str);
@asg = split('',$assig_str);
$len = length($pred_seq);

#getting scores from result file

$res = $dir."/results/".$out_file;

open(RES, '<' ,$res) or die $!;
@pred_percent;
@assi_percent;
@diff_percent;
foreach (<RES>)
	{
	if ($_ =~ /Total match score   :(.+)/){$match_score = $1;}
	if ($_ =~ /Contradiction score :(.+)/){$contra_score = $1;}
	if ($_ =~ /Prediction         = (.+)/){push(@pred_percent,$1);}
	if ($_ =~ /3D structure       = (.+)/){push(@assi_percent,$1);}
	if ($_ =~ /Difference         = (.+)/){push(@diff_percent,$1);}
	}

#remove this code ,only for testing
$te = $dir."/temp_files/test.txt";
open(TE, '>' ,$te) or die $!;
print TE "$match_score\n$contra_score\n";
print TE "@pred_percent\n";
print TE "@assi_percent\n";
print TE "@diff_percent\n";
#remove this code ,only for testing


$l1="";
$l2="";
$ind=0;

foreach (@pre) 
	{
	$l1 = $l1."$H" if ($_ eq "H");
	$l1 = $l1."$E" if ($_ eq "E");
	$l1 = $l1."$C" if ($_ eq "C");
	
	$l2 = $l2."$H" if ($asg[$ind] eq "H");
	$l2 = $l2."$E" if ($asg[$ind] eq "E");
	$l2 = $l2."$C" if ($asg[$ind] eq "C");
	$ind++;
	}

#webpage output
#________________________________________________________________________________________________________________________

print <<B1;
<!DOCTYPE html>
<html lang="en-US">
<head profile="PreSSM"><title>PreSSM</title>
<link rel="icon" 
      type="image/png" 
      href="../../CoSec/PreSSM/Images/logo.png">
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
  border-top: 7px solid #D20050;
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
  background-color: #D20050;
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
  padding: 12px 10px;
  text-align: left;
  border-bottom: 1px solid rgb(210, 0, 80,0.7);
  border-top: 1px solid rgb(210, 0, 80,0.7);
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
<img src = "../../CoSec/PreSSM/Images/head.png" style='height: 100%; width: 100%; object-fit: contain'/>
</div>

<div class="topnav">
  <a href="../../CoSec/PreSSM/PreSSM.html">Home</a>
  <a href="../../CoSec/CoSec.html">CoSec</a>
  <a href="../../CoSec/PreSSM/about.html">About</a>
  <a href="#">ReadME</a>
  <a href="../../CoSec/PreSSM/references.html">References</a>
  <a href="../../CoSec/contact.html">Contact</a>
  <a href="../../CoSec/PreSSM/faq.html">FAQs</a>
  <a href="../../CoSec/new_user.html" style="float:right">Register</a>
</div>

<div class="row">
	<div class="leftcolumn">
		<div class="card">
B1
		print "<center><h2>Hello $name !</h2></center>";
		print "<h4>Results for job $task_name are here. Your job completed on $time</h4>";
        print "<p>Length of protein : $len amino acids</p>";		
print <<B2;		
		
	</div>
	</div>
	<div class="rightcolumn"></center>
	<div class="card">
      <center><h2>Download Result</h2>
B2
	    print "<a href = 'results/$out_file' download = '$task_name.txt' ><button class=\"button\" >DOWNLOAD</button></a>";

print <<B3;	
      </div>
	</div>
</div>
<div class="row">
  <div class="leftcolumn">
    
    <div class="card">
      <center><h2>Alignment</h2></center><br>
	  <table>
      <tr><td>Pred :</td><td> Predicted secondary structure</td></tr>
	  <tr><td>Assign :</td><td> Secondary structure elements in 3D model as assigned by STRIDE</td></tr>
	  <tr><td>AA :</td><td> Amino acid</td></tr>
	  <tr><td>* :</td><td> A match</td></tr>
	  <tr><td>| :</td><td> A contradiction</td></tr>
	  <tr><td>Prediction method :</td><td> $method</td></tr>
	  </table>
	  <br><br><br><centre>
B3

	  print "<div style = 'width: 95%;margin-left: auto;margin-right: auto;'><pre>";
	  for ($i=0 ; $i < $len ; $i=$i+80 )
		{
		$li0=substr($marker,$i,80);
		$li1=substr($l1,(28*$i),(28*80));
		$li2=substr($l2,(28*$i),(28*80));
		$l3=substr($match,$i,80);
		$l4=substr($pred_seq,$i,80);
		$num=$i+80; 
		$num = "" if($i > $len-80);
		print "<p style='font-size:125%;'>        <b>$li0</b><br>  Pred: <b>$li1</b> $num<br>Assign: <b>$li2</b><br>        $l3<br>    AA: $l4</p><br><br>";
		}
		print "</pre></div></centre>";
	  
    print "</div>";
	
	print"<div class= 'card'>";
     print" <center><h2>Scores</h2></center>";

	  print "<p>Total match score : $match_score</p>";
	  print "<p>Total contradiction score : $contra_score</p>";
	  print "<center><div style = 'margin-left: 10px;margin-right: 10px;width: 30%;background: linear-gradient(to bottom, #ffffff 0%, #99ccff 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3>Helix content</h3></center>";
	  
	  print "<table>";
      print "<tr><td>Prediction </td><td>$pred_percent[0]</td></tr>";
	  print "<tr><td>3D structure </td><td>$assi_percent[0]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[0]</td></tr>";
	  print "</table> </div>";
	 	  
	  print "<div style = 'margin-left: 10px;margin-right: 10px;width: 30%;background: linear-gradient(to bottom, #ffffff 0%, #ff9999 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3>Sheet content</h3></center>";
	  
	  print "<table>";
      print "<tr><td>Prediction </td><td>$pred_percent[1]</td></tr>";
	  print "<tr><td>3D structure </td><td>$assi_percent[1]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[1]</td></tr>";
	  print "</table>";
	  print "</div>";
	  
	  print "<div style = 'margin-left: 10px;margin-right: 10px;width: 30%;background: linear-gradient(to bottom, #ffffff 0%, #ffff99 100%);display: inline-block;margin-bottom: 25px;text-align: center;'>";
	  print "<center><h3>Coil content</h3></center>";
	  
	  print "<table>";
      print "<tr><td>Prediction </td><td>$pred_percent[2]</td></tr>";
	  print "<tr><td>3D structure </td><td>$assi_percent[2]</td></tr>";
	  print "<tr style= 'color: red;'><td>Difference </td><td>$diff_percent[2]</td></tr>";
	  print "</table>";
	  print "</div></center>";
print <<B4;	
    <p><a href="../../CoSec/PreSSM/about.html#scores" target="_blank">Click here to know more about the scores</a></p>  
    </div>
	
  </div>
  <div class="rightcolumn">
    
    
	
    <div class="card" style = "background: linear-gradient(to bottom, #66ff33 0%, #009900 100%); color: white;">
      <center><h3>MATCH SCORE</h3>
B4
      print "<h1>$match_score<h1></center>";
      print "</div>";
	  
	  
	  print "<div class=\"card\" style = \"background: linear-gradient(to bottom, #ff6600 0%, #ff0000 100%); color: white;\">";
      print "<center><h3>CONTRADICTION SCORE</h3>";
      print "<h1>$contra_score<h1></center></div>";
	  
print <<B5;
    <div class="card">
      <center><h3>Legends</h3></center>
      <div class="btn-group">
  <button class="button" style = "background-color: #0000CC;">Helix</button>
  <button class="button" style = "background-color: #FF0000;">Sheet</button>
  <button class="button" style = "background-color: #FFFF00;color: black;">Coil</button>
  </div>
    </div>
  </div>
</div>
	  <div style ="background-color: #D20050 ;padding: 20px;width:100%;margin-top: 25px;color: white"> 
	  <table class="defaulttable" style="width: 100%;">
     <tr><td> Copyright &#9400; 2019 Ayaluru Murali | Ankur Chaurasia | All Rights Reserved </td><td style =" float: right;"> Centre for Bioinformatics | Pondicherry University </td></tr>
	 <tr><td height="50" valign="bottom"> Header background image by <a href="https://pixabay.com/users/DavidZydd-985081/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2484170" target="_blank">David Zydd</a>, Webpage designing learned from <a href="https://www.w3schools.com/" target="_blank">w3schools</a>.</td></tr>
	 </table>
      </div>
  </div>
</body>
</html>
B5

#________________________________________________________________________________________________________________________

#printing job status in file if success

$stat =$dir."/database/job_logs.csv";
open (STA,'>>',"$stat") or die;

print STA "\n$username,$task_name,$method,$len,$time,$status,$error";

exit;


end:

#printing job status in file if failed

$stat =$dir."/database/job_logs.csv";
open (STA,'>>',"$stat") or die;

print STA "\n$username,$task_name,$method,$len,$time,$status,$error";

#Printing error messages on webpage

print <<B2;
<!DOCTYPE html>
<html lang="en-US">
<head profile="PreSSM"><title>OOps Error!</title>
<link rel="icon" type="image/png" href="../../CoSec/PreSSM/Images/logo.png">
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
  color: #D20050;
  text-decoration: none;
}

/* visited link */
a:visited {
  color: #D20050;
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
	print "<img src=\"../../CoSec/PreSSM/Images/toolmark.png\" alt=\"PreSSM\" style=\"width: 30%;display: block; margin-left: auto; margin-right: auto;margin-top: 110px;\">";
	print "</body></center></html>";
