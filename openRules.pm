package openRules;

use strict;
use warnings;
use UUID;
use JSON;
use YAML::XS 'LoadFile';


# YAML integration


# GLOBAL

my $configPath = "config.yaml";

my $mainrulespath = "rules/";
my $mapspath = "maps/";
my $nodes = "nodes.list";
my $maps = "maps.list";
my $mapsandnodes = "mapsnodes.list";
my $sources = "sources.list";
my $user = "jose";

my $action = shift;
my $itemid = shift;
my $value = shift;


sub handle_error {
  print "Error, please review\n";
}

sub readConfig {
  print "read config\n";
  my $config = LoadFile($configPath);

  for (keys %{$config->{credentials}}) {
      print "$_: $config->{credentials}->{$_}\n";
  }
}

sub getSrcRules {
  my $line = "";
  print "reading Rules Set\n";
  open(FH,'<',$sources) || handle_error();  # typical open call
  while (defined($line = <FH>)) {
    chomp($line);
    my $cmd = `wget $line`;
  }
  close(FH);
  return "OK";
}

# MAPs

sub createMap {
  my $name = shift;
  print "Create Map: name, UUID\n";
  my $mapuuid = generateUUID();
  my %maphash = ('name' => $name , 'uuid' => $mapuuid);
  my $jsonname = toJson(\%maphash);
  writeToMapFile($jsonname);
  my $response = `mkdir $mapspath$mapuuid; cp -r $mapspath$mainrulespath* $mapspath$mapuuid/.`;
  print "new MAP UUID: $mapuuid\n";
  return "new MAP UUID: $mapuuid";
}

sub deleteMap {
  print "Delete Map: name\n";
}

sub exportMap {
  print "Export Map: name, UUID\n";
  my $map = shift;
}

# GROUPS

sub createGroup {
  print "create group: name, UUID\n";
  my $groupuuid = generateUUID();
  print "new group UUID: $groupuuid\n";
}

sub deleteGroup {
  print "delete group: name, UUID\n";
}

sub assignToGroup {
  print "assign to group: child UUID, Parent UUID\n";
}

sub removeFromGroup {
  print "remove from group: parent UUID, Child UUID\n";
}

# RULES

sub ruleExists {
  my $map = shift;
  my $sid = shift;
  print "does rule exist?\n";
  my $response = `cat $mapspath/$map/*.rules | grep $sid`;
  print "does rule exist? >> ".$response."\n";
  return "does rule exist? >> ".$response;
}

sub disableRule {
  print "disable Rule: sid, map\n";
  my $map = shift;
  my $sid = shift;
  if (ruleStatus($map, $sid) =~ /ENABLED/) {
    my $result = `sed -i '/sid:$sid/s/^/#/' $mapspath/$map/*.rules`;
  }

}

sub enableRule {
  print "enable Rule: sid, map\n";
  #sed -i '/sid:2523260/s/^#//' *.rules
  my $map = shift;
  my $sid = shift;
  if (ruleStatus($map, $sid) =~ /DISABLED/) {
    my $result = `sed -i '/sid:$sid/s/^#//' $mapspath/$map/*.rules`;
  }
}

sub ruleStatus {
  print "Rule Status: sid, map\n";
  my $map = shift;
  my $sid = shift;
  my $cmd = "cat $mapspath/$map/*.rules | grep sid:$sid |  perl -n -e '/^(.)/ && \$1 eq ".'"#" ? print "DISABLED\n" : print "ENABLED\n"'."'";
  my $result = `$cmd`;
  chomp $result;
  if ($result eq "ENABLED" || $result eq "DISABLED") {
    print "rule status is >> $result \n";
    return "rule $sid is $result";
  } else {
    print ">> rule DOES NOT EXIST\n";
    return "DOES NOT EXIST";
  }
}

sub listMapRules {
  my $map = shift;
  print "list rules: map UUID, regex\n";
  my $cmd = "cat $mapspath$map/*.rules | perl -n -e'/^#.+msg:".'\"([^\"]+)\".+sid:(\d+)/ && print "'."\$1 - \$2".'\n"'."'";
  my $result = `$cmd`;
  # Parse result to provide a nice output
  print $result;
  return $result;
}

