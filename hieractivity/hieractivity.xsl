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
  <xsl:variable name="common-base" select="concat($assets-base,'../common/')"/>
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
              | self::group
              | self::div1 | self::div2 | self::div3 | self::div4 | self::div5 
              | self::div6 | self::div7 | self::titlePage
              | self::listBibl | self::listEvent | self::listOrg | self::listPerson 
              | self::listPlace | self::castList
              | self::performance | self::prologue | self::epilogue | self::set 
              | self::opener | self::closer | self::postscript
              | self::quote[descendant::p] | self::said[descendant::p]
              | self::figure | self::note | self::sp
              ])"/>
  </xsl:function>
  
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/TEI" priority="92">
    <xsl:variable name="body" as="node()">
      <div class="hieractivity">
        <h1>
          <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title[1]"/>
        </h1>
        <div id="tei-container">
          <xsl:apply-templates select="text"/>
        </div>
        <div id="control-panel">
          <h2>Controls</h2>
          <h3>Zoom</h3>
          <div id="zoom-container">
            -
            <input id="zoom-slide" type="range"
              min="20" max="100" step="1" value="100" />
            +
          </div>
          <h3>Mark elements</h3>
          <form id="gi-option-selector">
            <xsl:call-template name="gi-counting-robot">
              <xsl:with-param name="start" select="text"/>
            </xsl:call-template>
          </form>
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
            <script src="{$common-base}jquery/jquery-3.2.1.min.js"></script>
            <script src="{$common-base}d3/d3.v4.min.js" type="text/javascript"></script>
            <script src="{$js-base}hieractivity.js" type="text/javascript"></script>
          </head>
          <body>
            <xsl:copy-of select="$body"/>
          </body>
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- We don't (yet) process the <teiHeader>. -->
  <xsl:template match="teiHeader" priority="91"/>
  
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
    <span class="block-after">
      <xsl:call-template name="set-data-attributes"/>
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
  <xsl:template match=" head | l | stage 
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
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'ul'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="list[not(*[not(self::item)])]/item">
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'li'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </xsl:element>
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
  
  <xsl:template match="graphic | media" mode="#default inside-p">
    <xsl:variable name="hasURL" select="exists(@url) and normalize-space(@url) ne ''"/>
    <span class="media-obj">
      <xsl:call-template name="get-attributes"/>
      <!-- If the current element has an @url, create a link for it. -->
      <xsl:if test="$hasURL">
        <a target="_blank">
          <xsl:apply-templates select="@*"/>
          <xsl:variable name="description">
            <xsl:call-template name="count-preceding-of-type"/>
            <xsl:choose>
              <xsl:when test="desc or following-sibling::figDesc">
                <xsl:text>; described below.</xsl:text>
              </xsl:when>
              <xsl:when test="preceding-sibling::figDesc">
                <xsl:text>; described above.</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <!-- TAPAS doesn't embed audio/video. Only images are given some kind of 
            visual indicator. -->
          <xsl:choose>
            <xsl:when test="self::graphic or contains(@mimeType,'image')">
              <img class="thumbnail" src="{@url/data(.)}" 
                alt="{$description}"/>
            </xsl:when>
            <xsl:otherwise>
              <span class="label-explanatory">
                <xsl:value-of select="$interjectStart"/>
                <xsl:value-of select="$description"/>
                <xsl:value-of select="$interjectEnd"/>
              </span>
            </xsl:otherwise>
          </xsl:choose>
        </a>
        <xsl:apply-templates/>
      </xsl:if>
    </span>
  </xsl:template>
  
  <xsl:template match="@url">
    <xsl:attribute name="href" select="data(.)"/>
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
  
  <xsl:template name="count-preceding-of-type">
    <xsl:param name="element" select="." as="node()"/>
    <xsl:variable name="gi" select="local-name($element)"/>
    <xsl:value-of select="$gi"/>
    <xsl:text> #</xsl:text>
    <xsl:value-of select="count(preceding::*[local-name(.) eq $gi][ancestor::text]) + 1"/>
    <xsl:text> of the TEI document</xsl:text>
  </xsl:template>
  
  <!-- Apply templates on attributes. -->
  <xsl:template name="get-attributes">
    <xsl:apply-templates select="@*" mode="carry-on"/>
    <xsl:call-template name="save-gi"/>
  </xsl:template>
  
  <!-- Count number of each type of element within a given element (the default is 
    the current node). -->
  <xsl:template name="gi-counting-robot">
    <xsl:param name="start" select="." as="node()"/>
    <xsl:variable name="allElements" select="$start/descendant-or-self::*/local-name(.)"/>
    <xsl:variable name="distinctGIs" select="distinct-values($allElements)"/>
    <label>
      <input type="radio" name="element" value="none" checked="checked"></input>
      <span class="gi-label">defaults only</span>
    </label>
    <xsl:variable name="options" as="item()*">
      <xsl:for-each select="$distinctGIs">
        <xsl:variable name="gi" select="."/>
        <xsl:variable name="count" select="count($allElements[. eq $gi])"/>
        <label>
          <input type="radio" name="element" value="{$gi}"></input>
          <span class="gi-label">
            <span class="gi-name"><xsl:value-of select="$gi"/></span>
            <xsl:text> </xsl:text>
            <span class="gi-count"><xsl:value-of select="$count"/></span>
          </span>
        </label>
      </xsl:for-each>
    </xsl:variable>
    <xsl:perform-sort select="$options">
      <xsl:sort select="xs:integer(descendant::*:span[@class eq 'gi-count']/text())" order="descending"/>
      <xsl:sort select="descendant::*:span[@class eq 'gi-name']/text()"/>
    </xsl:perform-sort>
  </xsl:template>
  
  <!-- Set data attributes, using the convenience template 'set-data-attributes'. 
    Then apply templates on child nodes. -->
  <xsl:template name="keep-calm-and-carry-on">
    <xsl:call-template name="set-data-attributes"/>
    <xsl:apply-templates mode="#current"/>
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