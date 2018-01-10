#!/usr/bin/perl
use Dancer2;
use REST::Client;
use lib '.';
use openRules;
use Monitor;

set serializer => 'JSON';
get '/' => sub { return { res => "OWLH, API v1.0" };};
get '/uno' => sub { return {res => "OWLH API working and 43 nodes installed"}; };
get '/dos' => sub {
    return { res => {"yno","dos"} };
};



# user-specific routes, for example
prefix '/users' => sub {
   get '/view'     => sub {return {user => "list of users"};};
   get '/view/:id' => sub {
       my $id     = route_parameters->get('id');
       return {user => "user $id details" };
   };
   put '/add'      => sub {return {"user add" => "user added"};};
};

post '/:entity/:id' => sub {
    my $entity = route_parameters->get('entity');
    my $id     = route_parameters->get('id');

    # input which was sent serialized
    my $user = body_parameters->get('user');
    return {res => 200, $entity, $id};
};

get '/status' => sub {
    my $status = '{"suricata" => "green", "storage" => "green", "cpu" => "green", "mem" => "green", "forwarder" => "green"}';
    return {res => 200, status => $status};
};

get '/status/suricata' => sub {
	#my $status = '{"pid" => "126", "interface" => "ens33", "alerts 1h" => "567"}';
    my $status = Monitor::getSuricataResources();
    return {res => 200, status => $status};
};

get '/map/create/:name' => sub {
    my $name = route_parameters->get('name');
    my $status = openRules::createMap($name);
    return {res => 200, status => $status};
};

get '/map/:map/rule/exist/:rule' => sub {
    my $map = route_parameters->get('map');
    my $rule= route_parameters->get('rule');
    my $status = openRules::ruleExists($map,$rule);
    return {res => 200, status => $status};
};

get '/map/:map/rule/status/:rule' => sub {
    my $map = route_parameters->get('map');
    my $rule= route_parameters->get('rule');
    my $status = openRules::ruleStatus($map,$rule);
    return {res => 200, status => $status};
};

get '/map/:map/rule/disable/:rule' => sub {
    my $map = route_parameters->get('map');
    my $rule= route_parameters->get('rule');
    my $status = openRules::disableRule($map,$rule);
    $status = openRules::ruleStatus($map,$rule);
    return {res => 200, status => $status};
};

get '/map/:map/rule/enable/:rule' => sub {
    my $map = route_parameters->get('map');
    my $rule= route_parameters->get('rule');
    my $status = openRules::enableRule($map,$rule);
    $status = openRules::ruleStatus($map,$rule);
    return {res => 200, status => $status};
};

get '/map/:map/list' => sub {
    my $map = route_parameters->get('map');
    my $status = openRules::listMapRules($map);
    return {res => 200, status => $status};
};

get '/map/:map/search/:regex' => sub {
    my $map = route_parameters->get('map');
    my $regex= route_parameters->get('regex');
    my $status = openRules::searchRules($map,$regex);
    return {res => 200, status => $status};
};

get '/status/node01' => sub {
    my $client = REST::Client->new();
    $client->GET('http://192.168.1.216:3000/');
    return  {res => 200, node01 => $client->responseContent()};
};


dance;
