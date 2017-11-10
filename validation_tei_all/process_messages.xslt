<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.w3.org/ns/xproc-step"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Read in a document of error messages, write out readable HTML thereof -->
  <!-- Input document format: 
    element tapas:errors { RNG?, SCH }
    RNG = element c:errors { c:error+ }
    SCH = element svrl:schematron-output { [SVRL] }
  -->
  
  <!-- saxon -xsl:validation_tei_all/process_messages.xslt -s:/tmp/errs.xml -o:/tmp/errs.html fullHTML=true css=/home/syd/Documents/tapas-view-packages/validation_tei_all/styles.css -->

   <xsl:param name="fullHTML" select="'false'"/> <!-- set to 'true' to get browsable output for debugging -->
   <xsl:param name="css" select="'./css/validation.css'"/>
   <xsl:param name="jquery" select="'../common/jquery/jquery-3.2.1.min.js'"/>
   <xsl:param name="js" select="'js/validation.js'"/>
   <xsl:param name="rng_prefix" select="'org.xml.sax.SAXParseException: '"/>
   <xsl:variable name="root" select="/" as="node()"/>
   <xsl:variable name="apos" select='"&apos;"'/>
   
  <xsl:output method="xhtml"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$fullHTML eq 'true'">
        <html xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0">
          <xsl:call-template name="htmlHead"/>
          <body>
            <xsl:call-template name="contentDiv"/>
          </body>
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$fullHTML ne 'false'">
          <xsl:message>WARNING: unrecognized value of 'fullHTML' parameter; presuming false</xsl:message>
        </xsl:if>
        <xsl:call-template name="contentDiv"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="htmlHead">
     <head>
      <title>TAPAS: TEI errors</title>
      <meta charset="UTF-8"/>
      <meta name="created-by" content="process_messages.xslt"/>
      <meta name="creation-timestamp" content="{current-dateTime()}"/>
      <link rel="stylesheet" type="text/css" href="{$css}"/>
        <script type="text/javascript" src="{$jquery}"></script>
        <script type="text/javascript" src="{$js}"></script>
    </head>
  </xsl:template>
  
  <xsl:template name="contentDiv">
     <div class="debug input" style="display:none;">
        <xsl:copy-of select="/"/>
     </div>
     <!-- The only 2 values TEI P5 uses for sch:*/@role are 'warning' and 'nonfatal'. -->
    <xsl:variable name="errors" select="//c:error|//svrl:text[not( ../@role ) or ../@role eq 'nonfatal']"/>
    <xsl:variable name="warnings" select="//svrl:text[../@role eq 'warning']"/>
    <!-- For right now, TAPAS is going to treat errors as warnings. Probably will change -->
    <!-- that in the future, but given that the schema we are currently validating against -->
    <!-- (tei_all) has only 2 warnings, and they are both pretty severe, as it were, there -->
    <!-- seems to be no reason to put in a lot of effort to treat these differently. -->

    <!--
        Regularize all warnings and errors, whether from RNG or SCH
        processing. Each error message (whether from c: or sch:
        namespace) gets converted to a <tapas:msg> element:
          element tapas:msg { 
            attribute role {"information"|"warning"|"error"|"severe"|"fatal"},
            # note that only "warning" and "error" are currently used
            (
              ( 
                attribute line { xsd:nonNegativeInteger },
                attribute col { xsd:nonNegativeInteger }?
              )
            | 
              (
                attribute type {"failed-assert"|"successful-report"},
                attribute context { XPath },
                attribute test { XPath },
                attribute loc { XPath }
              )
            ),
            anyXML # mostly text, which has $rng_prefix stripped off
           }
       Where XPath is just text that we know is an XPath, and
       anyXML is typically text with TEI phrase-level elements. 
    -->
    <!-- The variable $regularized contains nothing but a sequence -->
    <!-- of these <tapas:msg> elements, sorted by content. -->
    <xsl:variable name="regularized">
      <xsl:apply-templates select="( $warnings, $errors )" mode="regularize">
         <xsl:sort select="replace( normalize-space(.), $rng_prefix, '')"/>
      </xsl:apply-templates>
    </xsl:variable>

    <div class="validation-tei_all-pkg">
      <h1>Encoding Information</h1>
      <h2>Validity with respect to <tt>tei_all</tt></h2>
      <p>This TEI file has been validated against the TEI’s most broadly
        defined schema: <tt>tei_all</tt>. This schema defines TEI encoding practice at
        a very general level. TAPAS currently uses this schema as a
        way of defining the a minimum standard for encoding practices we can support in our
        TAPAS-wide stylesheets and viewing options. There may be other restrictions,
      but certainly a TEI file should meet the criteria expressed in <tt>tei_all</tt>.</p>
     <xsl:choose>
       <xsl:when test="$regularized">
         <h3>Problems…</h3>
         <p>The validation messages below describe where
           the encoding in this file is invalid: that is, where it differs from
           the rules expressed in the <tt>tei_all</tt> schema. In some cases this may be
           because this file was encoded using a customized TEI schema for a
           specific project. (Read more about <a href="http://www.tei-c.org/Guidelines/Customization/">TEI customization</a>.)
           Other cases may simply be errors in the encoding,
           or places where the encoding isn’t finished yet.</p>
         <h2>Messages</h2>
         <xsl:variable name="ranked">
           <xsl:for-each-group select="$regularized/tapas:msg" group-adjacent="normalize-space(.)">
             <xsl:variable name="this_grp">
               <xsl:for-each select="current-group()">
                 <xsl:copy-of select="."/>
               </xsl:for-each>
             </xsl:variable>
             <tapas:listMessage n="{position()}" cnt="{count( $this_grp/tapas:msg )}">
               <xsl:copy-of select="$this_grp"/>
             </tapas:listMessage>
           </xsl:for-each-group>
         </xsl:variable>
         <ul class="collapsable" id="{generate-id()}">
            <xsl:apply-templates select="$ranked/*" mode="ranked-msg-list">
               <xsl:sort select="@cnt cast as xs:integer" order="descending"/>
            </xsl:apply-templates>
         </ul>
       </xsl:when>
       <xsl:otherwise>
         <h3>Valid!</h3>
         <p>This file is valid against the <tt>tei_all</tt> schema. You can read more
           about validation in the <a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/SG.html#SG13">Genle
             Introduction to XML</a></p>
       </xsl:otherwise>
     </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="c:error" mode="regularize">
    <tapas:msg role="error" line="{@line}" col="{@column}">
      <xsl:value-of select="substring-after( normalize-space(.), $rng_prefix )"/>
    </tapas:msg>
  </xsl:template>

  <xsl:template match="svrl:text" mode="regularize">
    <xsl:variable name="loc">
      <xsl:variable name="ns_predicate" select="concat('\[namespace-uri\(\)=',$apos,'http://www.tei-c.org/ns/1.0',$apos,'\]')"/>
      <xsl:variable name="loc-sans-ns" select="replace( normalize-space(../@location),$ns_predicate,'')"/>
      <xsl:variable name="loc-sans-useless-ns-prefix" select="replace( $loc-sans-ns,'\*:','')"/>
      <xsl:value-of select="replace( $loc-sans-useless-ns-prefix, '(\c)\[1\]','$1')"/>
    </xsl:variable>
    <xsl:variable name="role" select="if (@role) then @role else 'error'"/>
    <tapas:msg type="{local-name(..)}" role="{$role}" loc="{$loc}" context="{../preceding-sibling::svrl:fired-rule[1]/@context}" test="../@test">
      <xsl:value-of select="normalize-space(.)"/>
    </tapas:msg>
  </xsl:template>

   <xsl:template match="tapas:listMessage" mode="ranked-msg-list">
      <li>
         <span class="msgType collapsableHeading">
            <span class="cnt"><xsl:value-of select="@cnt"/></span>
            <span class="msg"><xsl:apply-templates select="tapas:msg[1]" mode="msg"/></span>
         </span>
         <ul class="collapsable" id="{generate-id()}">
            <xsl:apply-templates select="tapas:msg" mode="msg2li"/>
         </ul>
      </li>
   </xsl:template>

   <xsl:template match="tapas:msg" mode="msg">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   
   <xsl:template match="tapas:msg" mode="msg2li">
      <li>
         <span class="msg collapsableHeading">
            <xsl:apply-templates mode="#current"/>
         </span>
         <span class="collapsable" id="{generate-id()}">
            <span class="lineNum blocked">
               <span class="label">Approximate line #:</span>
               <xsl:value-of select="@line"/>
            </span>
            <span class="colNum blocked">
               <span class="label">Estimated column #:</span>
               <xsl:value-of select="@col"/>         
            </span>
            <span class="allowed blocked">
               <span class="label">expected or allowed:</span>
               <span>!! watch this space !!</span>
            </span>
         </span>
      </li>
   </xsl:template>
   
   <xsl:template match="tei:att" mode="msg msg2li">
      <span class="{local-name(.)}">
         <xsl:text>@</xsl:text>
         <xsl:apply-templates mode="#current"/>
      </span>
   </xsl:template>
   <xsl:template match="tei:gi" mode="msg">
      <span class="{local-name(.)}">
         <xsl:text>&lt;</xsl:text>
         <xsl:apply-templates mode="#current"/>
         <xsl:text>></xsl:text>
      </span>
   </xsl:template>
   <xsl:template match="tei:val" mode="msg">
      <span class="{local-name(.)}">
         <xsl:text>"</xsl:text>
         <xsl:apply-templates mode="#current"/>
         <xsl:text>"</xsl:text>
      </span>
   </xsl:template>

      
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      <tapas:msg type="failed-assert" role="error" loc="/TEI/text/body/p/join" context="tei:join" test="../@test">You must supply at least two values for @target on join</tapas:msg>
      <tapas:msg type="successful-report" role="error" loc="/TEI/text/body/opener/dateline/date" context="tei:*[@when]" test="../@test">The @when attribute cannot be used with any other att.datable.w3c attributes.</tapas:msg>
      <tapas:msg role="error" line="54" col="11">element "WHAT" not allowed anywhere; expected the element end-tag, text or element "abbr", "add", "addName", "addSpan", "address", "affiliation", "alt", "altGrp", "am", "anchor", "app", "att", "binaryObject", "bloc", "c", "caesura", "catchwords", "cb", "certainty", "choice", "cl", "climate", "code", "corr", "country", "damage", "damageSpan", "date", "del", "delSpan", "depth", "dim", "dimensions", "distinct", "district", "docDate", "email", "emph", "ex", "expan", "fLib", "figure", "foreign", "forename", "formula", "fs", "fvLib", "fw", "g", "gap", "gb", "genName", "geo", "geogFeat", "geogName", "gi", "gloss", "graphic", "handShift", "height", "heraldry", "hi", "ident", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lang", "lb", "link", "linkGrp", "listTranspose", "location", "locus", "locusGrp", "m", "material", "measure", "measureGrp", "media", "mentioned", "metamark", "milestone", "mod", "name", "nameLink", "notatedMusic", "note", "num", "oRef", "oVar", "objectType", "offset", "orgName", "orig", "origDate", "origPlace", "pRef", "pVar", "pause", "pb", "pc", "persName", "phr", "placeName", "population", "precision", "ptr", "redo", "ref", "reg", "region", "respons", "restore", "retrace", "rhyme", "roleName", "rs", "s", "secFol", "secl", "seg", "settlement", "shift", "sic", "signatures", "soCalled", "space", "span", "spanGrp", "specDesc", "specList", "stamp", "state", "subst", "substJoin", "supplied", "surname", "surplus", "tag", "term", "terrain", "time", "timeline", "title", "trait", "unclear", "undo", "val", "vocal", "w", "watermark", "width", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="23" col="12">element "address" incomplete; expected element "addName", "addSpan", "addrLine", "alt", "altGrp", "anchor", "app", "bloc", "cb", "certainty", "climate", "country", "damageSpan", "delSpan", "district", "fLib", "figure", "forename", "fs", "fvLib", "fw", "gap", "gb", "genName", "geogFeat", "geogName", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lang", "lb", "link", "linkGrp", "listTranspose", "location", "metamark", "milestone", "name", "nameLink", "notatedMusic", "note", "offset", "orgName", "pause", "pb", "persName", "placeName", "population", "postBox", "postCode", "precision", "region", "respons", "roleName", "rs", "settlement", "shift", "space", "span", "spanGrp", "state", "street", "substJoin", "surname", "terrain", "timeline", "trait", "vocal", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="66" col="10">element "p" not allowed here; expected the element end-tag or element "addSpan", "alt", "altGrp", "anchor", "app", "argument", "byline", "cb", "certainty", "closer", "damageSpan", "dateline", "delSpan", "docAuthor", "docDate", "epigraph", "fLib", "figure", "fs", "fvLib", "fw", "gap", "gb", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lb", "link", "linkGrp", "listTranspose", "meeting", "metamark", "milestone", "notatedMusic", "note", "pause", "pb", "postscript", "precision", "respons", "salute", "shift", "signed", "space", "span", "spanGrp", "substJoin", "timeline", "trailer", "vocal", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="6" col="32">element "teiHeader" incomplete; missing required element "fileDesc"</tapas:msg>
      <tapas:msg role="error" line="6" col="32">element "teiHeader" not allowed here; expected the element end-tag, text or element "abbr", "add", "addName", "addSpan", "address", "affiliation", "alt", "altGrp", "am", "anchor", "app", "att", "bibl", "biblFull", "biblStruct", "binaryObject", "bloc", "c", "caesura", "camera", "caption", "castList", "catchwords", "cb", "certainty", "choice", "cit", "cl", "classSpec", "climate", "code", "constraintSpec", "corr", "country", "damage", "damageSpan", "dataSpec", "date", "del", "delSpan", "depth", "desc", "dim", "dimensions", "distinct", "district", "eg", "elementSpec", "email", "emph", "ex", "expan", "fLib", "figure", "floatingText", "foreign", "forename", "formula", "fs", "fvLib", "fw", "g", "gap", "gb", "genName", "geo", "geogFeat", "geogName", "gi", "gloss", "graphic", "handShift", "height", "heraldry", "hi", "ident", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "l", "label", "lang", "lb", "lg", "link", "linkGrp", "list", "listApp", "listBibl", "listEvent", "listNym", "listOrg", "listPerson", "listPlace", "listRef", "listRelation", "listTranspose", "listWit", "location", "locus", "locusGrp", "m", "macroSpec", "material", "measure", "measureGrp", "media", "mentioned", "metamark", "milestone", "mod", "moduleSpec", "move", "msDesc", "name", "nameLink", "notatedMusic", "note", "ns:egXML", "num", "oRef", "oVar", "objectType", "offset", "orgName", "orig", "origDate", "origPlace", "outputRendition", "pRef", "pVar", "pause", "pb", "pc", "persName", "phr", "placeName", "population", "precision", "ptr", "q", "quote", "redo", "ref", "reg", "region", "respons", "restore", "retrace", "rhyme", "roleName", "rs", "s", "said", "secFol", "secl", "seg", "settlement", "shift", "sic", "signatures", "soCalled", "sound", "space", "span", "spanGrp", "specDesc", "specGrp", "specGrpRef", "specList", "stage", "stamp", "state", "subst", "substJoin", "supplied", "surname", "surplus", "table", "tag", "tech", "term", "terrain", "time", "timeline", "title", "trait", "unclear", "undo", "val", "view", "vocal", "w", "watermark", "width", "witDetail" or "writing" (with xmlns:ns="http://www.tei-c.org/ns/Examples")</tapas:msg>
      <tapas:msg role="error" line="20" col="25">text not allowed here; expected element "addName", "addSpan", "addrLine", "alt", "altGrp", "anchor", "app", "bloc", "cb", "certainty", "climate", "country", "damageSpan", "delSpan", "district", "fLib", "figure", "forename", "fs", "fvLib", "fw", "gap", "gb", "genName", "geogFeat", "geogName", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lang", "lb", "link", "linkGrp", "listTranspose", "location", "metamark", "milestone", "name", "nameLink", "notatedMusic", "note", "offset", "orgName", "pause", "pb", "persName", "placeName", "population", "postBox", "postCode", "precision", "region", "respons", "roleName", "rs", "settlement", "shift", "space", "span", "spanGrp", "state", "street", "substJoin", "surname", "terrain", "timeline", "trait", "vocal", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="21" col="32">text not allowed here; expected element "addName", "addSpan", "addrLine", "alt", "altGrp", "anchor", "app", "bloc", "cb", "certainty", "climate", "country", "damageSpan", "delSpan", "district", "fLib", "figure", "forename", "fs", "fvLib", "fw", "gap", "gb", "genName", "geogFeat", "geogName", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lang", "lb", "link", "linkGrp", "listTranspose", "location", "metamark", "milestone", "name", "nameLink", "notatedMusic", "note", "offset", "orgName", "pause", "pb", "persName", "placeName", "population", "postBox", "postCode", "precision", "region", "respons", "roleName", "rs", "settlement", "shift", "space", "span", "spanGrp", "state", "street", "substJoin", "surname", "terrain", "timeline", "trait", "vocal", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="22" col="25">text not allowed here; expected element "addName", "addSpan", "addrLine", "alt", "altGrp", "anchor", "app", "bloc", "cb", "certainty", "climate", "country", "damageSpan", "delSpan", "district", "fLib", "figure", "forename", "fs", "fvLib", "fw", "gap", "gb", "genName", "geogFeat", "geogName", "idno", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "lang", "lb", "link", "linkGrp", "listTranspose", "location", "metamark", "milestone", "name", "nameLink", "notatedMusic", "note", "offset", "orgName", "pause", "pb", "persName", "placeName", "population", "postBox", "postCode", "precision", "region", "respons", "roleName", "rs", "settlement", "shift", "space", "span", "spanGrp", "state", "street", "substJoin", "surname", "terrain", "timeline", "trait", "vocal", "witDetail" or "writing"</tapas:msg>
      <tapas:msg role="error" line="60" col="403">text not allowed here; expected the element end-tag</tapas:msg>
    </xd:desc>
  </xd:doc>
