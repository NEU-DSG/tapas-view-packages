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
  
  <!--<xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This stylesheet performs a relatively simple mapping of TEI to HTML, using 
        data attributes to retain information about the TEI structure. A control box with 
        manipulatable form components allows reader exploration of a TEI document via 
        HTML and Javascript.</xd:p>
      <xd:p>Created by Ashley M. Clark for the 
        <xd:a href="http://tapas.northeastern.edu">TAPAS Project</xd:a>, 2017.</xd:p>
      
      <xd:p>Changelog:</xd:p>
      <xd:ul><!-\-
        <xd:li>DATE(, VERSION)?:
          <xd:ul>
            <xd:li></xd:li>
          </xd:ul>
        </xd:li>-\->
        <xd:li>2017-07-14, v0.1.0: Tweaked tunnelled depth parameters and added a legend 
          to boxed elements by color in 'Elements by frequency'.</xd:li>
        <xd:li>2017-07-10: Added 'Text contrast' widget, as well as an XSLT parameter 
          $contrast-default to change the default visibility of the text.</xd:li>
        <xd:li>2017-06-27, 2017-06-28:
          <xd:ul>
            <xd:li>Included select information from the &lt;teiHeader&gt; in 
              collapse-able sections separate from &lt;text&gt;.</xd:li>
            <xd:li>Moved some functionality to this XSLT from the Javascript so that no 
              information is hidden when Javascript is turned off or unavailable.</xd:li>
            <xd:li>Moved color palette for boxes to the LESS file, and moved the 
              algorithm for determining box color from the Javascript to this XSLT, in 
              the form of using the 'depth' parameter to assign classes to each 'box'.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-06-22: 
          <xd:ul>
            <xd:li>Added rules for displaying tables, and for faking tables when the TEI 
              structure isn't clean enough, or when the table occurs as a descendant of 
              &lt;p&gt;.</xd:li>
            <xd:li>Added 'Clicked element' widget: an empty list into which Javascript 
              will add a profile of the TEI element represented by the topmost clicked 
              div-box.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-06-21: Added rules for displaying images and other media, including 
          alt text (treated as interjectory).</xd:li>
        <xd:li>2017-06-19: Added 'Elements by frequency' widget, which includes radio 
          buttons for showing all instances of a given TEI element (as rendered in HTML).</xd:li>
        <xd:li>2017-06-16:
          <xd:ul>
            <xd:li>Marked empty elements with 'interjectory' labels.</xd:li>
            <xd:li>Added 'inside-p' mode to exclusively use &lt;html:span&gt;s inside 
              TEI/HTML paragraphs.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-06-09, v0.0.1: Created stylesheet and zoom controls.</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>-->
  
  <xsl:output indent="no" method="xhtml" omit-xml-declaration="yes"/>
  <xsl:include href="../common/odd-interpretation/tei-odd-interpreter.xsl"/>
  
<!-- PARAMETERS AND VARIABLES -->
  
  <xsl:param name="assets-base" select="'./'"/>
  <xsl:variable name="common-base" select="concat($assets-base,'../common/')"/>
  <xsl:variable name="css-base" select="concat($assets-base,'css/')"/>
  <xsl:variable name="js-base" select="concat($assets-base,'js/')"/>
  <xsl:param name="render-full-html"   select="false()" as="xs:boolean"/> <!-- set to 'true' to get browsable output for debugging -->
  <xsl:param name="contrast-default" select="'mid'" as="xs:string"/>
  
  <xsl:variable name="interjectStart">&lt;[ </xsl:variable>
  <xsl:variable name="interjectEnd"> ]&gt;</xsl:variable>
  <xsl:variable name="nbsp" select="'&#160;'"/>
  
