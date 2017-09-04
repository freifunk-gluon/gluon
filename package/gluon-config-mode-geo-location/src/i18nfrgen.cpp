#include <sstream>
#include<string>
#include <iostream>

using namespace std;

int main() {
  stringstream s;

  s << "msgid \"\"" << endl;
  s << "msgstr \"\"" << endl;
  s << "\"Project-Id-Version: PACKAGE VERSION\\n\"" << endl;
  s << "\"PO-Revision-Date: 2017-08-22 12:14+0100\\n\"" << endl;
  s << "\"Last-Translator: Jan-Tarek Butt <tarek@ring0.de>\\n\"" << endl;
  s << "\"Language-Team: French\\n\"" << endl;
  s << "\"Language: fr\\n\"" << endl;
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
  s << "\"Si vous souhaitez que l'emplacement de votre nœud soit affiché sur la carte, vous pouvez \"" << endl;
#ifdef WITHGELOC
  s << "\"définir une localisation automatique de votre routeur ou \"" << endl;
#endif
  s << "entrer ses coordonnées ici.\"" << endl;
#ifdef WITHMAP
  s << "\"Si votre PC est connecté à Internet, vous pouvez également cliquer sur la carte ci-dessous.\"" << endl;
#endif
  s << "\"Gardez à l'esprit que la définition d'un emplacement peut également améliorer la qualité du réseau.\"" << endl << endl;

  s << "msgid \"Geo-Location\"" << endl;
  s << "msgstr \"Géolocalisation\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Automatic (geolocator)\"" << endl;
  s << "msgstr \"Automatique (geolocator)\"" << endl << endl;
#endif

  s << "msgid \"Static location\"" << endl;
  s << "msgstr \"position manuelle\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Automatic & Static\"" << endl;
  s << "msgstr \"Automatique et manuel\"" << endl << endl;
#endif

  s << "msgid \"Disabled\"" << endl;
  s << "msgstr \"Désactivé\"" << endl << endl;

  s << "msgid \"Share your location to see your router on the map\"" << endl;
  s << "msgstr \"Partagez votre emplacement pour voir votre routeur sur la carte\"" << endl << endl;

#ifdef WITHGELOC
  s << "msgid \"Interval in minutes\"" << endl;
  s << "msgstr \"Intervalle en minutes\"" << endl << endl;
  s << "msgid \"Set refresh interval, the default is once per day\"" << endl;
  s << "msgstr \"Définir l'intervalle de rafraîchissement, la valeur par défaut est une fois par jour\"" << endl << endl;
#endif

  s << "msgid \"Latitude\"" << endl;
  s << "msgstr \"Latitude\"" << endl << endl;

  s << "msgid \"Longitude\"" << endl;
  s << "msgstr \"Longitude\"" << endl << endl;

  s << "msgid \"e.g. %s\"" << endl;
  s << "msgstr \"Ex: %s\"" << endl;

  cout << s.str();
  return 0;
}
