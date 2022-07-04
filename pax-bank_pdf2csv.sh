#!/usr/bin/env bash
### TODO: Shellsheck kommentare abarbeiten

#==============================================================================#
#
# Dieses Skript wandelt die Kontoauszüge der Pax-Bank
# aus dem PDF-Format erst das CSV-Format um.
#
# Es wird das Paket "poppler-utils" benötigt.
#
#==============================================================================#
#
# PDF -> TXT -> CSV
#
#==============================================================================#

#VERSION="v2017081103"
#VERSION="v2019082500"
#VERSION="v2020091200"		# Fehler behoben
VERSION="v2021060400"		# ♥ gegen ¶ ausgetauscht

#------------------------------------------------------------------------------#
### Funktionen

write2csv () {
	#======================================================================#
	### Gewonnene Daten aufbereiten und als Zeile in die CSV-Datei schreiben


	#--------------------------------------------------------
	### Datum um Jahreszahl ergänzen
	### Wenn VON_JAHR == BIS_JAHR dann BUCHUNG und WERT um Jahreszahl ergänzen
	if [ $VON_JAHR -eq $BIS_JAHR ]
	then
		###BUCHUNG um Jahreszahl ergänzen
		DATUM_BUCHUNG=$(echo "${BUCHUNG}${VON_JAHR}")
		###WERT um Jahreszahl ergänzen
		DATUM_WERT=$(echo "${WERT}${VON_JAHR}")
		###Wenn VON_JAHR < BIS_JAHR dann BUCHUNG und WERT um BIS_JAHR ergänzen, dann Kontoauszüge immer nur Monatsweise erstellt werden und von immer der letzte Tag des vorherigen Monats ist
	elif [ $VON_JAHR -lt $BIS_JAHR ]
	then
		###BUCHUNG um Jahreszahl ergänzen
		DATUM_BUCHUNG=$(echo "$BUCHUNG${BIS_JAHR}")
		###WERT um Jahreszahl ergänzen
		DATUM_WERT=$(echo "$WERT${BIS_JAHR}")
	else
		echo "Fehler: Jahreszahl konnte nicht erkannt werden: von $VON_JAHR bis $BIS_JAHR"
	fi
	# ###DEBUG
	# echo "
	# Buchungsdaten: '${BUCHUNGSDATEN}';
	# ========================================================
	# BETRAG='${BETRAG}';
	# --------------------------------------------------------
	# BUCHUNG='${BUCHUNG}';
	# DATUM_BUCHUNG='${DATUM_BUCHUNG}';
	# --------------------------------------------------------
	# WERT='${WERT}';
	# DATUM_WERT='${DATUM_WERT}';
	# --------------------------------------------------------
	# VORGANG='${VORGANG}';
	# --------------------------------------------------------
	# Verwendungszweck='${VERWENDUNGSZWECK}';
	# --------------------------------------------------------
	# "
	# exit

	#------------------------------------------------------------------------------#
	### Variablen zusammensetzen und in CSV-Datei schreiben
	### Reihenfolge der Ausgabe
	### Buchung;Wert;Vorgang;Absender;Verwendungszweck;Betrag;Haben/Soll;
	echo "${DATUM_BUCHUNG};${DATUM_WERT};${VORGANG};$ABSENDER;$VERWENDUNGSZWECK;${BETRAG};$HABEN_SOLL;" >> "${NEUERNAME}".csv

	#------------------------------------------------------------------------------#
	### Variablen aufräumen
	unset BUCHUNG
	unset WERT
	unset BETRAG
	unset VORGANG
	unset ABSENDER
	unset VERWENDUNGSZWECK
	unset HABEN_SOLL
	unset DATUM_BUCHUNG
	unset DATUM_WERT
}

#------------------------------------------------------------------------------#
### Eingabeüberprüfung

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [ -z "${1}" ] ; then
	echo "${0} Kontoauszug_der_Pax-Bank.pdf"
	exit 1
fi

#------------------------------------------------------------------------------#
### Kontoinhaber abfragen, um Zeilen mit dem Namen zu filtern

read -p "Bitte Kontoinhaber angeben : " KONTOINHABER

#------------------------------------------------------------------------------#
### Hinweis geben

