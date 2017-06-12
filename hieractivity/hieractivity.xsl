<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wfn="http://www.wwp.northeastern.edu/ns/functions"
  xmlns:tps="http://tapas.northeastern.edu"
  exclude-result-prefixes="#all">
  
  <xsl:output indent="no" method="xhtml" omit-xml-declaration="yes"/>
  
  <!-- PARAMETERS AND VARIABLES -->
  
  <xsl:param name="assets-base" select="'./'"/>
  <xsl:variable name="css-base" select="concat($assets-base,'css/')"/>
  <xsl:variable name="js-base" select="concat($assets-base,'js/')"/>
  <xsl:param name="fullHTML"   select="'false'"/> <!-- set to 'true' to get browsable output for debugging -->
  
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/">
    <xsl:variable name="body" as="node()">
      <div class="hieractivity">
        <div id="tei-container">
          <xsl:apply-templates select="//text"/>
        </div>
        <div id="control-panel">
          40% <input id="zoom-slide" type="range"
          min="40" max="100" step="1" value="100" />
          100%
        </div>
      </div>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$fullHTML">
        <html>
          <head>
            <title>Testing</title>
            <meta charset="UTF-8" />
            <link id="maincss" rel="stylesheet" type="text/css" href="{$css-base}hieractivity.css" />
            <script src="https://code.jquery.com/jquery-3.2.1.min.js"
              integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
              crossorigin="anonymous"></script>
            <script src="https://d3js.org/d3.v4.min.js" type="text/javascript"></script>
          </head>
          <body>
            <xsl:copy-of select="$body"/>
            <script src="{$js-base}hieractivity.js" type="text/javascript"></script>
          </body>
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$body"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="*">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xsl:template match="@*" name="make-data-attr" priority="-20">
    <xsl:attribute name="data-tapas-att-{local-name()}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match=" TEI | text | front | body | back | div | ab | floatingText 
                      | div1 | div2 | div3 | div4 | div5 | div6 | div7 | lg
                      | listBibl | listEvent | listOrg | listPerson | listPlace">
    <div>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </div>
  </xsl:template>
  
  <xsl:template match="lb | pb">
    <br>
      <xsl:call-template name="save-gi"/>
      <xsl:call-template name="get-attributes"/>
    </br>
  </xsl:template>
  
  <xsl:template match="p">
    <p>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </p>
  </xsl:template>
  
  <!-- Handle simple lists, those containing only <item>s. -->
  <xsl:template match="list[not(*[not(self::item)])]">
    <ul>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list[not(*[not(self::item)])]/item">
    <li>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </li>
  </xsl:template>
  
  
  <!-- SUPPLEMENTAL TEMPLATES -->
  
  <xsl:template name="keep-calm-and-carry-on">
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="get-attributes"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Apply templates on attributes. -->
  <xsl:template name="get-attributes">
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:call-template name="save-gi"/>
  </xsl:template>
  
  <!-- Create a data attribute to store the name of the current TEI element. -->
  <xsl:template name="save-gi">
    <xsl:attribute name="data-tapas-gi" select="local-name(.)"/>
  </xsl:template>
  
</xsl:stylesheet>