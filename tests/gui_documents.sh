# libreoffice and soffice, okular and xdg-open. The formats of --convert-to and the filters of --infilter come from
# the registry of the LibreOffice that PATH has, found by following its `soffice` link: here a small one, with the
# shapes of the real one's (a filter whose name has spaces, a self-closing property, a translated name, a character
# reference, a type whose extensions are a pattern, and a section of another package). PATH is set after the files are
# made, since the machine's may have a LibreOffice.
__luish_internal plugin load "$EXTRA/complete/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p lo/program lo/share/registry bin nobin out
printf '#!/bin/sh\n' >lo/program/soffice
chmod +x lo/program/soffice
ln -s ../lo/program/soffice bin/soffice
ln -s ../lo/program/soffice bin/libreoffice
touch report.odt sheet.ods
cat >lo/share/registry/writer.xcd <<'XCD'
<?xml version="1.0"?>
<oor:data xmlns:oor="http://openoffice.org/2001/registry">
<oor:component-data oor:package="org.openoffice.TypeDetection" oor:name="Filter">
  <node oor:name="Filters">
    <node oor:name="writer_pdf_Export" oor:op="replace">
      <prop oor:name="Flags">
        <value>EXPORT ALIEN 3RDPARTYFILTER</value>
      </prop>
      <prop oor:name="UserData">
        <value/>
      </prop>
      <prop oor:name="UIName">
        <value xml:lang="en-US">PDF - Portable Document Format</value>
      </prop>
      <prop oor:name="Type">
        <value>pdf_Portable_Document_Format</value>
      </prop>
    </node>
    <node oor:name="MS Word 97" oor:op="replace">
      <prop oor:name="Flags">
        <value>IMPORT EXPORT ALIEN PREFERRED</value>
      </prop>
      <prop oor:name="UIName">
        <value xml:lang="en-US">Word 97&#x2013;2003</value>
      </prop>
      <prop oor:name="Type">
        <value>writer_MS_Word_97</value>
      </prop>
    </node>
    <node oor:name="Text (encoded)" oor:op="replace">
      <prop oor:name="Flags">
        <value>IMPORT EXPORT ALIEN</value>
      </prop>
      <prop oor:name="UIName"/>
      <prop oor:name="Type">
        <value>writer_Text_encoded</value>
      </prop>
    </node>
    <node oor:name="UOF text" oor:op="replace">
      <prop oor:name="Flags">
        <value>IMPORT EXPORT ALIEN</value>
      </prop>
      <prop oor:name="Type">
        <value>writer_UOF</value>
      </prop>
    </node>
    <node oor:name="writer_web_HTML_help" oor:op="replace">
      <prop oor:name="Flags">
        <value>IMPORT INTERNAL</value>
      </prop>
      <prop oor:name="Type">
        <value>writer_web_HTML_help</value>
      </prop>
    </node>
  </node>
</oor:component-data>
<oor:component-data oor:package="org.openoffice.TypeDetection" oor:name="Types">
  <node oor:name="Types">
    <node oor:name="pdf_Portable_Document_Format" oor:op="replace">
      <prop oor:name="Extensions">
        <value>pdf</value>
      </prop>
      <prop oor:name="UIName">
        <value>PDF - Portable Document Format</value>
      </prop>
    </node>
    <node oor:name="writer_MS_Word_97" oor:op="replace">
      <prop oor:name="Extensions">
        <value>doc wps</value>
      </prop>
      <prop oor:name="UIName">
        <value>Word 97&#x2013;2003</value>
      </prop>
    </node>
    <node oor:name="writer_Text_encoded" oor:op="replace">
      <prop oor:name="Extensions">
        <value>txt csv</value>
      </prop>
      <prop oor:name="UIName">
        <value>Text (encoded) &amp; more</value>
      </prop>
    </node>
    <node oor:name="writer_UOF" oor:op="replace">
      <prop oor:name="Extensions">
        <value>uot;uof</value>
      </prop>
    </node>
    <node oor:name="writer_web_HTML_help" oor:op="replace">
      <prop oor:name="Extensions">
        <value>*</value>
      </prop>
    </node>
  </node>
</oor:component-data>
<oor:component-data oor:package="org.openoffice.Office.Common" oor:name="Misc">
  <node oor:name="NotAFilter" oor:op="replace">
    <prop oor:name="Type">
      <value>pdf_Portable_Document_Format</value>
    </prop>
    <prop oor:name="Flags">
      <value>EXPORT</value>
    </prop>
  </node>
</oor:component-data>
</oor:data>
XCD
PATH=$PWD/bin:$PATH
echo "=== options"
c 'soffice --conv'
c 'soffice --he'
c 'soffice --quick'
c 'soffice --inf'
c 'soffice -'
echo "=== values"
c 'soffice --convert-to '
c 'soffice --convert-to p'
c 'soffice --convert-to txt:'
c 'libreoffice --convert-to doc:MS'
c 'soffice --convert-to txt:Text (encoded):'
c 'soffice --convert-to pdf --outdir '
c 'soffice --convert-to pdf --outdir out '
c 'soffice --infilter='
c 'soffice --pt '
c 'soffice --print-to-file --printer-name P'
c 'soffice --accept='
c 'soffice --unaccept='
c 'soffice -env:'
c 'soffice -env:UserInstallation=file:///tmp/x --headless r'
echo "=== without a registry"
PATH=$PWD/nobin
c 'soffice --convert-to '
c 'soffice --convert-to pdf:'
c 'soffice --infilter='
echo "=== okular"
c 'okular --p'
c 'okular -p '
c 'okular --platform '
c 'okular --page 3 r'
c 'okular --qwindowicon '
echo "=== xdg-open"
c 'xdg-open -'
c 'xdg-open r'
c 'xdg-open report.odt '
