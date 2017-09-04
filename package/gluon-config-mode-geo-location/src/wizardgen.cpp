#include <sstream>
#include<string>
#include <iostream>


using namespace std;

int main() {
  stringstream s;

  s << "return function(form, uci)" << endl;
  s << "\tlocal site = require 'gluon.site'" << endl;
  s << "" << endl;
  s << "\tlocal location = uci:get_first(\"gluon-node-info\", \"location\")" << endl;
  s << "" << endl;
#ifdef WITHMAP
  s << "\tlocal function show_lon()" << endl;
  s << "\t\tif site.config_mode.geo_location.map_lon(true) then" << endl;
  s << "\t\t\treturn site.config_mode.geo_location.map_lon" << endl;
  s << "\t\tend" << endl;
  s << "\t\treturn 0.0 -- check ob pos reboot fest" << endl;
  s << "\tend" << endl;
  s << "" << endl;
  s << "\tlocal function show_lat()" << endl;
  s << "\t\tif site.config_mode.geo_location.map_lat(true) then" << endl;
  s << "\t\t\treturn site.config_mode.geo_location.map_lat" << endl;
  s << "\t\tend" << endl;
  s << "\t\treturn 0.0 -- check ob pos reboot fest" << endl;
  s << "\tend" << endl;
  s << "" << endl;
#endif
  s << "\tlocal function show_altitude()" << endl;
  s << "\t\tif site.config_mode.geo_location.show_altitude(true) then" << endl;
  s << "\t\t\treturn true" << endl;
  s << "\t\tend" << endl;
  s << "\t\treturn uci:get_bool(\"gluon-node-info\", location, \"altitude\")" << endl;
  s << "\tend" << endl;
  s << "" << endl;
#ifdef WITHMAP
  s << "\tlocal function show_olurl()" << endl;
  s << "\t\tif site.config_mode.geo_location.olurl(true) then" << endl;
  s << "\t\t\treturn site.config_mode.geo_location.olurl" << endl;
  s << "\t\tend" << endl;
  s << "\t\treturn 'http://dev.openlayers.org/OpenLayers.js'" << endl;
  s << "\tend" << endl;
  s << "" << endl;
#endif
  s << "\tlocal text = translate(" << endl;
  s << "\t\t'If you want the location of your node to be displayed on the map, you can ' .." << endl;
#ifdef WITHGELOC
  s << "\t\t'set an automatically localization of your router or ' .." << endl;
#endif
  s << "\t\t'enter its coordinates here. ' .." << endl;
#ifdef WITHMAP
  s << "\t\t'If your PC is connected to the internet you can also click on the map displayed below. ' .." << endl;
#endif
  s << "\t\t'Please keep in mind setting a location can also enhance the network quality.'" << endl;
  s << "\t)" << endl;
  s << "\tif show_altitude() then" << endl;
  s << "\t\ttext = text .. ' ' .. translate(\"gluon-config-mode:altitude-help\")" << endl;
  s << "\tend" << endl;
  s << "" << endl;
#ifdef WITHMAP
  s << "\ttext = text .. [[" << endl;
  s << "\t\t<div id=\"locationPickerMap\" style=\"width:100%; height:300px; display: none;\"></div>" << endl;
  s << "\t\t<script src=\"]] .. show_olurl() .. [[\"></script>" << endl;
  s << "\t\t<script src=\"/static/gluon/osm.js\"></script>" << endl;
  s << "\t\t<script>" << endl;
  s << "\t\t\tvar latitude=]] .. show_lon() .. \",longitude=\" .. show_lat() .. [[;" << endl;
  s << "\t\t\tdocument.addEventListener(\"DOMContentLoaded\", showMap, false);" << endl;
  s << "\t\t\tsetInterval(function() {" << endl;
  s << "\t\t\t\tif(false !== findObj(\"longitude\")) {" << endl;
  s << "\t\t\t\t\tdocument.getElementById(\"locationPickerMap\").style.display=\"block\";" << endl;
  s << "\t\t\t\t}else{" << endl;
  s << "\t\t\t\t\tdocument.getElementById(\"locationPickerMap\").style.display=\"none\";" << endl;
  s << "\t\t\t\t}" << endl;
  s << "\t\t\t}, 1000);" << endl;
  s << "\t\t</script>" << endl;
  s << "\t]]" << endl;
  s << "" << endl;
#endif
  s << "\tlocal s = form:section(Section, nil, text)" << endl;
  s << "" << endl;
  s << "" << endl;
  s << "\tlocal geolocation = s:option(ListValue, \"geolocation\", translate(\"Geo-Location\"))" << endl;
#ifdef WITHGELOC
  s << "\tgeolocation:value(\"automatic\", translate(\"Automatic (geolocator)\"))" << endl;
#endif
  s << "\tgeolocation:value(\"static\", translate(\"Static location\"))" << endl;
#ifdef WITHGELOC
  s << "\tgeolocation:value(\"auto_static\", translate(\"Automatic & Static\"))" << endl;
#endif
  s << "\tgeolocation:value(\"none\", translate(\"Disabled\"))" << endl;
#ifdef WITHGELOC
  s << "\tlocal auto_location = uci:get_bool(\"geolocator\", \"stettings\", \"auto_location\")" << endl;
  s << "\tlocal static_location = uci:get_bool(\"geolocator\", \"stettings\", \"static_location\")" << endl;
  s << "\tif auto_location == false and static_location == true then" << endl;
#else
  s << "\tlocal lat = uci:get(\"geolocator\", \"stettings\", \"latitude\")" << endl;
  s << "\tlocal lon = uci:get(\"geolocator\", \"stettings\", \"longitude\")" << endl;
  s << "\tif lat ~= nil and lon ~= nil then" << endl;
#endif
  s << "\t\tgeolocation.default = \"static\"" << endl;
#ifndef WITHGELOC
  s << "\telse" << endl;
  s << "\t\tgeolocation.default = \"none\"" << endl;
#endif
  s << "\tend" << endl;
#ifdef WITHGELOC
  s << "\tif auto_location == true and static_location == true then" << endl;
  s << "\t\tgeolocation.default = \"auto_static\"" << endl;
  s << "\tend" << endl;
  s << "\tif auto_location == false and static_location == false then" << endl;
  s << "\t\tgeolocation.default = \"none\"" << endl;
  s << "\tend" << endl;
#endif
  s << "" << endl;
  s << "\tlocal share_location = s:option(Flag, \"sharelocation\", translate(\"Share your location to see your router on the map\"))" << endl;
  s << "\tshare_location.default = uci:get_bool(\"gluon-node-info\", location, \"share_location\")" << endl;
#ifdef WITHGELOC
  s << "\tshare_location:depends(geolocation, \"automatic\")" << endl;
#endif
  s << "\tshare_location:depends(geolocation, \"static\")" << endl;
#ifdef WITHGELOC
  s << "\tshare_location:depends(geolocation, \"auto_static\")" << endl;
#endif
  s << "" << endl;
#ifdef WITHGELOC
  s << "\t--[[ -- Aktuell nicht verfügbar" << endl;
  s << "\to = s:option(DummyValue, \"automatic_disc\", \" \", translatef(\"Automaticaly location service over wifi.\"))" << endl;
  s << "\to:depends(geolocation, \"automatic\")" << endl;
  s << "\to.description = translatef(\"Automaticaly location service over wifi.\")" << endl;
  s << "\t--]]" << endl;
  s << "" << endl;
  s << "\tlocal interval = s:option(Value, \"interval\", translate(\"Interval in minutes\"), translatef(\"Set refresh interval, the default is once per day\"))" << endl;
  s << "\tinterval.default = uci:get_first(\"geolocator\", \"stettings\", \"refresh_interval\")" << endl;
  s << "\tinterval:depends(geolocation, \"automatic\")" << endl;
  s << "\tinterval:depends(geolocation, \"auto_static\")" << endl;
  s << "\tinterval.datatype = \"uinteger\"" << endl;
  s << "" << endl;
#endif
  s << "\tlocal latitude = s:option(Value, \"latitude\", translate(\"Latitude\"), translatef(\"e.g. %s\", \"50.364931\"))" << endl;
  s << "\tlatitude.default = uci:get(\"gluon-node-info\", location, \"latitude\")" << endl;
  s << "\tlatitude:depends(geolocation, \"static\")" << endl;
#ifdef WITHGELOC
  s << "\tlatitude:depends(geolocation, \"auto_static\")" << endl;
#endif
  s << "\tlatitude.datatype = \"float\"" << endl;
  s << "" << endl;
  s << "\tlocal longitude = s:option(Value, \"longitude\", translate(\"Longitude\"), translatef(\"e.g. %s\", \"7.606417\"))" << endl;
  s << "\tlongitude.default = uci:get(\"gluon-node-info\", location, \"longitude\")" << endl;
  s << "\tlongitude:depends(geolocation, \"static\")" << endl;
#ifdef WITHGELOC
  s << "\tlongitude:depends(geolocation, \"auto_static\")" << endl;
#endif
  s << "\tlongitude.datatype = \"float\"" << endl;
  s << "" << endl;
  s << "\tlocal altitude;" << endl;
  s << "\tif show_altitude() then" << endl;
  s << "\t\taltitude = s:option(Value, \"altitude\", translate(\"gluon-config-mode:altitude-label\"), translatef(\"e.g. %s\", \"11.51\"))" << endl;
  s << "\t\taltitude.default = uci:get(\"gluon-node-info\", location, \"altitude\")" << endl;
  s << "\t\taltitude:depends(geolocation, \"static\")" << endl;
#ifdef WITHGELOC
  s << "\t\taltitude:depends(geolocation, \"auto_static\")" << endl;
#endif
  s << "\t\taltitude.datatype = \"float\"" << endl;
  s << "\t\taltitude.optional = true" << endl;
  s << "\tend" << endl;
  s << "\tfunction geolocation:write(data)" << endl;
#ifdef WITHGELOC
  s << "\t\tif data == \"automatic\" or data == \"auto_static\" then" << endl;
  s << "\t\t\tuci:set(\"geolocator\", \"stettings\", \"auto_location\", 1)" << endl;
  s << "\t\t\tif interval.data ~= nil and tonumber(interval.data) >= 1 and tonumber(interval.data) <= 43200 then" << endl;
  s << "\t\t\t\tuci:set(\"geolocator\", \"stettings\", \"refresh_interval\", interval.data)" << endl;
  s << "\t\t\telseif tonumber(interval.data) > 43200 then" << endl;
  s << "\t\t\t\tuci:set(\"geolocator\", \"stettings\", \"refresh_interval\", 43200)" << endl;
  s << "\t\t\tend" << endl;
  s << "\t\telse" << endl;
  s << "\t\t\tuci:set(\"geolocator\", \"stettings\", \"auto_location\", 0)" << endl;
  s << "\t\tend" << endl;
  s << "\t\tif data == \"static\" or data == \"auto_static\" then" << endl;
  s << "\t\t\tuci:set(\"geolocator\", \"stettings\", \"static_location\", 1)" << endl;
#else
  s << "\t\tif data == \"static\" then" << endl;
#endif
  s << "\t\t\tuci:set(\"gluon-node-info\", location, \"latitude\", latitude.data)" << endl;
  s << "\t\t\tuci:set(\"gluon-node-info\", location, \"longitude\", longitude.data)" << endl;
  s << "\t\t\tif show_altitude() then" << endl;
  s << "\t\t\t\tif altitude.data then" << endl;
  s << "\t\t\t\t\tuci:set(\"gluon-node-info\", location, \"altitude\", altitude.data)" << endl;
  s << "\t\t\t\telse" << endl;
  s << "\t\t\t\t\tuci:delete(\"gluon-node-info\", location, \"altitude\")" << endl;
  s << "\t\t\t\tend" << endl;
  s << "\t\t\tend" << endl;
#ifdef WITHGELOC
  s << "\t\telse" << endl;
  s << "\t\t\tuci:set(\"geolocator\", \"stettings\", \"static_location\", 0)" << endl;
#endif
  s << "\t\tend" << endl;
  s << "\t\tif data == \"none\" then" << endl;
  s << "\t\t\tuci:delete(\"gluon-node-info\", location, \"altitude\")" << endl;
  s << "\t\t\tuci:delete(\"gluon-node-info\", location, \"latitude\")" << endl;
  s << "\t\t\tuci:delete(\"gluon-node-info\", location, \"longitude\")" << endl;
  s << "\t\t\tuci:set(\"gluon-node-info\", location, \"share_location\", 0)" << endl;
#ifdef WITHGELOC
  s << "\t\t\tuci:set(\"geolocator\", \"stettings\", \"auto_location\", 0)" << endl;
#endif
  s << "\t\telse" << endl;
  s << "\t\t\tuci:set(\"gluon-node-info\", location, \"share_location\", share_location.data)" << endl;
  s << "\t\tend" << endl;
  s << "\tend" << endl;
  s << "" << endl;
  s << "\treturn {'gluon-node-info'";
#ifdef WITHGELOC
  s << ", 'geolocator'}" << endl;
#else
  s << "}" << endl;
#endif
  s << "end" << endl;

  cout << s.str();
  return 0;
}
