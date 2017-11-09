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
  <xsl:param name="css" select="'styles.css'"/>
  <xsl:param name="rng_prefix" select="'org.xml.sax.SAXParseException: '"/>
  <xsl:variable name="root" select="/" as="node()"/>
  <xsl:variable name="apos" select='"&apos;"'/>
  
  <xsl:output method="xhtml"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$fullHTML eq 'true'">
        <html>
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
    </head>
  </xsl:template>
  
  <xsl:template name="contentDiv">
    <!-- The only 2 values TEI P5 uses for sch:*/@role are 'warning' and 'nonfatal'. -->
    <xsl:variable name="errors" select="//c:error|//svrl:text[not( ../@role ) or ../@role eq 'nonfatal']"/>
    <xsl:variable name="warnings" select="//svrl:text[../@role eq 'warning']"/>
    <!-- For right now, TAPAS is going to treat errors as warnings. Probably will change -->
    <!-- that in the future, but given that the schema we are currently validating against -->
    <!-- (tei_all) has only 2 warnings, and they are both pretty severe, as it were, there -->
    <!-- seems to be no reason to put in a lot of effort to treat these differently. -->
    <xsl:variable name="regularized">
      <xsl:apply-templates select="( $warnings, $errors )" mode="regularize">
        <xsl:sort/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <div class="validation-tei_all-pkg">
      <h1>Messages</h1>
      <p>[Julia to send Syd prose for here.]</p>
      <h2>Messages</h2>
      <xsl:copy-of select="$regularized"/>
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