sub searchRules {
  print "search rules: regex\n";
  my $map = shift;
  my $regex = shift;

  my $result = `cat $mapspath$map/*.rules | egrep -i "$regex"`;
  print $result;
  return $result;
}

sub syncMap {
  my $map = shift;
  print "sync a map with all its nodes";
}

sub writeToMapFile {
  my $map = shift;
  my $result = `echo $map >> $maps`;
}

# NODES

sub writeToNodeFile {
  my $node = shift;
  my $result = `echo $node >> $nodes`;
}


sub listNodes {
  # Parse result as nice.
  my $result = `cat $nodes`;
}

sub registerNode {
  my $name = shift;
  my $ip = shift;
  my %nodehash = ('name' => $name , 'uuid' => generateUUID(), 'ip' => $ip);
  my $jsonname = toJson(\%nodehash);
  writeToNodeFile($jsonname);
  return $jsonname;
}

sub removeNode {
  print "remove node: name, ip\n";
}

sub writeToMapNodeFile {
  my $line = shift;
  my $result = `echo $line >> $mapsandnodes`;
}

sub assignMapToNode {
  my $map = shift;
  my $node = shift;
  my %nodehash = ('map' => $map , 'node' => $node);
  my $jsonname = toJson(\%nodehash);
  print "assign map to node: $jsonname\n";
  writeToMapNodeFile($jsonname);
  return $jsonname;
}

sub removeMapFromNode {
  print "SURE >> remove map from node\n";
}

sub getNodeMap {
  print "get node map: node UUID\n";
  # my $perl_scalar = from_json($json_text[, $optional_hashref])
  my $json = ""; # read node line from mapsnodes files.
  # parse $json to obtain Map
  my $map = from_json($json);

}

sub getMapNodes {
  my $map = shift;
  my @maps = ();
  my $line = "";
  my $maphash = "";
  print "get map nodes: map UUID\n";
  open(FH,'<',$mapsandnodes) || handle_error();
  while (defined($line = <FH>)) {
    chomp($line);
    if ($line =~ /$map/) {
      $maphash = fromJson($line);
      push @maps,$maphash->{"map"};
      last;
    }
  }
  close(FH);
  return @maps;
}

sub getNodeIp {
  my $node = shift;
  my $line = "";
  my $nodeIP = "NONE";
  my $nodehash = "";
  print "get Node IP from nodes file\n";
  open(FH,'<',$nodes) || handle_error();
  while (defined($line = <FH>)) {
    chomp($line);
    if ($line =~ /$node/) {
      $nodehash = fromJson ($line);
      $nodeIP = $nodehash->{"ip"};
      last;
    }
  }
  close(FH);
  return $nodeIP;
}

sub sendMapToNode {
  print "send Map to its node\n";
  my $node = shift;
  my $map = shift;
  my $nodeIP = getNodeIp ($node);
  # TODO This should be done by API no openRules. sendFileToNode(file,ip);
  my $cmd = `scp $node$map.tar.gz $user@$nodeIP:/var/owlhnode/etc/$node$map.tar.gz`;
}

sub restartNode {
  my $nodeip = shift;
  print "restart NODE IDS\n";
  # TODO must be done from API.
  my $cmd = `ssh $user@$nodeip "touch /var/owlhnode/etc/restartIDS"`;
}

sub syncNodeMap {
  print "sync node map: node uuid(all them if blank)\n";
  my $node = shift;
  my $map = getNodeMap($node);
  if ($map != /NONE/) {
    exportMap($node, $map);
    sendMapToNode($node, $map);
    restartNode($node);
  }
}

# UTILS

sub generateUUID {
  my $ug = "";
  my $string = "";
  UUID::generate($ug);
  UUID::unparse($ug, $string);
  return $string;
}

sub toJson {
  my $rec_hash = shift;
  my $json = encode_json $rec_hash;
  return $json;
}

sub fromJson {
  my $json = shift;
  my $rec_hash = decode_json $json;
  return $rec_hash;
}


# MAIN
1
