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
  <xsl:variable name="nbsp" select="'&#160;'"/>
  
  
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
    <xsl:variable name="lang" select="if ( @xml:lang ) then @xml:lang/data(.) else 'en'"/>
    <xsl:variable name="body" as="node()">
      <div class="hieractivity">
        <xsl:if test="not($fullHTML)">
          <xsl:attribute name="lang" select="$lang"/>
        </xsl:if>
        <!-- Metadata from the <teiHeader> -->
        <div id="tei-header">
          <xsl:apply-templates select="teiHeader"/>
        </div>
        <!-- The HTML representation of <text> -->
        <div id="tei-container">
          <xsl:apply-templates select="text"/>
        </div>
        <!-- The control panel -->
        <div id="control-panel">
          <h2>Controls</h2>
          <h3>Zoom</h3>
          <div id="zoom-container">
            -
            <input id="zoom-slide" title="Zoom control slider" tabindex="1"
              type="range" min="20" max="100" step="1" value="100" />
            +
          </div>
          <h3>Elements by frequency</h3>
          <fieldset id="gi-option-selector" tabindex="2">
            <legend>Mark</legend>
            <xsl:call-template name="gi-counting-robot">
              <xsl:with-param name="start" select="text"/>
            </xsl:call-template>
          </fieldset>
          <h3>Clicked element</h3>
          <dl id="gi-properties"></dl>
        </div>
      </div>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$fullHTML">
        <html>
          <xsl:attribute name="lang" select="$lang"/>
          <head>
            <title>
              <xsl:value-of select="teiHeader/fileDesc/titleStmt/title[1]/normalize-space(.)"/>
            </title>
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
  
  <xsl:template match="@*" priority="-10"/>
  
  <xsl:template match="*" mode="#default table-complex">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xsl:template match="@*" name="make-data-attr" mode="carry-on" priority="-20">
    <xsl:variable name="attrName" 
      select="if ( local-name() eq name() ) then name() 
              else translate(name(),':','-')"/>
    <xsl:attribute name="data-tapas-att-{$attrName}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match="teiHeader" priority="91">
    <xsl:apply-templates select="fileDesc/titleStmt/title[1]" mode="teiheader"/>
    <h2 class="expandable-heading box-c1">TEI Header</h2>
    <div id="teiheader" class="expandable expandable-hidden">
      <xsl:apply-templates mode="teiheader"/>
    </div>
  </xsl:template>
  
  <xsl:template match="text" priority="90">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <div>
      <xsl:call-template name="set-box-classes-depthwise">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <h2>TEI Text</h2>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <!-- Block-level TEI elements will be used to create boxes in the HTML output. 
    Since CSS doesn't allow selecting on ancestors of nodes, we calculate the depth 
    (nestedness) of the current node here. -->
  <xsl:template match="*[tps:is-chunk-level(.)]" mode="#default inside-p">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="set-box-classes-depthwise">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

<!-- LISTS -->

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
  
<!-- TABLES -->
  
  <xsl:template match="cell/@rows | cell/@cols" mode="#default">
    <xsl:variable name="data" select="data(.)"/>
    <xsl:if test="$data castable as xs:integer and xs:integer($data) gt 1">
      <xsl:variable name="attrName" select="substring-before(local-name(),'s')"/>
      <xsl:attribute name="{$attrName}span" select="$data"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="table[not(*[not(self::head) and not(self::row)])]" priority="23" mode="#default">
    <table>
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates mode="table-simple"/>
    </table>
  </xsl:template>
  
  <xsl:template match="table/head" mode="table-simple">
    <caption>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </caption>
  </xsl:template>
  
  <xsl:template match="row" mode="table-simple">
    <tr>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </tr>
  </xsl:template>
  
  <xsl:template match="cell" mode="table-simple">
    <td>
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates select="@* | node()" mode="#default"/>
    </td>
  </xsl:template>
  
  <xsl:template match="table" mode="#default inside-p">
    <span class="block">
      <span>
        <xsl:call-template name="get-attributes"/>
        <xsl:apply-templates mode="table-complex"/>
      </span>
    </span>
  </xsl:template>
  
  <xsl:template match="cell" mode="table-complex">
    <xsl:variable name="cell" select="."/>
    <xsl:variable name="columns" as="xs:integer" 
      select="if ( @cols and xs:integer(@cols) gt 1 ) then @cols/data(.) else 1"/>
    <xsl:variable name="rows" as="xs:integer" 
      select="if ( @rows and xs:integer(@rows) gt 1 ) then @rows/data(.) else 1"/>
    <xsl:variable name="contents">
      <xsl:choose>
        <xsl:when test="node() and ancestor::p">
          <xsl:apply-templates mode="inside-p"/>
        </xsl:when>
        <xsl:when test="node()">
          <xsl:apply-templates mode="#default"/>
        </xsl:when>
        <!-- Empty <span> 'cells' have to have something inside them. -->
        <xsl:otherwise>
          <xsl:value-of select="$nbsp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="1 to $columns">
      <span>
        <xsl:choose>
          <xsl:when test="position() eq last()">
            <xsl:call-template name="get-attributes">
              <xsl:with-param name="start" select="$cell"/>
            </xsl:call-template>
            <xsl:copy-of select="$contents"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$columns gt 1">
              <xsl:attribute name="class" select="'colspanned'"/>
            </xsl:if>
            <xsl:value-of select="$nbsp"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:for-each>
  </xsl:template>
  