echo "
================================================================================
=> das kann jetzt ein paar Minuten dauern ...
================================================================================
"

#==============================================================================#
VERZEICHNIS="$(dirname ${0})"

for PDFDATEI in "${@}"
do
	#======================================================================#
	### PDF -> TXT -> CSV

	#----------------------------------------------------------------------#
	### Dateiname ermitteln

	unset NEUERNAME
	### Dateiendung und Erstellungsdatum entfernen
	### 9999999_1970_Nr.006_Kontoauszug_vom_01.01.1970_197010101111111.pdf
	NEUERNAME="$(echo "${PDFDATEI}"  | sed 's/_[0-9]*[.]pdf//' )"

	#----------------------------------------------------------------------#
	### PDF -> TXT

	pdftotext -fixed 8 -enc UTF-8 -eol unix "${PDFDATEI}" "${NEUERNAME}".txt

	#----------------------------------------------------------------------#
	### Möglichst viel von Anfang und Ende des Kontoauszugs entfernen
	cat "${NEUERNAME}".txt | sed '1,/^     Bu-TagWertVorgang$/d' | sed '/Sehr geehrte Kundin, sehr geehrter Kunde,/,//d' > "${NEUERNAME}_.txt"

	#----------------------------------------------------------------------#
	### Datum gewinnen
	###                                alter Kontostand vom 01.01.1970 999.999,99 H
	###                                           erstellt am 01.01.1970
	VON_ZEILE="$(cat "${NEUERNAME}_.txt" | grep -Pa '                                alter Kontostand vom [0-3][0-9].[0-1][0-9].20[0-9][0-9]')"
	BIS_ZEILE="$(cat "${NEUERNAME}".txt | grep -Pa '                                          erstellt am [0-3][0-9].[0-1][0-9].20[0-9][0-9]' | head -1)"
	rm -f "${NEUERNAME}".txt
	#MONAT_JAHR_VON="$(echo "${VON_ZEILE}" | sed 's/.* vom //' | awk -F'.' '{print $3"-"$2"-"$1}')"
	#MONAT_JAHR_BIS="$(echo "${BIS_ZEILE}" | sed 's/.* bis //' | awk -F'.' '{print $3"-"$2"-"$1}')"
	VON_DATUM="$(echo "${VON_ZEILE}" | sed 's/.* vom //' | awk -F' ' '{print $1}')"
	BIS_DATUM="$(echo "${BIS_ZEILE}" | sed 's/.* am //')"
	VON_JAHR="$(echo "${VON_ZEILE}" | sed 's/.* vom //' | awk -F' ' '{print $1}' | awk -F'.' '{print $3}')"
	BIS_JAHR="$(echo "${BIS_ZEILE}" | sed 's/.* am //;s/.*[.]//')"

	# #----------------------------------------------------------------------#
	# ### DEBUG
	# echo "
	# ========================================================
	# VON_ZEILE='${VON_ZEILE}';
	# BIS_ZEILE='${BIS_ZEILE}';
	# --------------------------------------------------------
	# VON_DATUM='${VON_DATUM}';
	# BIS_DATUM='${BIS_DATUM}';
	# VON_JAHR='${VON_JAHR}';
	# BIS_JAHR='${BIS_JAHR}';
	# --------------------------------------------------------
	# "
	# exit

	#----------------------------------------------------------------------#
	### Überflüssige Zeilen entfernen
	#  Bu-TagWertVorgang
	#                             alter Kontostand vom 01.01.1970 99.999,99 H

	ZEILE_0='^.[ ]+Bu-TagWertVorgang$'
	ZEILE_1='^                                alter Kontostand vom [0-3][0-9].[0-1][0-9].20[0-9][0-9] \d*.\d*,[0-9][0-9] H$'

	#										Übertrag auf Blatt 2      99.999,99 H
	#0111
	#011
	#K00011111
	#5M 70          Bitte beachten Sie die Hinweise auf der Rückseite oder am Ende des Dokuments
	#                                          Pax Pecunia Plus
	#										EUR-Konto   Kontonummer 1111111111
	#	KONTOINHABER
	#										Kontoauszug           Nr. 5/1970
	#										erstellt am 01.01.1970
	#														22:06Blatt2 von 3
	ZEILE_2='^                                      Übertrag auf Blatt \d*[ ]*\d*.\d*,[0-9][0-9] H$'
	ZEILE_3='^0\d{3}$'
	ZEILE_4='^0\d{2}$'
	ZEILE_5='^K\d*$'
	ZEILE_6='^5M 70[ ]*Bitte beachten Sie die Hinweise auf der Rückseite oder am Ende des Dokuments$'
	ZEILE_7='^                                          Pax .*$'
	ZEILE_8='^                                          EUR-Konto   Kontonummer \d*$'
	ZEILE_9="^     ${KONTOINHABER}$"
	ZEILE_10='^                                          Kontoauszug           Nr. \d*\/[0-9]{4}$'
	ZEILE_11='^                                          erstellt am [0-3][0-9].[0-1][0-9].20[0-9][0-9]$'
	ZEILE_12='^                                                        [0-9][0-9]:[0-9][0-9]Blatt\d* von \d*$'
	ZEILE_13='^                                      Übertrag von Blatt \d*[ ]*\d*.\d*,[0-9][0-9] H$'
	ZEILE_14='^K\d*      Bitte beachten Sie die Hinweise auf der Rückseite oder am Ende des Dokuments$'
	VORVORLETZTE_ZEILE='^                                neuer Kontostand vom [0-3][0-9].[0-1][0-9].20[0-9][0-9] \d*.\d*,[0-9][0-9] H$'
	VORLETZTE_ZEILE='                    Der ausgewiesene Kontostand berücksichtigt nicht'
	LETZTE_ZEILE='                    die Wertstellung der einzelnen Buchungen.'
	#Regex leerezeile
	LEEREZEILE='^$'

	#ls -lha ${NEUERNAME}_.txt
	cat "${NEUERNAME}_.txt" | \
		grep -Pv "${ZEILE_0}" | \
		grep -Pv "${ZEILE_1}" | \
		grep -Pv "${ZEILE_2}" | \
		grep -Pv "${ZEILE_3}" | \
		grep -Pv "${ZEILE_4}" | \
		grep -Pv "${ZEILE_5}" | \
		grep -Pv "${ZEILE_6}" | \
		grep -Pv "${ZEILE_7}" | \
		grep -Pv "${ZEILE_8}" | \
		grep -Pv "${ZEILE_9}" | \
		grep -Pv "${ZEILE_10}" | \
		grep -Pv "${ZEILE_11}" | \
		grep -Pv "${ZEILE_12}" | \
		grep -Pv "${ZEILE_13}" | \
		grep -Pv "${ZEILE_14}" | \
		grep -Pv "${VORVORLETZTE_ZEILE}" | \
		grep -Fv "${VORLETZTE_ZEILE}" | \
		grep -Fv "${LETZTE_ZEILE}" | \
		grep -Pv "${LEEREZEILE}" > \
		"${NEUERNAME}".txt

		echo "###letzte Zeile###" >> "${NEUERNAME}".txt

	rm -f "${NEUERNAME}_.txt"


	#----------------------------------------------------------------------#
	### TXT -> CSV
	#
	### die Textdatei in Buchungsbloecke umwandeln
	### und diese dann in CSV-Zeilen umwandeln

	#----------------------------------------------------------------------#
	### CSV-Datei initialisieren

	# Konto-Informationen
	echo "Erstellt vom " "$VON_DATUM" " bis zum " "$BIS_DATUM" > "${NEUERNAME}.csv" 

	#----------------------------------------------------------------------#
	### Tabellenkopf

	### Originalreihenfolge
	#echo "Betrag;Vorgang/Buchungsinformation;Buchung;Wert;${MONAT_JAHR_VON};${MONAT_JAHR_BIS}" >> "${NEUERNAME}.csv"

	### bevorzugte Reihenfolge
	echo "Buchung;Wert;Vorgang;Absender;Verwendungszweck;Betrag;Haben/Soll;" >> "${NEUERNAME}.csv"

	#----------------------------------------------------------------------#
	### Textdatei Zeilenweise in das CSV-Format umwandeln

	#ls -lha  "${NEUERNAME}.txt"
	###     01.01. 01.01. Basislastschrift                               69,69 S
	###           Absender
	###           Verwendungszweck
	###           Verwendungszweck
	###           Verwendungszweck

	ls -lha  "${NEUERNAME}.txt"
	ZEILEN_ZAEHLER=0
	### IFS= damit führende Leerzeichen nicht automatisch entfernt werden
	cat  "${NEUERNAME}.txt" | while IFS= read -r ZEILE
	do
		### Leerzeichen am Anfang der Zeile zählen
		ANZAHL_LEERZEICHEN=$(echo "$ZEILE" | grep -o "^[ ]*" | wc -L)
		### String ZEILE aufräumen
		## Leerzeichen am Anfang entfernen
		ZEILE=$(echo $ZEILE | sed "s/^[ ]*//")
		## Mehrere Leerzeichen zu einem zusammenfassen
		ZEILE=$(echo $ZEILE | sed "s/[ ]{2,}/ /g")
		## Sonderfall "Kartenzahlung girocard" abfangen
		ZEILE=$(echo $ZEILE | sed "s/Kartenzahlung girocard/Kartenzahlung_girocard/g")
		## Sonderfall "Abschluss lt. Anlage 1" abfangen
		ZEILE=$(echo $ZEILE | sed "s/Abschluss lt. Anlage 1/Abschluss_lt._Anlage_1/g")
		#echo Zeile: "${ZEILE}"
		
		### Wenn ANZAHL_LEERZEICHEN == 5, dann neue Buchung. Ansonsten Buchungsinformation
		if [ "$ANZAHL_LEERZEICHEN" == 5 ]
		then
			### Neue Buchung/ CSV Zeile
			#echo "Neue Buchung erkannt"
			### Wenn ZEILEN_ZAEHLER > 0, dann Daten vom letzten Run in CSV-Zeile schreiben
			if [ $ZEILEN_ZAEHLER -gt 0 ]
			then
				write2csv
			fi
			VERWENDUNGSZWECK=""
			#echo "$ZEILE"
			BUCHUNGSDATEN=($ZEILE)
			BUCHUNG="${BUCHUNGSDATEN[0]}"
			WERT="${BUCHUNGSDATEN[1]}"
			VORGANG="${BUCHUNGSDATEN[2]}"
			BETRAG="${BUCHUNGSDATEN[3]}"
			HABEN_SOLL="${BUCHUNGSDATEN[4]}"

			## ZEILEN_ZAEHLER um 1 erhöhen
			ZEILEN_ZAEHLER=$((ZEILEN_ZAEHLER+1))
			INFO_ZEILEN_ZAEHLER=1
		else
			### Buchungsinformation
			#echo "Zusätzliche Buchungsinformation erkannt"

			### Wenn ZEILE == ###letzte Zeile###, dann letzte Buchung in CSV-Zeile schreiben
			if [ "$ZEILE" == "###letzte Zeile###" ]
			then
				write2csv
			fi

			### Wenn INFO_ZEILEN_ZAEHLER == 1, dann Absender. Ansonsten Verwendungszweck
			#echo $INFO_ZEILEN_ZAEHLER
			if [ $INFO_ZEILEN_ZAEHLER -eq 1 ]
			then
				### Absender
				ABSENDER=$(echo "$ZEILE")
				INFO_ZEILEN_ZAEHLER=$((INFO_ZEILEN_ZAEHLER+1))
			else
				### Verwendungszweck
				### Bisherigen Verwendungszweck um neue ZEILE erweitern
				VERWENDUNGSZWECK=$(echo "$VERWENDUNGSZWECK""$ZEILE")
				INFO_ZEILEN_ZAEHLER=$((INFO_ZEILEN_ZAEHLER+1))
			fi
			
		fi		
	done
	#exit

	#----------------------------------------------------------------------#
	### BOM setzen und aufräumen
	sed -i '1s/^/\xef\xbb\xbf/' "${NEUERNAME}.csv"
	rm -f  "${NEUERNAME}.txt"
	
	#----------------------------------------------------------------------#
	### Ergebnisse anzeigen

	ls -lha "${NEUERNAME}.csv"

done
#==============================================================================#

#------------------------------------------------------------------------------#
### Hinweise anzeigen

echo "
libreoffice --calc "${NEUERNAME}.csv"
------------------------------------------------------------------------"

#------------------------------------------------------------------------------#