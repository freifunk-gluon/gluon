#include <sstream>
#include<string>
#include <iostream>

using namespace std;

int main() {
  stringstream s;

  s << "msgid \"\"" << endl;
  s << "msgstr \"\"" << endl;
#ifdef WITHMAP
#ifdef WITHGELOC
  s << "\"Project-Id-Version: gluon-config-mode-geo-location-with-geloc-map\\n\"" << endl;
#else
  s << "\"Project-Id-Version: gluon-config-mode-geo-location-with-map\\n\"" << endl;
#endif
#else
#ifdef WITHGELOC
  s << "\"Project-Id-Version: gluon-config-mode-geo-location-with-geloc\\n\"" << endl;
#else
  s << "\"Project-Id-Version: gluon-config-mode-geo-location\\n\"" << endl;
#endif
#endif
  s << "\"PO-Revision-Date: 2017-08-22 12:14+0100\\n\"" << endl;
  s << "\"Last-Translator: Jan-Tarek Butt <tarek@ring0.de>\\n\"" << endl;
  s << "\"Language-Team: German\\n\"" << endl;
  s << "\"Language: de\\n\"" << endl;
  s << "\"MIME-Version: 1.0\\n\"" << endl;
  s << "\"Content-Type: text/plain; charset=UTF-8\\n\"" << endl;
  s << "\"Content-Transfer-Encoding: 8bit\\n\"" << endl;
  s << "\"Plural-Forms: nplurals=2; plural=(n != 1);\\n\"" << endl << endl;

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
  s << "msgstr \"\"" << endl;
  s << "\"Um Deinen Router auf der Karte anzeigen zu können, benötigen wir seine \"" << endl;
  s << "\"Koordinaten. Hier hast Du die Möglichkeit, ";
#ifdef WITHGELOC
  s << "das der Router seine Position automatisch \"" << endl;
  s << "\"bestimmt. Eine andere Option ist, ";
#endif
  s << "die Koordinaten händisch zu hinterlegen.\"" << endl;
#ifdef WITHMAP
  s << "\"Wenn dein Computer mit dem du den Router einrichtes am Internet angeschlossen ist, \"" << endl;
  s << "\"hast du die Möglichkeit auf der unten angezeigten Karte an die stelle zu klicken wo \"" << endl;
  s << "\"der Router Stehen wird.\"" << endl;
#endif
  s << "\"Bitte berücksichtige das, das setzen einer Position die Netzwerk Qualität verbessern kann.\"" << endl << endl;

  s << "msgid \"Geo-Location\"" << endl;
  s << "msgstr \"Geo-Position\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Automatic (geolocator)\"" << endl;
  s << "msgstr \"Automatisch (geolocator)\"" << endl << endl;
#endif

  s << "msgid \"Static location\"" << endl;
  s << "msgstr \"Manuelle Position\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Automatic & Static\"" << endl;
  s << "msgstr \"Automatisch & Manuell\"" << endl << endl;
#endif

  s << "msgid \"Disabled\"" << endl;
  s << "msgstr \"Deaktiviert\"" << endl << endl;

  s << "msgid \"Share your location to see your router on the map\"" << endl;
  s << "msgstr \"Position für die Karte freigeben\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Interval in minutes\"" << endl;
  s << "msgstr \"Intervall in Minuten\"" << endl << endl;
  s << "msgid \"Set refresh interval, the default is once per day\"" << endl;
  s << "msgstr \"Setze aktuallisierungs Intervall, der Standard Intervall ist einmal pro Tag\"" << endl << endl;
#endif

  s << "msgid \"Latitude\"" << endl;
  s << "msgstr \"Breitengrad\"" << endl << endl;

  s << "msgid \"Longitude\"" << endl;
  s << "msgstr \"Längengrad\"" << endl << endl;

  s << "msgid \"e.g. %s\"" << endl;
  s << "msgstr \"z.B. %s\"" << endl;

  cout << s.str();
  return 0;
}