</xsl:stylesheet>

<!-- 
  
1. value of attribute "foo" is invalid; must be equal to "bar" or "blort"

Short version: The value for the [foo] attribute doesn't match the list of permitted values. It should be one of the following: [bar] or [blort].

Long version: The value for the [foo] attribute doesn't match the list of permitted values. It should be one of the following: [bar] or [blort]. In this schema, this attribute does not permit you to enter your own values.


2. value of attribute "ana" is invalid; token "X" invalid; must be a URI

Short version: The value for the [foo] attribute is not the right data type. It should be a [URI].

Long version: The value for the "[foo]" attribute is not the right data type. The [foo] attribute is defined as a [URI], which means [gloss of required properties].


3. attribute "blort" not allowed here; expected attribute "ana", "cert", "change", "copyOf", "corresp", "exclude", "facs", "hand", "n", "next", "place", "prev", "rend", "rendition", "resp", "sameAs", "select", "source", "style", "subtype", "synch", "type", "xml:base", "xml:id", "xml:lang" or "xml:space"

Short version: The [blort] attribute is not allowed on the [foo] element. Try checking the attribute name for capitalization errors and typos.

Long version: The "[blort]" attribute is not allowed on the "[foo]" element. Try checking the attribute name for capitalization errors and typos. Here's the list of permitted attributes: [list]


