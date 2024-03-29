package openRules;

#########
#########
# OLD ###
#########
#########
# Do not use this.

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
my $nodes = "nodes.json";
my $maps = "maps.json";
my $mapsandnodes = "mapsnodes.json";

my $action = shift;
my $itemid = shift;
my $value = shift;


sub readConfig {
  print "read config\n";
  my $config = LoadFile($configPath);

  for (keys %{$config->{credentials}}) {
      print "$_: $config->{credentials}->{$_}\n";
  }
}

sub getSrcRules {
  print "reading Rules Set\n";
  my $cmd = `wget https://rules.emergingthreats.net/open/suricata-4.0/emerging.rules.tar.gz`;
}

sub main {
  #print "hello\n";
  readConfig();

  #registerNode();
  #toJson();
  #print registerNode("manolo");
  #print "rule 2100448 disabled\n";
  #print "rule 2100448 enabled\n";
  #ruleExists($itemid);
  #print ruleStatus($itemid)."\n";

  if (!defined $action) {
    print "nothing to do .\n";
    exit;
  }

  if ($action eq "STATUS") {
    if ($itemid eq "ALL") {
      $itemid = $mainrulespath;
    }
    ruleStatus($itemid, $value);
  }

  if ($action eq "DISABLE") {
    if ($itemid eq "ALL") {
      $itemid = $mainrulespath;
    }
    disableRule($itemid, $value);
    ruleStatus($itemid, $value);
  }

  if ($action eq "ENABLE") {
    if ($itemid eq "ALL") {
      $itemid = $mainrulespath;
    }
    enableRule($itemid, $value);
    ruleStatus($itemid, $value);
  }

  if ($action eq "CREATEMAP") {
    createMap($itemid);
  }

  if ($action eq "LISTMAP") {
    if ($itemid eq "ALL") {
      $itemid = $mainrulespath;
    }
    listMapRules($itemid, $value);
  }

  if ($action eq "LISTNODES") {
    print listNodes();
  }

  if ($action eq "REGISTERNODE") {
    registerNode($itemid);
  }

  if ($action eq "SEARCHRULE") {
    if ($itemid eq "ALL") {
      $itemid = $mainrulespath;
    }
    searchRules($itemid, $value);
  }

  if ($action eq "GETSRCRULES") {
    print "Downloading main rules\n";
    getSrcRules();
  }



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
}

sub disableRule {
  print "disable Rule: sid, map\n";
  my $map = shift;
  my $sid = shift;
  if (ruleStatus($map, $sid) eq "ENABLED") {
    my $result = `sed -i '/sid:$sid/s/^/#/' $mapspath/$map/*.rules`;
  }

}

sub enableRule {
  print "enable Rule: sid, map\n";
  #sed -i '/sid:2523260/s/^#//' *.rules
  my $map = shift;
  my $sid = shift;
  if (ruleStatus($map, $sid) eq "DISABLED") {
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
    return $result;
  } else {
    print ">> rule DOES NOT EXIST\n";
    return "DOES NOT EXIST";
  }
}

sub listMapRules {
  my $map = shift;
  print "list rules: map UUID, regex\n";
  my $cmd = "cat $mapspath$map*.rules | perl -n -e'/^#.+msg:".'\"([^\"]+)\".+sid:(\d+)/ && print "'."\$1 - \$2".'\n"'."'";
  my $result = `$cmd`;
  print $result;
}

sub searchRules {
  print "search rules: regex\n";
  my $map = shift;
  my $regex = shift;

  my $result = `cat $mapspath$map*.rules | egrep -i "$regex"`;
  print $result;
  return $result;
}

# NODES

sub writeToNodeFile {
  my $node = shift;
  my $result = `echo $node >> $nodes`;
}

sub writeToMapFile {
  my $map = shift;
  my $result = `echo $map >> $maps`;
}

sub listNodes {
  my $result = `cat $nodes`;
}

sub registerNode {
  my $name = shift;
  my %nodehash = ('name' => $name , 'uuid' => generateUUID());
  my $jsonname = toJson(\%nodehash);
  writeToNodeFile($jsonname);
  return $jsonname;
}

sub removeNode {
  print "remove node: name, ip\n";
}

sub assignMapToNode {
  print "assign map to node: node uuid, map uuid\n";
}

sub removeMapFromNode {
  print "SURE >> remove map from node\n";
}

sub getNodeMap {
  print "get node map: node UUID\n";
}

sub getMapNodes {
  print "get map nodes: map UUID\n";
}

sub syncNodeMap {
  print "sync node map: node uuid(all them if blank)\n";
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



# MAIN
# main();
