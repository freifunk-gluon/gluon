#include <sstream>
#include<string>
#include <iostream>

using namespace std;

int main() {
  stringstream s;

  s << "msgid \"\"" << endl;
  s << "msgstr \"Content-Type: text/plain; charset=UTF-8\"" << endl << endl;
  s << "msgid \"\"" << endl;
  s << "\"If you want the location of your node to be displayed on the map, you can \"" << endl;
#ifdef WITHGELOC
  s << "\"set an automatically localization of your router or \"" << endl;
#endif
  s << "\"enter its coordinates here. \"" << endl;
#ifdef WITHMAP
  s << "\"If your PC is connected to the internet you can also click on the map displayed below. \"" << endl;
#endif
  s << "\"Please keep in mind setting a location can also enhance the network quality.\"" << endl;
  s << "msgstr \"\"" << endl << endl;
  s << "msgid \"Geo-Location\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#ifdef WITHGELOC
  s << "msgid \"Automatic (geolocator)\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#endif
  s << "msgid \"Static location\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#ifdef WITHGELOC
  s << "msgid \"Automatic & Static\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#endif
  s << "msgid \"Disabled\"" << endl;
  s << "msgstr \"\"" << endl << endl;
  s << "msgid \"Share your location to see your router on the map\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#ifdef WITHGELOC
  s << "msgid \"Interval in minutes\"" << endl;
  s << "msgstr \"\"" << endl << endl;
  s << "msgid \"Set refresh interval, the default is once per day\"" << endl;
  s << "msgstr \"\"" << endl << endl;
#endif
  s << "msgid \"Latitude\"" << endl;
  s << "msgstr \"\"" << endl << endl;
  s << "msgid \"Longitude\"" << endl;
  s << "msgstr \"\"" << endl << endl;
  s << "msgid \"e.g. %s\"" << endl;
  s << "msgstr \"\"" << endl;
  cout << s.str();
  return 0;
}
