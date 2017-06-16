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
  
  <xsl:variable name="interjectStart">&lt;[ </xsl:variable>
  <xsl:variable name="interjectEnd"> ]&gt;</xsl:variable>
  
  <!-- FUNCTIONS -->
  
  <xsl:function name="tps:is-chunk-level" as="xs:boolean">
    <xsl:param name="element" as="element()" required="yes"/>
    <xsl:value-of 
      select="exists($element[
                self::TEI | self::text | self::front | self::body | self::back 
              | self::ab | self::floatingText | self::lg | self::div
              | self::div1 | self::div2 | self::div3 | self::div4 | self::div5 
              | self::div6 | self::div7 | self::titlePage
              | self::listBibl | self::listEvent | self::listOrg | self::listPerson 
              | self::listPlace
              | self::quote[descendant::p] | self::said[descendant::p]
              | self::figure | self::note | self::sp
              ])"/>
  </xsl:function>
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/">
    <xsl:variable name="body" as="node()">
      <div class="hieractivity">
        <div id="tei-container">
          <xsl:apply-templates select="//text"/>
        </div>
        <div id="control-panel">
          <div id="zoom-container">
            -
            <input id="zoom-slide" type="range"
              min="20" max="100" step="1" value="100" />
            +
          </div>
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
  
  <xsl:template match="@*" priority="-10"/>
  
  <xsl:template match="*">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xsl:template match="@*" name="make-data-attr" mode="carry-on" priority="-20">
    <xsl:attribute name="data-tapas-att-{local-name()}" select="data(.)"/>
  </xsl:template>
  
  <!-- Block-level TEI elements will be used to create boxes in the HTML output. 
    Since CSS doesn't allow selecting on ancestors of nodes, we calculate the depth 
    (nestedness) of the current node here. -->
  <xsl:template match="*[tps:is-chunk-level(.)]" mode="#default inside-p">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="lb" mode="#default inside-p">
    <span>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:if test="ancestor::p">
        <xsl:attribute name="class" select="'block-after'"/>
      </xsl:if>
    </span>
  </xsl:template>
  
  <xsl:template match="cb | pb" mode="#default inside-p">
    <span class="block">
      <xsl:call-template name="set-data-attributes"/>
      <span class="label-explanatory">
        <xsl:value-of select="$interjectStart"/>
        <xsl:choose>
          <xsl:when test="self::cb">column</xsl:when>
          <xsl:when test="self::pb">page</xsl:when>
        </xsl:choose>
        <xsl:text> break</xsl:text>
        <xsl:if test="@n">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@n"/>
        </xsl:if>
        <xsl:value-of select="$interjectEnd"/>
      </span>
    </span>
  </xsl:template>
  
  <!-- TEI elements which do not warrant an <html:div> or <html:p>, but should have 
    "display: block". -->
  <xsl:template match=" byline | head | l | stage 
                      | salute | signed
                      | argument | byline | docAuthor | docDate | docEdition 
                      | docImprint | docTitle[not(titlePart)] | titlePart" 
                mode="#default inside-p">
    <span class="block">
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
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
  
  <xsl:template match="p">
    <p>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:apply-templates mode="inside-p"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*" priority="-10" mode="inside-p">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xsl:template match="gap" mode="#default inside-p">
    <xsl:variable name="contentDivider" select="': '"/>
    <span>
      <xsl:call-template name="set-data-attributes"/>
      <span class="label-explanatory">
        <xsl:value-of select="$interjectStart"/>
        <xsl:text>gap</xsl:text>
        <xsl:choose>
          <xsl:when test="desc">
            <xsl:value-of select="$contentDivider"/>
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:when test="@extent">
            <xsl:value-of select="$contentDivider"/>
            <xsl:value-of select="@extent"/>
          </xsl:when>
          <xsl:when test="@quantity">
            <xsl:value-of select="$contentDivider"/>
            <xsl:value-of select="@quantity"/>
            <xsl:if test="@unit">
              <xsl:text> </xsl:text>
              <xsl:value-of select="@unit"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$interjectEnd"/>
      </span>
    </span>
  </xsl:template>
  
  <xsl:template match="choice" mode="#default inside-p">
    <span class="label-explanatory">
      <xsl:call-template name="set-data-attributes"/>
      <xsl:value-of select="$interjectStart"/>
      <xsl:text>choice: </xsl:text>
      <xsl:apply-templates mode="#current"/>
      <xsl:value-of select="$interjectEnd"/>
    </span>
  </xsl:template>
  
  <!-- Whitespace inside <choice> is thrown away. -->
  <xsl:template match="choice/text()" mode="#default inside-p"/>
  
  <xsl:template match="choice/*[preceding-sibling::*]" mode="#default inside-p">
    <xsl:text> | </xsl:text>
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  
  <!-- SUPPLEMENTAL TEMPLATES -->
  
  <!-- Set data attributes, using the convenience template 'set-data-attributes'. 
    Then apply templates on child nodes. -->
  <xsl:template name="keep-calm-and-carry-on">
    <xsl:call-template name="set-data-attributes"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- Apply templates on attributes. -->
  <xsl:template name="get-attributes">
    <xsl:apply-templates select="@*" mode="carry-on"/>
    <xsl:call-template name="save-gi"/>
  </xsl:template>
  
  <!-- Create a data attribute to store the name of the current TEI element. -->
  <xsl:template name="save-gi">
    <xsl:attribute name="data-tapas-gi" select="local-name(.)"/>
  </xsl:template>
  
  <!-- Set data attributes, saving the TEI element's name and attribute values. This 
    is a convenience template for 'save-gi' followed by 'get-attributes'. -->
  <xsl:template name="set-data-attributes">
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="get-attributes"/>
  </xsl:template>
  
</xsl:stylesheet>