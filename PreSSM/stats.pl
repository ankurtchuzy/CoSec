#! C:\xampp\perl\bin\perl.exe
print "Content-Type: text/html\n\n";

#importing modules
use CGI(':standard');
use Cwd qw(cwd);

#Getting user informations
$admin_username = param ("name");
$password = param ("password");

#Verifying credintials

#if correct
if ( $admin_username eq 'PreSSM' && $password eq 'triangle'){

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
.button {
  background-color:#32CD32;
  color: rgb(60, 60, 60);
  margin-top: 25px;
  padding: 21px 5px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 20px;
  width: 60%;
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
  <a href="../../CoSec/PreSSM/stats.html">Stats</a>
  <a href="../../CoSec/new_user.html" style="float:right">Register</a>
</div>

<div style="border-radius: 10px;background-color: white;width:60%;margin: auto;margin-top: 25px;padding-top: 25px;padding-bottom: 25px;padding-left: 50px;padding-right: 50px;margin-top: 25px;">
<center><h2>Download the user profiles and job logs here</h2>
<a href = "database/profiles.csv" download = 'profiles.csv' ><button class= "button" >User Profiles</button></a>
<a href = "database/job_logs.csv" download = 'pressm_job_logs.csv' ><button class= "button" >PreSSM Job Logs</button></a>
<a href = "../CompASS/database/job_logs_compass.csv" download = 'compass_job_logs.csv' ><button class= "button" >CompASS Job Logs</button></a>
</div>
</div>

<div style ="background-color: #D20050 ;padding: 20px;width:100%;margin-top: 25px;color: white"> 
	  <table style="width: 100%;">
     <tr><td> Copyright &#9400; 2019 Ayaluru Murali | Ankur Chaurasia | All Rights Reserved </td><td style =" float: right;"> Centre for Bioinformatics | Pondicherry University </td></tr>
	 <tr><td height="50" valign="bottom"> Header background image by <a href="https://pixabay.com/users/DavidZydd-985081/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=image&amp;utm_content=2484170" target="_blank">David Zydd</a>, Webpage designing learned from <a href="https://www.w3schools.com/" target="_blank">w3schools</a>.</td></tr>
</table>
</div>
</body>
</html>

B1
}

#if incorrect
else{

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
  color: rgb(210, 0, 80,0.9);
  text-decoration: none;
}

/* visited link */
a:visited {
  color: rgb(210, 0, 80,0.9);
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
<h1>OOps Error!</h1><h2>Invalid username or password</h2>
<img src= "../../CoSec/PreSSM/Images/toolmark.png " alt= "PreSSM" style= "width: 30%;display: block; margin-left: auto; margin-right: auto;margin-top: 110px;">
</body></center></html>
B2

}