4. element "songline" not allowed anywhere; expected element "addSpan", "alt", "altGrp", "anchor", "app", "argument", "byline", "camera", "caption", "cb", "certainty", "damageSpan", "dateline", "delSpan", "desc", "docAuthor", "docDate", "epigraph", "fLib", "figure", "fs", "fvLib", "fw", "gap", "gb", "head", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "l", "label", "lb", "lg", "link", "linkGrp", "listTranspose", "meeting", "metamark", "milestone", "move", "notatedMusic", "note", "opener", "pause", "pb", "precision", "respons", "salute", "shift", "signed", "sound", "space", "span", "spanGrp", "stage", "substJoin", "tech", "timeline", "view", "vocal", "witDetail" or "writing"

Short version: The [songline] element doesn't exist in this markup language. Try checking the element name for capitalization errors and typos.

Long version: The [songline] element doesn't exist in this markup language. Try checking the element name for capitalization errors and typos. Here's a list of elements that are allowed here: [list].


5. element "person" not allowed here; expected element "addSpan", "alt", "altGrp", "anchor", "app", "argument", "byline", "camera", "caption", "cb", "certainty", "damageSpan", "dateline", "delSpan", "desc", "docAuthor", "docDate", "epigraph", "fLib", "figure", "fs", "fvLib", "fw", "gap", "gb", "head", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "l", "label", "lb", "lg", "link", "linkGrp", "listTranspose", "meeting", "metamark", "milestone", "move", "notatedMusic", "note", "opener", "pause", "pb", "precision", "respons", "salute", "shift", "signed", "sound", "space", "span", "spanGrp", "stage", "substJoin", "tech", "timeline", "view", "vocal", "witDetail" or "writing"