<!-- FUNCTIONS -->
  
  <xsl:function name="tps:is-chunk-level" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of 
      select="exists($element[
                self::TEI or self::text or self::front or self::body or self::back 
              or self::ab or self::floatingText or self::lg or self::div
              or self::argument or self::group or self::table
              or self::div1 or self::div2 or self::div3 or self::div4 or self::div5 
              or self::div6 or self::div7 or self::titlePage
              or self::listBibl or self::listEvent or self::listOrg or self::listPerson 
              or self::listPlace or self::castList
              or self::bibl[parent::listBibl] or self::biblFull or self::biblStruct 
              or self::event or self::org or self::person or self::persona or self::place
              or self::performance or self::prologue or self::epilogue or self::set 
              or self::opener or self::closer or self::postscript
              or self::quote[descendant::p] or self::said[descendant::p]
              or self::figure or self::note or self::sp
              or self::attDef or self::attList or self::elementSpec or self::schemaSpec
              ])"/>
  </xsl:function>
  
  <xsl:function name="tps:has-only-element-children" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element/*) 
                      and not(exists($element/text()[normalize-space(.) ne '']))"/>
  </xsl:function>
  
  
<!-- TEMPLATES -->
  
  <xsl:template match="/">
    <xsl:variable name="main-transform" as="node()">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="boxedElements" select="$main-transform//*[@id eq 'tei-container']//*[@data-tapas-box-depth]/@data-tapas-gi"/>
    <xsl:apply-templates select="$main-transform" mode="postprocessing">
      <xsl:with-param name="boxedElements" select="$boxedElements" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="/TEI" priority="92">
    <xsl:variable name="language" 
      select="if ( @xml:lang ) then @xml:lang/data(.) else $defaultLanguage"/>
    <xsl:variable name="useLang" 
      select="if ( not(@xml:id) and text/@xml:id ) then 
                text/@xml:id/data(.)
              else $language"/>
    <xsl:variable name="body" as="node()">
      <div class="hieractivity">
        <xsl:if test="not($render-full-html)">
          <xsl:attribute name="lang" select="$useLang"/>
        </xsl:if>
        <!-- Metadata from the <teiHeader> -->
        <div id="tei-header">
          <xsl:apply-templates select="teiHeader">
            <xsl:with-param name="language" select="$language"/>
          </xsl:apply-templates>
        </div>
        <!-- The HTML representation of <text> -->
        <div id="tei-container">
          <xsl:attribute name="class">
            <xsl:text>text-contrast-</xsl:text>
            <xsl:choose>
              <xsl:when test="$contrast-default eq 'high'">
                <xsl:text>high</xsl:text>
              </xsl:when>
              <xsl:when test="$contrast-default eq 'mid'">
                <xsl:text>mid</xsl:text>
              </xsl:when>
              <xsl:when test="$contrast-default eq 'none'">
                <xsl:text>none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>low</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="text">
            <xsl:with-param name="language" select="$useLang"/>
          </xsl:apply-templates>
        </div>
        <!-- The control panel -->
        <xsl:call-template name="control-box"/>
      </div>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$render-full-html">
        <html>
          <xsl:attribute name="lang" select="$useLang"/>
          <head>
            <title>
              <xsl:value-of select="teiHeader/fileDesc/titleStmt/title[1]/normalize-space(.)"/>
            </title>
            <meta charset="UTF-8" />
            <link rel="stylesheet" type="text/css" href="{$common-base}jquery-ui-1.12.1/jquery-ui.min.css"></link>
            <link id="maincss" rel="stylesheet" type="text/css" href="{$css-base}hieractivity.css" ></link>
            <script src="{$common-base}jquery/jquery-3.2.1.min.js" type="text/javascript"></script>
            <script src="{$common-base}jquery-ui-1.12.1/jquery-ui.min.js" type="text/javascript"></script>
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
  
  <xsl:template match="*" mode="#default table-complex" priority="-7">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xsl:template match="@*" name="make-data-attr" mode="carry-on" priority="-20">
    <xsl:variable name="nsResolved" 
      select="if ( local-name() eq name() ) then name() 
              else translate(name(),':','-')"/>
    <xsl:variable name="attrName" 
      select="lower-case(replace($nsResolved, '([a-z])([A-Z])', '$1-$2'))"/>
    <xsl:attribute name="data-tapas-att-{$attrName}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match="teiHeader" priority="91">
    <xsl:param name="language" as="xs:string" required="yes"/>
    <xsl:apply-templates select="fileDesc/titleStmt/title[1]" mode="teiheader"/>
    <xsl:variable name="useLang" 
      select="if ( @xml:lang ) then @xml:lang/data(.) else $language"/>
    <xsl:variable name="changedLang" as="xs:boolean" select="$useLang ne $language"/>
    <h2 class="expandable-heading box-outermost">
      <xsl:if test="$changedLang">
        <xsl:attribute name="lang" select="$useLang"/>
      </xsl:if>
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:call-template>
    </h2>
    <div id="teiheader" class="expandable expandable-hidden">
      <xsl:if test="$changedLang">
        <xsl:attribute name="lang" select="$useLang"/>
      </xsl:if>
      <xsl:apply-templates mode="teiheader">
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="text" priority="90">
    <xsl:param name="depth" select="0" as="xs:integer" tunnel="yes"/>
    <xsl:param name="language" as="xs:string" required="yes"/>
    <xsl:variable name="useLang" 
      select="if ( @xml:lang ) then @xml:lang/data(.) else $language"/>
    <div class="boxed box-outermost">
      <xsl:if test="$useLang ne $language">
        <xsl:attribute name="lang" select="$useLang"/>
      </xsl:if>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <h2>
        <xsl:call-template name="gloss-gi">
          <xsl:with-param name="isHeading" select="true()"/>
          <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
        </xsl:call-template>
      </h2>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="floatingText" mode="#default inside-p" priority="89">
    <xsl:param name="depth" select="0" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-outermost'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="front | body | back" mode="#default inside-p" priority="88">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-outer'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="group" mode="#default inside-p" priority="87">
    <xsl:param name="depth" select="-1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="language" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-tabularasa'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="0" tunnel="yes"/>
        <xsl:with-param name="language" select="$language"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <!-- Block-level TEI elements will be used to create boxes in the HTML output. 
    Since CSS doesn't allow selecting on ancestors of nodes, we calculate the depth 
    (nestedness) of the current node here. -->
  <xsl:template match="*[tps:is-chunk-level(.)]" mode="#default inside-p">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="set-box-attributes-by-depth">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

<!-- LISTS -->

  <!-- For the purposes of this view package, the HTML element associated with 
    <tei:list> is not <ul>, but a wrapper <div> or <span>. This is because TEI 
    allows elements inside <list> that HTML would have no capacity to represent. -->
  <xsl:template match="list" mode="#default inside-p">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="isDescendantOfP" select="exists(ancestor::p)"/>
    <xsl:variable name="boxWrapper" select="if ( $isDescendantOfP ) then 'span' else 'div'"/>
    <xsl:variable name="listType" 
      select="if ( exists(label) ) then 'dl'
              else 'ul'"/>
    <xsl:variable name="listWrapper" select="if ( $isDescendantOfP ) then 'span' else $listType"/>
    <xsl:element name="{$boxWrapper}">
      <xsl:call-template name="set-box-attributes-by-depth">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <!-- Process any instances of model.divTop. -->
      <xsl:apply-templates select=" head | opener | signed | argument | byline 
                                  | dateline | docAuthor | docDate | epigraph 
                                  | meeting | salute" mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
      <!-- Process what should be list items. -->
      <xsl:element name="{$listWrapper}">
        <xsl:if test="$isDescendantOfP">
          <xsl:attribute name="class" select="concat('list-', $listType)"/>
        </xsl:if>
        <!-- XD: model.global can also be used anywhere in list. -->
        <xsl:apply-templates select="label | item" mode="#current">
          <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
      <!-- Process any instances of model.divBottom. -->
      <xsl:apply-templates select=" closer | postscript | signed | trailer | argument 
                                  | byline | dateline | docAuthor | docDate | epigraph 
                                  | meeting | salute" mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="list/item" mode="#default inside-p">
    <xsl:variable name="isDescendantOfP" select="exists(ancestor::p)"/>
    <xsl:variable name="listItemType"
      select="if ( parent::list[label] ) then 'dd' else 'li'"/>
    <xsl:variable name="wrapper" 
      select=" if ( $isDescendantOfP ) then 'span' else $listItemType"/>
    <xsl:element name="{$wrapper}">
      <xsl:if test="$isDescendantOfP">
        <xsl:attribute name="class" select="concat('list-item-',$listItemType)"/>
      </xsl:if>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="list/label" mode="#default inside-p">
    <xsl:variable name="isDescendantOfP" select="exists(ancestor::p)"/>
    <xsl:variable name="wrapper" 
      select=" if ( $isDescendantOfP ) then 'span' else 'dt'"/>
    <xsl:element name="{$wrapper}">
      <xsl:if test="$isDescendantOfP">
        <xsl:attribute name="class" select="'list-item-dt'"/>
      </xsl:if>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </xsl:element>
  </xsl:template>
  
<!-- TABLES -->
  
  <xsl:template match="table" priority="23" mode="#default inside-p">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="isDescendantOfP" select="exists(ancestor::p)"/>
    <xsl:variable name="isTableComplex" 
      select="if ( not(ancestor::p) and not(*[not(self::head | self::row)]) ) then false() else true()"/>
    <xsl:variable name="wrapper" 
      select=" if ( $isDescendantOfP ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="set-box-attributes-by-depth">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$isTableComplex">
          <span class="table">
            <xsl:apply-templates mode="table-complex">
              <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
            </xsl:apply-templates>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <table>
            <xsl:apply-templates mode="table-simple">
              <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
            </xsl:apply-templates>
          </table>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
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
  
  <xsl:template match="cell" mode="table-complex">
    <xsl:variable name="start" select="."/>
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
              <xsl:with-param name="start" select="$start"/>
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
  
  <xsl:template match="cell/@rows | cell/@cols" mode="#default">
    <xsl:variable name="data" select="data(.)"/>
    <xsl:if test="$data castable as xs:integer and xs:integer($data) gt 1">
      <xsl:variable name="attrName" select="substring-before(local-name(),'s')"/>
      <xsl:attribute name="{$attrName}span" select="$data"/>
    </xsl:if>
  </xsl:template>
  
<!-- ELEMENTS THAT REQUIRE JUST A NEWLINE -->
  
  <!-- TEI elements which do not warrant an <html:div> or <html:p>, but should have 
    "display: block". -->
  <xsl:template match=" head | l | stage | salute | signed
                      | listBibl/bibl[tps:has-only-element-children(.)]/* | biblFull/* | biblStruct/*
                      | event/* | org/* | person/* | place/*
                      | argument | byline | docAuthor | docDate | docEdition 
                      | docImprint | docTitle[not(titlePart)] | titlePart
                      | moduleRef" 
                mode="#default inside-p" priority="-6">
    <span class="block">
      <xsl:choose>
        <xsl:when test="not(*) and not(text())">
          <xsl:call-template name="gloss-empty"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="keep-calm-and-carry-on"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
<!-- PARAGRAPHS AND ELEMENTS THAT MIGHT APPEAR IN THEM -->
  
  <xsl:template match="p" mode="#default inside-p">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( ancestor::p ) then 'span' else 'p'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-p'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="inside-p">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
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
        <xsl:call-template name="gloss-gi"/>
        <xsl:if test="@*">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="@*" mode="show-att"/>
        </xsl:if>
        <xsl:value-of select="$interjectEnd"/>
      </span>
    </span>
  </xsl:template>
  
  <!-- Empty elements require placeholders. If no other template matches an element
    that happens to be empty, this one simply outputs a label with the TEI element 
    name. -->
  <xsl:template name="gloss-empty" match="*[not(*)][not(text())]" priority="-8" mode="#default inside-p">
    <span class="label-explanatory">
      <xsl:call-template name="get-attributes"/>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$interjectStart"/>
      <xsl:call-template name="gloss-gi"/>
      <xsl:if test="@*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="@*" mode="show-att"/>
      </xsl:if>
      <xsl:value-of select="$interjectEnd"/>
    </span>
  </xsl:template>
  
  <xsl:template match="graphic | media" mode="#default inside-p">
    <xsl:variable name="hasURL" select="exists(@url) and normalize-space(@url) ne ''"/>
    <xsl:variable name="description">
      <xsl:call-template name="count-preceding-of-type"/>
      <xsl:choose>
        <xsl:when test="desc or following-sibling::figDesc">
          <xsl:text>; described below.</xsl:text> <!-- XD: uses English -->
        </xsl:when>
        <xsl:when test="preceding-sibling::figDesc">
          <xsl:text>; described above.</xsl:text> <!-- XD: uses English -->
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
                <img class="thumbnail" src="{$url}" lang="en" 
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
        <xsl:call-template name="gloss-gi"/>
        <xsl:choose>
          <xsl:when test="desc">
            <xsl:value-of select="$contentDivider"/>
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:when test="@*">
            <xsl:text> </xsl:text>
            <!--<xsl:value-of select="$contentDivider"/>-->
            <xsl:apply-templates select="@*" mode="show-att"/>
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
      <xsl:call-template name="gloss-gi"/>
      <xsl:text>: </xsl:text>
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
  
  
<!-- MODE: SHOW-ATT -->

  <xsl:template match="@*" mode="show-att">
    <code>
      <xsl:text>@</xsl:text>
      <xsl:value-of select="name(.)"/>
    </code>
    <xsl:text>: "</xsl:text>
    <xsl:value-of select="data(.)"/>
    <xsl:text>"</xsl:text>
    <xsl:if test="position() ne last()">
      <xsl:text>; </xsl:text>
    </xsl:if>
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
    <h3 class="expandable-heading box-outer">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h3>
    <div id="fileDesc" class="expandable">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/titleStmt" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
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
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
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
  
  <xsl:template match="teiHeader/fileDesc/editionStmt" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="editionstmt" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/extent" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="fileextent" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/publicationStmt" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="publicationstmt" class="expandable">
      <xsl:apply-templates select="* except availability" mode="#current"/>
      <xsl:apply-templates select="availability" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="publicationStmt/availability" mode="teiheader">
    <h5 class="expandable-heading box-gen2">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h5>
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
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="seriesstmt" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc/notesStmt" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="notesstmt" class="expandable expandable-hidden">
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
    <h3 class="expandable-heading box-outer">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h3>
    <div id="encodingdesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/encodingDesc/projectDesc" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="projectdesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/encodingDesc/editorialDecl" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="editorialdecl" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/profileDesc" mode="teiheader">
    <h3 class="expandable-heading box-outer">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h3>
    <div id="profiledesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="profileDesc/*" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="{translate(lower-case(local-name(.)),'-','')}" 
      class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="teiHeader/revisionDesc" mode="teiheader">
    <h3 class="expandable-heading box-outer">
      <xsl:call-template name="gloss-gi">
        <xsl:with-param name="isHeading" select="true()"/>
      </xsl:call-template>
    </h3>
    <div id="revisiondesc" class="expandable expandable-hidden">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="revisionDesc//change" mode="teiheader">
    <span>
      <span class="change">
        <xsl:apply-templates select="@*" mode="show-att"/>
      </span>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="textAllowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>
  
  
<!-- MODE: POSTPROCESSING -->
  
  <xsl:template match="*" mode="postprocessing" priority="-10">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Create a legend for the colors assigned to the TEI element, if boxed. -->
  <xsl:template match="html:label[html:input[@name eq 'element']]" mode="postprocessing">
    <xsl:param name="boxedElements" tunnel="yes"/>
    <xsl:variable name="currentValue" select="html:input/@value"/>
    <xsl:variable name="distinctBoxed" select="distinct-values($boxedElements/data(.))"/>
    <xsl:variable name="width" select="10"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
      
      <xsl:if test="$currentValue eq 'p' or $currentValue = $distinctBoxed">
        <svg xmlns="http://www.w3.org/2000/svg" width="82%" height="12" class="legend">
          <xsl:choose>
            <!-- <p> isn't covered in $distinctBoxed, so it's handled separately. -->
            <xsl:when test="$currentValue eq 'p'">
              <rect width="{$width}" height="{$width}" class="legend-key box-p" 
                transform="translate(1 1)">
                <xsl:call-template name="set-legend-tooltip">
                  <xsl:with-param name="boxedElements" select="$boxedElements"/>
                  <xsl:with-param name="currentGI" select="$currentValue"/>
                  <xsl:with-param name="currentType" select="'box-p'"/>
                </xsl:call-template>
              </rect>
            </xsl:when>
            <!-- Handle all other elements that get boxed in the output. -->
            <xsl:when test="$currentValue = $distinctBoxed">
              <xsl:variable name="distinctTypes" as="xs:string+">
                <xsl:variable name="classes" 
                  select="$boxedElements[. eq $currentValue]/parent::html:*/@class"/>
                <xsl:variable name="boxTypes" as="xs:string+">
                  <xsl:for-each select="$classes">
                    <xsl:variable name="split" select="tokenize(data(.),' ')"/>
                    <xsl:value-of select="$split[contains(.,'box-')]"/>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:copy-of select="distinct-values($boxTypes)"/>
              </xsl:variable>
              <!--<xsl:message terminate="no">
                <xsl:value-of select="$distinctTypes"/>
              </xsl:message>-->
              <!-- For each class of box, add a rectangle to the legend. -->
              <xsl:for-each select="$distinctTypes">
                <xsl:variable name="thisType" select="."/>
                <xsl:variable name="translateX">
                  <xsl:variable name="prevBoxes" select="index-of($distinctTypes, $thisType) - 1"/>
                  <xsl:value-of select="$prevBoxes * $width  + 1"/>
                </xsl:variable>
                <rect width="{$width}" height="{$width}" class="legend-key {$thisType}"
                  transform="translate({$translateX} 1)">
                  <xsl:call-template name="set-legend-tooltip">
                    <xsl:with-param name="boxedElements" select="$boxedElements"/>
                    <xsl:with-param name="currentGI" select="$currentValue"/>
                    <xsl:with-param name="currentType" select="$thisType"/>
                  </xsl:call-template>
                </rect>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </svg>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  
