# gluon-config-mode-autoupdater-freifunk

The package gluon-config-mode-autoupdater-freifunk provides an
 alternative to both gluon-config-mode-autoupdater and gluon-web-autoupdater.
By replacing both packages, gluon-config-mode-autoupdater-freifunk it cannot be installed in combination: Both
have to be missing from site.mk.
 
Users are asked for consent before enabling automatic updates. This follows (Freifunk's 
Memorandum of understanding)[https://github.com/freifunk/MoU]. The question is asked using radio-buttons without any defaults. It is neither opt-in nor opt-out.

To maintain compatibility with existing setups and keep defaults, enabling updates and giving consent is handled differently.

* By giving or revoking consent, users can enable or disable automatic updates
* If automatic-updates are enabled, but consent is not given, 
a message is shown telling, that consent was given out of band. By that, defaults from gluon-config-mode-autoupdater 
and gluon-web-autoupdater are implemented.
* If consent is given, but updates are disabled (e.g. manually using the shell), the form is inactive.


By default, the dialog uses (slightly modified) texts from the Freifunk MoU. The texts can be adjusted using site-specific 
i18n-files. 

These texts are used:

| Key (e.g. in `site/i18n/de.po` )  | English  | German  |   
|---|---|---|
| autoupdater-freifunk:description  | Node operators have the choice to allow remote maintenance. Interventions on the nodes via automatic firmware upgrades are done with explicit agreement of the respective operators. You can configure automatic updates in the <a href="/cgi-bin/config/admin/autoupdater"> Advanced settings</a> section.  | Die Knotenbetreiber*innen haben die Wahl, sich für Fernwartung zu entscheiden. Eingriffe in die Knoten, z.B. Firmwareupdates oder andere Fernwartungsarbeiten geschehen immer mit dem ausdrücklichen Einverständnis der jeweiligen Betreibenden. Weitere Einstellungen findest Du im Bereich <a href="/cgi-bin/config/admin/autoupdater">Erweiterte Einstellungen</a>.  |
| autoupdater-freifunk:constent_assumed  | <p /><span style="color:red">You have already agreed to remote maintenance via automatic upgrades by downloading and using this software.</span>  | <p /><span style="color:red">Du hast Dich schon mit dem Download und der Benutzung dieser Firmware für eine Fernwartung mittels automatischer Updates entschieden. </span>  |
| autoupdater-freifunk:disabled_on_shell  | <p />You have disabled automatic updates after giving consent.  | <p />Du hast zugestimmt, aber die Updates ausgeschaltet.  | 
| autoupdater-freifunk:option_dissent  | Disable - I do not agree  |  Deaktivieren - ich stimme nicht zu | 
| autoupdater-freifunk:option_consent  | Enable - I agree  | Aktivieren - ich stimme zu  | 
| autoupdater-freifunk:option_name  | Remote Maintenance via Automatic Updates  | Fernwartung mittels automatischer Updates  | 
| autoupdater-freifunk:description_admin  | Node operators have the choice to allow remote maintenance. Interventions on the nodes via automatic firmware upgrades are done with explicit agreement of the respective operators.  |  Die Knotenbetreiber*innen haben die Wahl, sich für Fernwartung zu entscheiden. Eingriffe in die Knoten, z.B. Firmwareupdates oder andere Fernwartungsarbeiten geschehen immer mit dem ausdrücklichen Einverständnis der jeweiligen Betreibenden.  | 
| autoupdater-freifunk:constent_assumed_admin |  <p /><span style="color:red">You have already agreed to remote maintenance via automatic upgrades by downloading and using this software. <br /> You can disable automatic updates by selecting no branch. </span> | <p /><span style="color:red">Du hast Dich schon mit dem Download und der Benutzung dieser Firmware für eine Fernwartung mittels automatischer Updates entschieden. <br /> Du kannst den Auto-Updater deaktivieren, indem Du keinen Branch auswählst. </span>  | 
| autoupdater-freifunk:disabled_on_shell_admin  | <p />You have manually disabled automatic updates after giving consent.  | <p />Du hast zugestimmt, aber die Updates manuell ausgeschaltet (z.B. per shell)  | 
