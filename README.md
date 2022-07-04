Pax-Bank_PDF2CSV
================

Dies ist ein Fork des Projekts Postbank_PDF2CSV von FlatheadV8, welches durch mich für die Pax-Bank angepasst wurde.

Leider kann man im Onlineportal der Pax-Bank (und auch per EBICS) seine Umsätze nur für die letzten 365 Tage als CSV runter runterladen. Braucht man mehr in einem elektronisch verarbeitbaren Format, dann muss man auf die Kontoauszüge zurückgreifen, die aber leider nur im nicht bearbeitbaren PDF-Format vorliegen. Um diese ins Text-Format und dann ins CSV-Format umzuwandeln, damit man sie in einer Tabellenkalkulation aufarbeiten kann, wurde das folgende Skript geschrieben.

PDF-Dateien mit Leezeichen, Umlaute, Sonderzeichen und/oder Klammern im Dateinamen wurden nicht getestet!

--------------------------------------------------------------------------------

Dieses Skript benötigt das Paket "pdftotext" welches Teil der "poppler-utils" ist. Dieses muss installiert werden!

--------------------------------------------------------------------------------
Vorbereitungen/Installationen mit Ubuntu 14.04 bzw. Mint 17
-----------------------------------------------------------

Es wird das Kommando "bash" benötigt, das ist in der Basisinstallation der meisten Linux-Distributionen bereits vorhanden.

Darüber hinaus wird lediglich das Kommando "pdftohtml" benötigt, um es zu installieren, muss das folgende Installationskommando ausgeführt werden:
    
    apt-get update ; apt-get -y install poppler-utils

--------------------------------------------------------------------------------
Vorbereitungen/Installationen mit FreeBSD 10
--------------------------------------------

Es wird das Kommando "bash" benötigt, um es zu installieren, muss das folgende Installationskommando ausgeführt werden:
    
    pkg install shells/bash
    ln -s /usr/local/bin/bash /bin/bash

Darüber hinaus wird lediglich das Kommando "pdftohtml" benötigt, um es zu installieren, muss das folgende Installationskommando ausgeführt werden:
    
    pkg install graphics/poppler-utils

--------------------------------------------------------------------------------
Anwendung
--------------------------------------------

beispielsweise könnte man das so machen,
als erstes die neueste Version saugen:
    
    git clone https://github.com/ComictypX/Pax-Bank_PDF2CSV

den Kontoauszug aus dem PDF-Format ins CSV-Format umwandeln:
    
    ./postbank_pdf2csv.sh /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.006_Kontoauszug_vom_01.01.1970.pdf
    Bitte Kontoinhaber angeben : Kontoinhaber

    ================================================================================
    => das kann jetzt ein paar Minuten dauern ...
    ================================================================================

    -rw-r--r-- 1 ich ich 1,5K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.006_Kontoauszug_vom_01.01.1970.txt
    -rw-r--r-- 1 ich ich 1,2K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.006_Kontoauszug_vom_01.01.1970.csv

    libreoffice --calc 11111_201970_Nr.006_Kontoauszug_vom_01.01.1970.csv

Mehrere in einem Ordner liegende PDF-Dateien in CSV-Dateien umwandeln:
Achtung, bitte nur die Umzuwandelnden PDF-Dateien in dem Ordner liegen haben. Bisher werden alle Dateien bearbeitet.

    ./postbank_pdf2csv.sh /home/ich/Schreibtisch/Pax-Bank/*.pdf
    Bitte Kontoinhaber angeben : Kontoinhaber

    ================================================================================
    => das kann jetzt ein paar Minuten dauern ...
    ================================================================================

    -rw-r--r-- 1 ich ich 1,5K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.006_Kontoauszug_vom_01.07.1970.txt
    -rw-r--r-- 1 ich ich 1,2K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.006_Kontoauszug_vom_01.07.1970.csv
    -rw-r--r-- 1 ich ich 568  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.007_Kontoauszug_vom_31.07.1970.txt
    -rw-r--r-- 1 ich ich 501  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.007_Kontoauszug_vom_31.07.1970.csv
    -rw-r--r-- 1 ich ich 445  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.008_Kontoauszug_vom_31.08.1970.txt
    -rw-r--r-- 1 ich ich 414  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.008_Kontoauszug_vom_31.08.1970.csv
    -rw-r--r-- 1 ich ich 1,9K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.009_Kontoauszug_vom_01.10.1970.txt
    -rw-r--r-- 1 ich ich 1,5K  4. Jul 10:23 /home/ich/Schreibtisch/Pax-Bank/11111_1970_Nr.009_Kontoauszug_vom_01.10.1970.csv

    libreoffice --calc 11111_1970_Nr.009_Kontoauszug_vom_01.10.1970.csv

--------------------------------------------------------------------------------

Achtung, durch die vielen ineinander geschachtelten Schleifen, verursacht das Skript wärend seiner Laufzeit eine erhöhte Last und läuft relativ langsam.