Short version: The [person] element isn't allowed at this point in the encoding (although it is valid elsewhere).

Long version: The [person] element isn't allowed at this point in the encoding (although it is valid elsewhere). Check to see whether you might be missing a parent element. Here's a list of elements that are valid here: [list].


6. text not allowed here; expected element "addSpan", "alt", "altGrp", "anchor", "app", "argument", "byline", "camera", "caption", "cb", "certainty", "damageSpan", "dateline", "delSpan", "desc", "docAuthor", "docDate", "epigraph", "fLib", "figure", "fs", "fvLib", "fw", "gap", "gb", "head", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "l", "label", "lb", "lg", "link", "linkGrp", "listTranspose", "meeting", "metamark", "milestone", "move", "notatedMusic", "note", "opener", "pause", "pb", "precision", "respons", "salute", "shift", "signed", "sound", "space", "span", "spanGrp", "stage", "substJoin", "tech", "timeline", "view", "vocal", "witDetail" or "writing"

Short version: At this place in the encoding, text is not allowed; the [parent] element may only contain other elements.

Long version: At this place in the encoding, text is not allowed; the [parent] element may only contain other elements. Check to see whether you might be missing a parent element. Here's a list of elements that are valid here: [list].


7. text not allowed here; expected the element end-tag
[I think I need to understand the difference between this error message and the previous one more fully]

