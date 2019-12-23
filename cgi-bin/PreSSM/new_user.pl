#! C:\xampp\perl\bin\perl.exe
print "Content-Type: text/html\n\n";

#importing modules
use CGI(':standard');
use Cwd qw(cwd);

#Document to store user profiles
$dir = cwd; #current working directory
$pro = $dir."../../CoSec/database/profiles.csv";


#Getting user informations
$name = param ("name");
$work = param ("work");
$institute = param ("institute");
$location = param ("location");
$email = param ("email");
$username = param ("username");
#Reading existing profiles
$flag = 0;
@values;
$heading;
$additional;

open (PRO,'<',"$pro") or die;

foreach (<PRO>)
	{
	@values = split(',',$_);
	if ($values[0] eq $username && $values[1] eq $email)
		{
		$heading ='Your user profile already exists';
		$additional ='You can go ahead and use <a href=\'../../CoSec/CoSec.html\'>CoSec</a> tools with this username.';
		$flag = 1;
		last;
		}
	elsif ($values[0] eq $username)
		{
		$heading ='This username already exists';
		$additional ='Try with another username. NOTE: you can use your email ID as username, they are usually unique.';
		$flag = 1;
		last;
		}
	elsif ($values[1] eq $email)
		{
		$heading ='This email ID is already registered';
		$additional ='If you forgot your username then <a href=\'../../CoSec/contact.html\'>contact</a> the admins with your registered email.';
		$flag = 1;
		last;
		}
    }
close PRO;

if ($flag == 0)
	{
	if ($username =~ /[^0-9a-zA-Z_]/)
		{
		$heading ='Your username contains special character';
		$additional ='Try again with a valid username';
		goto end;
		}
	
	if ($email =~ /@/ && $email =~ /\./)
		{
	open (PRO,'>>',"$pro") or die;
	print PRO "\n$username,$email,$name,$work,$institute,$location";
	close PRO;
	
print <<B1;
<!DOCTYPE html>
<html lang="en-US">
<head profile="CoSec"><title>Success!</title>
<link rel="icon" type="image/png" href="../../CoSec/cosec_logo.png">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body {
  font-family: Arial;
  padding-top: 10px;
  padding-right: 50px;
  padding-bottom: 20px;
  padding-left: 50px;
  
  }
  /* unvisited link */
a:link {
  color: #FF6600;
  text-decoration: none;
}

/* visited link */
a:visited {
  color: #FF6600;
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
B1

		print "<h1>Success!</h1><h2>Congratulations you have registered succesfully</h2><p>Now you can use our tools at <a href='../../CoSec/CoSec.html'>CoSec</a></p>";
		print "<img src=\"../../CoSec/cosec_logo.png\" alt=\"CoSec\"  style=\"width: 20%;display: block; margin-left: auto; margin-right: auto;margin-top: 50px;\">";
		print "</body></center></html>";
        exit;
		}
	else 
		{
		$heading ='This email ID is not valid';
		$additional ="Try again with a valid email ID";
		}
	}

end:
#Printing error messages on webpage

print <<B2;
<!DOCTYPE html>
<html lang="en-US">
<head profile="CoSec"><title>OOps Error!</title>
<link rel="icon" type="image/png" href="../../CoSec/cosec_logo.png">
<style>
body {
  font-family: Arial;
  padding-top: 10px;
  padding-right: 50px;
  padding-bottom: 20px;
  padding-left: 50px;
  
}
/* unvisited link */
a:link {
  color: #FF6600;
  text-decoration: none;
}

/* visited link */
a:visited {
  color: #FF6600;
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
	print "<img src=\"../../CoSec/cosec_logo.png\" alt=\"CoSec\" style=\"width: 20%;display: block; margin-left: auto; margin-right: auto;margin-top: 50px;\">";
	print "</body></center></html>";

