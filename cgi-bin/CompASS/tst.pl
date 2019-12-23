#! /usr/bin/perl -w
BEGIN
{
  $ENV{BLASTDIR} = '/opt/lampp/cgi-bin/iep/';  # where my blastall binary is
  $ENV{BLASTDATADIR} = '/opt/lampp/cgi-bin/iep/' ; # where my -d are
}

use CGI::Carp qw(fatalsToBrowser);
use Bio::Tools::Run::StandAloneBlast; 
use Bio::Tools::Run::RemoteBlast; 
use Bio::SearchIO::Blast; 
use Bio::Perl; 
use Bio::Factory::ApplicationFactoryI; 
use Bio::Root::IO; 
use Bio::Root::Root; 
use Bio::SearchIO; 
use Bio::Seq; 
use Bio::SeqIO; 
use Bio::Tools::BPbl2seq; 
use Bio::Tools::BPpsilite; 
use Bio::Tools::Run::WrapperBase;
use Bio::Tools::Run::RemoteBlast;  
print"Content-type: text/html\n\n";

my $Seq_in = Bio::SeqIO->new (-file => 'mul.txt', -format => 'fasta'); 
my $query = $Seq_in->next_seq(); 
my $factory = Bio::Tools::Run::StandAloneBlast->new(-program => 'blastp', -database => 'sample.nt',  -outfile =>'test.html' ); 
my $blast_report = $factory->blastall($query); 
my $result = $blast_report->next_result; 
write_blast(">test.html",$result); 