<!-- SUPPLEMENTAL TEMPLATES -->
  
  <!-- Build out the control box and its widgets. -->
  <xsl:template name="control-box">
    <div id="control-panel" lang="en">
      <h2 class="expandable-heading">Controls</h2>
      <div id="controls-container" class="expandable">
        <!-- Zoom -->
        <div class="control-widget">
          <h3 class="expandable-heading">Zoom</h3>
          <div id="zoom-container" class="control-widget-component expandable">
            -
            <input id="zoom-slide" title="Zoom control slider" tabindex="1"
              type="range" min="20" max="100" step="1" value="100" />
            +
          </div>
        </div>
        <!-- Text contrast -->
        <div class="control-widget">
          <h3 class="expandable-heading">Text contrast</h3>
          <div id="text-contrasts" class="control-widget-component expandable expandable-hidden">
            <xsl:variable name="tabIndex" select="2"/>
            <fieldset id="text-contrast-selector" tabindex="2">
              <legend>Visibility</legend>
              <xsl:for-each select="( 'high', 'mid', 'low', 'none' )">
                <xsl:variable name="value" select="."/>
                <xsl:call-template name="make-radio-button">
                  <xsl:with-param name="fieldsetName" select="'contrast-type'"/>
                  <xsl:with-param name="value" select="$value"/>
                  <xsl:with-param name="isChecked" 
                    select="if ( $contrast-default eq $value ) then true() else false()"/>
                  <xsl:with-param name="tabIndex" 
                    select="if ( $contrast-default eq $value ) then $tabIndex else 9999"/>
                  <xsl:with-param name="label"
                    select="if ( $value eq 'none' ) then 'none (invisible text)' else $value"/>
                </xsl:call-template>
              </xsl:for-each>
            </fieldset>
          </div>
        </div>
        <!-- Elements by frequency -->
        <div class="control-widget">
          <h3 class="expandable-heading">Elements by frequency</h3>
          <div id="gi-frequencies" class="control-widget-component expandable">
            <fieldset id="gi-option-selector" tabindex="3">
              <legend>Mark</legend>
              <xsl:call-template name="gi-counting-robot">
                <xsl:with-param name="start" select="text"/>
              </xsl:call-template>
            </fieldset>
          </div>
        </div>
        <!-- Clicked element properties -->
        <div class="control-widget">
          <h3 class="expandable-heading">Clicked box</h3>
          <dl id="gi-properties" class="control-widget-component expandable"></dl>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <!-- For a given element, determine the number of preceding elements of the same 
    type that exist within <text>. -->
  <xsl:template name="count-preceding-of-type">
    <xsl:param name="element" select="." as="node()"/>
    <xsl:variable name="gi" select="$element/local-name(.)"/>
    <xsl:call-template name="gloss-gi">
      <xsl:with-param name="start" select="$element"/>
    </xsl:call-template>
    <xsl:text> #</xsl:text>
    <xsl:value-of select="count(preceding::*[local-name(.) eq $gi][ancestor::text]) + 1"/>
    <!--<xsl:text> of the TEI document</xsl:text>-->
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
    <xsl:variable name="fieldsetName" select="'element'"/>
    <xsl:variable name="allElements" select="$start/descendant-or-self::*/local-name(.)"/>
    <xsl:variable name="distinctGIs" select="distinct-values($allElements)"/>
    <xsl:call-template name="make-radio-button">
      <xsl:with-param name="fieldsetName" select="$fieldsetName"/>
      <xsl:with-param name="value" select="'none'"/>
      <xsl:with-param name="label">defaults only</xsl:with-param>
      <xsl:with-param name="isChecked" select="true()"/>
      <xsl:with-param name="tabIndex" select="4"/>
    </xsl:call-template>
    <xsl:variable name="options" as="item()*">
      <xsl:for-each select="$distinctGIs">
        <xsl:variable name="gi" select="."/>
        <xsl:variable name="count" select="count($allElements[. eq $gi])"/>
        <xsl:call-template name="make-radio-button">
          <xsl:with-param name="fieldsetName" select="$fieldsetName"/>
          <xsl:with-param name="value" select="$gi"/>
          <xsl:with-param name="label">
            <span class="gi-name encoded encoded-gi"><xsl:value-of select="$gi"/></span>
            <xsl:text> </xsl:text>
            <span class="gi-count"><xsl:value-of select="$count"/></span>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:perform-sort select="$options">
      <xsl:sort select="xs:integer(descendant::*:span[@class eq 'gi-count']/text())" order="descending"/>
      <xsl:sort select="descendant::html:span[contains(@class, 'gi-name')]/text()"/>
    </xsl:perform-sort>
  </xsl:template>
  
  <!-- Set data attributes, using the convenience template 'set-data-attributes'. 
    Then apply templates on child nodes. -->
  <xsl:template name="keep-calm-and-carry-on">
    <xsl:call-template name="set-data-attributes"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- Create a labelled radio button for the control box. -->
  <xsl:template name="make-radio-button">
    <xsl:param name="fieldsetName" as="xs:string" required="yes"/>
    <xsl:param name="value" as="xs:string" required="yes"/>
    <xsl:param name="label" select="$value"/>
    <xsl:param name="isChecked" select="false()" as="xs:boolean"/>
    <xsl:param name="tabIndex" select="9999" as="xs:integer"/>
    <label>
      <input type="radio" name="{$fieldsetName}" value="{$value}">
        <xsl:if test="$isChecked">
          <xsl:attribute name="checked" select="'checked'"/>
        </xsl:if>
        <xsl:if test="$tabIndex ne 9999">
          <xsl:attribute name="tabindex" select="$tabIndex"/>
        </xsl:if>
      </input>
      <span class="label-desc">
        <xsl:copy-of select="$label"/>
      </span>
    </label>
  </xsl:template>
  
  <!-- Create a data attribute to store the name of the current TEI element. -->
  <xsl:template name="save-gi">
    <xsl:param name="start" select="." as="node()"/>
    <xsl:attribute name="data-tapas-gi" select="local-name($start)"/>
  </xsl:template>
  
  <xsl:template name="set-box-attributes-by-depth">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:call-template name="set-box-classes-depthwise">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:call-template>
    <xsl:call-template name="set-data-attributes"/>
    <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
  </xsl:template>
  
  <!-- Set a color class for a boxed element, based on its depth in the hierarchy. -->
  <xsl:template name="set-box-classes-depthwise">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:variable name="colorNum" select="($depth - 1) mod 10"/>
    <xsl:attribute name="class">
      <xsl:text>boxed box-gen</xsl:text><xsl:value-of select="$colorNum"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Set data attributes, saving the TEI element's name and attribute values. This 
    is a convenience template for 'save-gi' followed by 'get-attributes'. -->
  <xsl:template name="set-data-attributes">
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="get-attributes"/>
  </xsl:template>
  
  <!-- Add an explanation of depth-based color handling to a legend key, which will be 
    used to populate a tooltip. -->
  <xsl:template name="set-legend-tooltip">
    <xsl:param name="boxedElements" as="attribute()+" required="yes"/>
    <xsl:param name="currentGI" as="xs:string" required="yes"/>
    <xsl:param name="currentType" as="xs:string+" required="yes"/>
    <xsl:variable name="sortedDepths" as="xs:string+">
      <xsl:variable name="depths" 
        select="distinct-values($boxedElements/parent::html:*
                  [matches(@data-tapas-gi/data(.), $currentGI)]
                  [matches(@class/data(.), concat($currentType,'( +.*)?$'))]
                /@data-tapas-box-depth/data(.))" as="xs:integer+"/>
      <xsl:for-each select="$depths">
        <xsl:sort select="." order="ascending"/>
        <xsl:copy-of select="xs:string(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:attribute name="title">
      <xsl:text>Box depth</xsl:text>
      <xsl:if test="count($sortedDepths) gt 1">
        <xsl:text>s</xsl:text>
      </xsl:if>
      <xsl:text> of </xsl:text>
      <xsl:value-of select="string-join($sortedDepths,', ')"/>
      <xsl:text> from &lt;text&gt; or &lt;floatingText&gt;.</xsl:text>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
