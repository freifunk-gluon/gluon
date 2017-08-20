#include <sstream>
#include<string>
#include <iostream>

using namespace std;

int main() {
  stringstream s;

  s << "if need_table('config_mode', nil, false) and need_table('config_mode.geo_location', nil, false) then" << endl;
  s << "\tneed_boolean('config_mode.geo_location.show_altitude', false)" << endl;
#ifdef WITHMAP
  s << "\tneed_string('config_mode.geo_location.olurl', false)" << endl;
  s << "\tneed_number('config_mode.geo_location.map_lon', false)" << endl;
  s << "\tneed_number('config_mode.geo_location.map_lat', false)" << endl;
#endif
  s << "end" << endl;
  cout << s.str();
  return 0;
}