Short version: At this place in the encoding, text is not allowed, only element content.

Long version: At this place in the encoding, text is not allowed, only element content. It's possible that you've accidentally added a stray text character in between elements; take a close look.

8. element "lg" incomplete; expected element "addSpan", "alt", "altGrp", "anchor", "app", "argument", "byline", "camera", "caption", "cb", "certainty", "damageSpan", "dateline", "delSpan", "desc", "docAuthor", "docDate", "epigraph", "fLib", "figure", "fs", "fvLib", "fw", "gap", "gb", "head", "incident", "index", "interp", "interpGrp", "join", "joinGrp", "kinesic", "l", "label", "lb", "lg", "link", "linkGrp", "listTranspose", "meeting", "metamark", "milestone", "move", "notatedMusic", "note", "opener", "pause", "pb", "precision", "respons", "salute", "shift", "signed", "sound", "space", "span", "spanGrp", "stage", "substJoin", "tech", "timeline", "view", "vocal", "witDetail" or "writing"

Short version: The [lg] element is incomplete; it is missing a required child element.

Long version: The [lg] element is incomplete; it is missing a required child element. Here is a list of the elements that are required at this point: [list].

9. element "index" not allowed yet; expected the element end-tag or element "term"

Short version: The [index] element is valid here, but another element ([term]) is required first.

Long version: The [index] element is valid here, but another element ([term]) is required first. Here's a full list of elements that are allowed before [index].

-->