<!-- ELEMENTS THAT REQUIRE JUST A NEWLINE -->
  
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
  
<!-- PARAGRAPHS AND ELEMENTS THAT MIGHT APPEAR IN THEM -->
  
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
  
  <!-- Empty elements require placeholders. If no other template matches an element
    that happens to be empty, this one simply outputs a label with the TEI element 
    name. -->
  <xsl:template match="*[not(*)][normalize-space(.) eq '']" priority="-5" mode="#default inside-p">
    <span class="label-explanatory">
      <xsl:call-template name="get-attributes"/>
      <xsl:value-of select="$interjectStart"/>
      <xsl:value-of select="local-name(.)"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$interjectEnd"/>
    </span>
  </xsl:template>
  
  <xsl:template match="graphic | media" mode="#default inside-p">
    <xsl:variable name="hasURL" select="exists(@url) and normalize-space(@url) ne ''"/>
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
    <span class="media-obj">
      <xsl:call-template name="get-attributes"/>
      <!-- If the current element has an @url, create a link for it. -->
      <xsl:choose>
        <xsl:when test="$hasURL">
          <xsl:variable name="url" select="@url/data(.)"/>
          <a target="_blank">
            <xsl:attribute name="href" select="$url"/>
            <!-- TAPAS doesn't embed audio/video. Only images are given some kind of 
              visual indicator. -->
            <xsl:choose>
              <xsl:when test="self::graphic or contains(@mimeType,'image')">
                <img class="thumbnail" src="{$url}" 
                  alt="{$interjectStart}{$description}{$interjectEnd}"/>
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
        </xsl:when>
        <xsl:otherwise>
          <span class="label-explanatory">
            <xsl:value-of select="$interjectStart"/>
            <xsl:value-of select="$description"/>
            <xsl:value-of select="$interjectEnd"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
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
  
  
<!-- MODE: TEIHEADER -->
  
  <xsl:template match="*" mode="teiheader" priority="-30">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="teiheader">
    <xsl:param name="textAllowed" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:if test="$textAllowed">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc" mode="teiheader">
    <h3 class="expandable-heading box-c2">File Description</h3>
    <div id="fileDesc" class="expandable">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/titleStmt" mode="teiheader">
    <h4 class="expandable-heading box-c3">Title Statement</h4>
    <div id="titleStmt" class="expandable">
      <dl>
        <xsl:apply-templates select="* except title[1]" mode="#current"/>
      </dl>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/titleStmt/title[1]" mode="teiheader">
    <h1>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:if test="following-sibling::title">
        <small>
          <xsl:for-each select="following-sibling::title">
            <br></br>
            <xsl:apply-templates select="." mode="#current">
              <xsl:with-param name="isAllowed" select="true()"/>
              <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </small>
      </xsl:if>
    </h1>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/titleStmt/title[not(position() eq 1)]" mode="teiheader">
    <xsl:param name="isAllowed" select="false()" as="xs:boolean"/>
    <xsl:if test="$isAllowed">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="author | editor | funder | principal | sponsor" mode="teiheader">
    <dt>
      <xsl:choose>
        <xsl:when test="self::author">Author</xsl:when>
        <xsl:when test="self::editor">Editor</xsl:when>
        <xsl:when test="self::funder">Funder</xsl:when>
        <xsl:when test="self::principal">Principal researcher</xsl:when>
        <xsl:when test="self::sponsor">Sponsor</xsl:when>
      </xsl:choose>
    </dt>
    <dd><!-- XD: handle multiple names -->
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dd>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="teiheader">
    <xsl:apply-templates select="resp" mode="#current">
      <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="* except resp" mode="#current">
      <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="respStmt/resp" mode="teiheader">
    <dt>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dt>
  </xsl:template>
  
  <xsl:template match="respStmt/name | respStmt/orgName | respStmt/persName" mode="teiheader">
    <dd>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dd>
  </xsl:template>
  
  <xsl:template match="p" mode="teiheader">
    <p>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </p>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/publicationStmt" mode="teiheader">
    <h4 class="expandable-heading box-c3">Publication Statement</h4>
    <div id="publicationstmt" class="expandable expandable-hidden">
      <xsl:apply-templates select="* except availability" mode="#current"/>
      <xsl:apply-templates select="availability" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="publicationStmt/availability" mode="teiheader">
    <h5 class="expandable-heading box-c4">Availability</h5>
    <div id="availability" class="expandable">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="availability/licence[descendant::p]" mode="teiheader">
    <div>
      <xsl:if test="@target">
        <xsl:variable name="linkAddr" select="@target/data(.)"/>
        <p>
          <a href="{$linkAddr}" target="_blank">
            <xsl:value-of select="$linkAddr"/>
          </a>
        </p>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="availability/licence[not(descendant::p)]" mode="teiheader">
    <xsl:variable name="content" as="node()*">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <div>
      <p>
        <xsl:choose>
          <xsl:when test="@target">
            <a href="{@target/data(.)}" target="_blank">
              <xsl:copy-of select="$content"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </div>
  </xsl:template>
  
  <xsl:template match="address | publicationStmt/idno" mode="teiheader"/>
  
  <xsl:template match=" authority | publicationStmt/date | distributor 
                      | publisher | pubPlace" mode="teiheader">
    <span class="block">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/seriesStmt" mode="teiheader">
    <h4 class="expandable-heading box-c3">Series Statement</h4>
    <div id="seriesstmt" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="title" mode="teiheader" priority="-10">
    <span class="block">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/sourceDesc" mode="teiheader"/> <!-- XD -->
  
  <xsl:template match="teiHeader/encodingDesc" mode="teiheader">
    <h3 class="expandable-heading box-c2">Encoding Description</h3>
    <div id="encodingdesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/encodingDesc/projectDesc" mode="teiheader">
    <h4 class="expandable-heading box-c3">Project Description</h4>
    <div id="projectdesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/encodingDesc/editorialDecl" mode="teiheader">
    <h4 class="expandable-heading box-c3">Editorial Practice</h4>
    <div id="editorialdecl" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
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
    <xsl:param name="start" select="." as="node()"/>
    <!-- Create a data attribute with the name of the TEI element. -->
    <xsl:call-template name="save-gi">
      <xsl:with-param name="start" select="$start"/>
    </xsl:call-template>
    <!-- Create data attribute copies of the TEI attributes. -->
    <xsl:apply-templates select="$start/@*" mode="carry-on"/>
    <!-- Create a data attribute listing the names of the TEI attributes. -->
    <xsl:attribute name="data-tapas-attributes">
      <xsl:for-each select="$start/@*">
        <xsl:value-of select="./name()"/>
        <xsl:if test="position() ne last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:attribute>
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
            <span class="gi-name encoded encoded-gi"><xsl:value-of select="$gi"/></span>
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
    <xsl:param name="start" select="." as="node()"/>
    <xsl:attribute name="data-tapas-gi" select="local-name($start)"/>
  </xsl:template>
  
  <!-- Set a color class for a boxed element, based on its depth in the hierarchy. -->
  <xsl:template name="set-box-classes-depthwise">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:variable name="colorNum" select="$depth mod 10"/>
    <xsl:attribute name="class">
      <xsl:text>boxed box-c</xsl:text><xsl:value-of select="$colorNum"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Set data attributes, saving the TEI element's name and attribute values. This 
    is a convenience template for 'save-gi' followed by 'get-attributes'. -->
  <xsl:template name="set-data-attributes">
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="get-attributes"/>
  </xsl:template>
  
</xsl:stylesheet>