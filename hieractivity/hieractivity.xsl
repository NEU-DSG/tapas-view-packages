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
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This stylesheet performs a relatively simple mapping of TEI to HTML, using 
        data attributes to retain information about the TEI structure. A control box with 
        manipulatable form components allows reader exploration of a TEI document via 
        HTML and Javascript.</xd:p>
      <xd:p>Created by Ashley M. Clark for the 
        <xd:a href="http://tapas.northeastern.edu">TAPAS Project</xd:a>, 2017.</xd:p>
      
      <xd:p>Changelog:</xd:p>
      <xd:ul><!--
        <xd:li>DATE(, VERSION)?:
          <xd:ul>
            <xd:li></xd:li>
          </xd:ul>
        </xd:li>-->
        <xd:li>2017-10-23, v0.4.0: Added legends for the two color schemes, plus a 
          sublegend that is always shown, for elements that always get the same color 
          (e.g. &lt;text&gt;).
        </xd:li>
        <xd:li>2017-09-22, v0.3.0: Added element families: 'rhetorical', 'transcriptional', 
          'bibliographic', and 'choicepart'.</xd:li>
        <xd:li>2017-09-15:
          <xd:ul>
            <xd:li>Added &lt;caption&gt; and &lt;figDesc&gt; to list of box candidates.</xd:li>
            <xd:li>Expanded handling of children of &lt;encodingDesc&gt;.</xd:li>
            <xd:li>Added the 'boxed-gen' class for all boxes colored by depth rather than 
              identity.</xd:li>
            <xd:li>Created the first element family (name-likes) for the new familial mode, 
              which de-emphasizes depth in favor of pre-selected groups of elements.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-09-11:
          <xd:ul>
            <xd:li>Abstracted out the creation of &lt;teiHeader&gt; sections, simplifying code.</xd:li>
            <xd:li>Expanded handling of elements within the &lt;teiHeader&gt;.</xd:li>
            <xd:li>Allow the use of some standard templates within "teiheader" mode: &lt;p&gt;, 
              &lt;list&gt;, &lt;gi&gt;, &lt;att&gt;.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-09-01:
          <xd:ul>
            <xd:li>In empty element mode, added links for attributes with teidata.pointer 
              data.</xd:li>
            <xd:li>Used TEI's @xml:id and @xml:lang to populate HTML @id and @lang.</xd:li>
            <xd:li>Created a code block inside each &lt;constraint&gt;.</xd:li>
            <xd:li>Made "xml2code" mode a little more savvy about showing namespaces, 
              since prefixes aren't very useful here.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-08-31, v0.2.1:
          <xd:ul>
            <xd:li>Reduced the number of box classes available by depth.</xd:li>
            <xd:li>Sorted legend boxes by class (which now sorts by color in a rainbow 
              pattern).</xd:li>
            <xd:li>Added several ODD elements to the box candidates.</xd:li>
            <xd:li>Ensured that most non-TEI-namespaced elements are not represented in 
              the "Elements by frequency" widget. &lt;egXML&gt; is an exception.</xd:li>
            <xd:li>Used .encoded class for &lt;gi&gt; and &lt;att&gt;.</xd:li>
            <xd:li>Ensured that preformatted text will render inside &lt;html:p&gt;, with 
              the .preformatted class.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-08-23, v0.2.0:
          <xd:ul>
            <xd:li>Removed ODD interpretation due to too-long processing time in eXist. 
              The element name is output instead, with some attributes for glossing via 
              Javascript (currently unimplemented).</xd:li>
            <xd:li>Removed `ancestor::p` tests in favor of a tunnelled parameter 
              `$has-ancestor-p`.</xd:li>
            <xd:li>Added &lt;epigraph&gt; and &lt;q&gt; to box candidate testing.</xd:li>
            <xd:li>&lt;q&gt;, &lt;quote&gt;, and &lt;said&gt; are considered boxable if 
              they contain &lt;lg&gt;, not just &lt;p&gt;</xd:li>
            <xd:li>Added a template in post-processing to turn &lt;html:span&gt;s into 
              &lt;html:div&gt;s if they contain &lt;html:div&gt;s or &lt;html:p&gt;s 
              (which is invalid HTML).</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-08-17, v0.1.1:
          <xd:ul>
            <xd:li>Moved the control box between the &lt;teiHeader&gt; and &lt;text&gt;.</xd:li>
            <xd:li>Removed explicitly-stated tab-indexes, since the revised DOM order 
              should yield the correct tab order without intervention.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>2017-08-08: Separated camel-cased words in attribute names, solving a bug 
          where the Javascript was unable to identify the correct HTML data attribute.</xd:li>
        <xd:li>2017-08-07: Handle &lt;group&gt; with a new class 'box-tabularasa'.</xd:li>
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
    <xd:param name="assets-base">The path to a folder from which paths to specific CSS 
      and Javascript assets will be built.</xd:param>
    <xd:param name="contrast-default">The default contrast between text and background. 
      Valid choices: 'high', 'mid', 'low', 'none'. The default is 'mid'.</xd:param>
    <xd:param name="legend-icon-width">The width (in pixels) to use when creating legend 
      icons. The default is 20.</xd:param>
    <xd:param name="render-full-html">A parameter to toggle the generation of a complete 
      HTML page. By default, an HTML fragment starting at &lt;div&gt; is returned.</xd:param>
  </xd:doc>
  
  <xsl:output encoding="UTF-8" indent="no" method="xhtml" omit-xml-declaration="yes"/>
  
  
<!-- PARAMETERS AND VARIABLES -->
  
  <xsl:param name="assets-base" select="'./'"/>
  <xsl:variable name="common-base" select="concat($assets-base,'../common/')"/>
  <xsl:variable name="css-base" select="concat($assets-base,'css/')"/>
  <xsl:variable name="js-base" select="concat($assets-base,'js/')"/>
  <xsl:param name="render-full-html"   select="false()" as="xs:boolean"/> <!-- set to 'true' to get browsable output for debugging -->
  <xsl:param name="contrast-default" select="'mid'" as="xs:string"/>
  <xsl:param name="legend-icon-width" select="20" as="xs:integer"/>
  
  <xsl:variable name="css-class-map" as="node()*">
    <!-- The classes below are those boxes which are strictly based on element identity. -->
    <!--<class name="box-outermost">
      <span class="encoded encoded-gi">text</span>
      <span class="encoded encoded-gi">floatingText</span>
    </class>
    <class name="box-outer">
      <span class="encoded encoded-gi">body</span>
      <span class="encoded encoded-gi">front</span>
      <span class="encoded encoded-gi">back</span>
    </class>
    <class name="box-p">
      <span class="encoded encoded-gi">p</span>
    </class>
    <class name="box-tabularasa">
      <span class="encoded encoded-gi">group</span>
    </class>-->
    <!-- The classes below are those families into which phrase-level elements might be sorted. -->
    <class name="family-bibliographic">
      <span>bibliographic:</span>
    </class>
    <class name="family-choicepart">
      <span>choice parts:</span>
    </class>
    <class name="family-measurement">
      <span>measurements:</span>
    </class>
    <class name="family-namelike">
      <span>name-likes:</span>
    </class>
    <class name="family-rhetorical">
      <span>rhetorical:</span>
    </class>
    <class name="family-transcriptional">
      <span>transcriptional:</span>
    </class>
  </xsl:variable>
  <xsl:variable name="defaultLanguage" select="'en'"/>
  <xsl:variable name="interjectStart">&lt;[ </xsl:variable>
  <xsl:variable name="interjectEnd"> ]&gt;</xsl:variable>
  <xsl:variable name="nbsp" select="'&#160;'"/>
  
<!-- FUNCTIONS -->
  
  <xd:doc>
    <xd:desc>Given a CSS class name, get its description from the $css-class-map.</xd:desc>
    <xd:param name="classname">The class name which should be described.</xd:param>
  </xd:doc>
  <xsl:function name="tps:get-css-class-desc" as="node()*">
    <xsl:param name="classname" as="xs:string"/>
    <xsl:variable name="mapMatch" select="$css-class-map[@name eq $classname]"/>
    <xsl:if test="exists($mapMatch)">
      <xsl:copy-of select="$mapMatch/node()"/>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Test if an element has only elements as significant children. Text nodes 
      which contain only whitespace are do not count as significant here.</xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:has-only-element-children" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element/*) 
                      and not(exists($element/text()[normalize-space(.) ne '']))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Test if an attribute is expected to contain pointer data; that is, URLs or 
      anchors used in linking.</xd:desc>
    <xd:param name="attribute">The attribute to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:has-pointer-data" as="xs:boolean">
    <xsl:param name="attribute" as="attribute()"/>
    <xsl:value-of 
      select="$attribute/name() = 
              ( 'active', 'adj', 'adjFrom', 'adjTo', 'ana', 'calendar', 'change', 
                'children', 'class', 'code', 'copyOf', 'corresp', 'datcat', 
                'datingMethod', 'datingPoint', 'decls', 'domains', 'edRef', 'end', 
                'exclude', 'facs', 'feats', 'filter', 'follow', 'from', 'fVal', 'given', 
                'hand', 'inst', 'lemmaRef', 'location', 'mergedIn', 'mutual', 'new', 
                'next', 'nymRef', 'origin', 'parent', 'parts', 'passive', 'perf', 
                'period', 'prev', 'ref', 'rendition', 'require', 'resp', 'sameAs', 
                'scheme', 'scribeRef', 'scriptRef', 'select', 'since', 'source', 'spanTo', 
                'start', 'synch', 'target', 'targetEnd', 'to', 'uri', 'url', 'value', 
                'valueDatcat', 'where', 'who', 'wit', 'xml:base'
              )"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags used in bibliographic description.</xd:p>
      <xd:p>Tags were drawn from the TEI's <xd:a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.biblPart.html"
        >model.biblPart</xd:a>.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-bibliographic-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::author or self::availability or self::bibl 
              or self::biblScope or self::citedRange or self::distributor or self::edition 
              or self::editor or self::extent or self::funder or self::listRelation 
              or self::meeting or self::msIdentifier or self::principal or self::pubPlace 
              or self::publisher or self::relatedItem or self::respStmt or self::series 
              or self::sponsor or self::textLang or self::title
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags which, as possible children of 
        &lt;choice&gt;, indicate a facet of editorial identification or intervention.</xd:p>
      <xd:p>Tags were drawn primarily from the TEI's <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.choicePart.html"
        >model.choicePart</xd:a>, and include &lt;choice&gt; itself. &lt;seg&gt; is only 
        included if it occurs as a child of &lt;choice&gt;.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-choicepart-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::abbr or self::am or self::choice or self::corr  
              or self::ex or self::expan or self::orig or self::reg 
              or self::seg[parent::choice] or self::sic 
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Test if an element is chunk-able, and it should get its own 'box' in the 
      output HTML.</xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-chunk-level" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of 
      select="exists($element[
                self::TEI or self::text or self::front or self::body or self::back 
              or self::ab or self::floatingText or self::lg or self::div
              or self::argument or self::desc or self::epigraph or self::group or self::table
              or self::div1 or self::div2 or self::div3 or self::div4 or self::div5 
              or self::div6 or self::div7 or self::titlePage
              or self::listBibl or self::listEvent or self::listOrg or self::listPerson 
              or self::listPlace or self::listRef or self::castList
              or self::bibl[parent::listBibl] or self::biblFull or self::biblStruct 
              or self::event or self::org or self::person or self::persona or self::place
              or self::performance or self::prologue or self::epilogue or self::set 
              or self::opener or self::closer or self::postscript
              or self::q[descendant::p or descendant::lg] 
              or self::quote[descendant::p or descendant::lg] 
              or self::said[descendant::p or descendant::lg]
              or self::figure or self::caption or self::figDesc or self::note or self::sp
              or self::attDef or self::attList or self::classes or self::classSpec 
              or self::constraint or self::constraintSpec or self::dataSpec 
              or self::datatype or self::eg:egXML or self::elementSpec or self::exemplum 
              or self::macroSpec or self::moduleRef or self::moduleSpec or self::paramList 
              or self::paramSpec or self::remarks or self::schemaSpec or self::alternate 
              or self::content or self::sequence or self::valItem or self::valList
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Test if an element is empty—if it has no child elements and no text nodes.</xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-empty" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="not($element/*) and not($element/text())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags used to measurements.</xd:p>
      <xd:p>Tags were drawn from the TEI's <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.measureLike.html"
        >model.measureLike</xd:a> and <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.dateLike.html"
        >model.dateLike</xd:a>.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-measurement-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::date or self::depth or self::dim or self::geo 
              or self::height or self::measure or self::measureGrp or self::num or self::time 
              or self::width
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags used to indicate the names of 
        things.</xd:p>
      <xd:p>Tags were drawn from the TEI's <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.nameLike.html"
        >model.nameLike</xd:a>.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-namelike-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::addName or self::bloc or self::climate 
              or self::country or self::district or self::forename or self::genName 
              or self::geogFeat or self::geogName or self::idno or self::location 
              or self::lang or self::name or self::nameLink or self::offset or self::orgName 
              or self::persName or self::placeName or self::population or self::region 
              or self::roleName or self::rs or self::settlement or self::state 
              or self::surname or self::terrain or self::trait
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags indicating rhetorical, often 
        typographically distinct text.</xd:p>
      <xd:p>Tags were drawn from the TEI's <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.highlighted.html"
        >model.highlighted</xd:a>.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-rhetorical-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::distinct or self::emph or self::foreign 
              or self::gloss or self::hi or self::ident or self::mentioned or self::soCalled 
              or self::term
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Test if an element belongs to a family of tags used for editorial transcription.</xd:p>
      <xd:p>Tags were drawn from the TEI's <xd:a 
        href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-model.pPart.transcriptional.html"
        >model.pPart.transcriptional</xd:a>. The children of &lt;choice&gt; are not included.</xd:p>
    </xd:desc>
    <xd:param name="element">The element to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:is-transcriptional-candidate" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:value-of select="exists($element[self::add or self::damage or self::del or self::gap 
              or self::handShift or self::redo or self::restore or self::retrace or self::secl 
              or self::subst or self::supplied or self::surplus or self::unclear or self::undo
              ])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Test if an element is a member of a given HTML class.</xd:desc>
    <xd:param name="element">The element to test.</xd:param>
    <xd:param name="classnames">The class for which to test.</xd:param>
  </xd:doc>
  <xsl:function name="tps:matches-classnames" as="xs:boolean">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="classnames" as="xs:string+"/>
    <xsl:variable name="choiceOfClass" 
      select="if ( count($classnames) gt 1 ) then
                concat('(', string-join($classnames,'|'), ')')
              else $classnames
              "/>
    <xsl:value-of 
      select="exists($element[@class[matches(., concat($choiceOfClass,'( +.*)?$'))]])"/>
  </xsl:function>
  
  
<!-- TEMPLATES -->
  
  <xd:doc>
    <xd:desc>The input document goes through two passes. First, TEI elements are turned 
      into HTML, and those which should render as boxes are identified. In the second 
      pass, the 'boxed' elements are used to create SVG legends for the colors/depths 
      used for each type of TEI element.</xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:variable name="main-transform" as="node()">
      <xsl:document>
        <xsl:apply-templates/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="boxed-elements" 
      select="$main-transform//*[@id eq 'tei-container']//*[@data-tapas-box-depth]/@data-tapas-gi"/>
    <xsl:variable name="uniqueClasses" as="xs:string*">
      <xsl:variable name="boxClassAttrs" select="$boxed-elements/parent::*/@class" as="attribute()*"/>
      <xsl:variable name="splitTokens" as="xs:string*">
        <xsl:for-each select="$boxClassAttrs">
          <xsl:variable name="me" select="."/>
          <xsl:value-of select="tokenize(data($me),' ')[matches(.,'^box-')]"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each select="distinct-values($splitTokens)">
        <xsl:sort data-type="number"
          select="if ( . eq 'box-gen0' ) then 99
                  else if ( contains(., 'box-gen') ) then 
                    xs:integer(substring-after(.,'box-gen'))
                  else -1" order="ascending"/>
        <xsl:copy/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:apply-templates select="$main-transform" mode="postprocessing">
      <xsl:with-param name="boxed-elements" select="$boxed-elements" tunnel="yes"/>
      <xsl:with-param name="distinct-classes" select="$uniqueClasses" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create the structure of the HTML document, including a control panel. The 
      &lt;teiHeader&gt; is handled separately from &lt;text&gt;.</xd:desc>
  </xd:doc>
  <xsl:template match="/TEI" priority="92">
    <xsl:variable name="language" 
      select="if ( @xml:lang ) then @xml:lang/data(.) else $defaultLanguage"/>
    <xsl:variable name="useLang" 
      select="if ( not(@xml:id) and text/@xml:id ) then 
                text/@xml:id/data(.)
              else $language"/>
    <xsl:variable name="body" as="node()">
      <div class="hieractivity hieractivity-depthwise">
        <xsl:if test="not($render-full-html)">
          <xsl:attribute name="lang" select="$useLang"/>
        </xsl:if>
        <!-- Metadata from the <teiHeader> -->
        <div id="tei-header">
          <xsl:apply-templates select="teiHeader">
            <xsl:with-param name="language" select="$language"/>
          </xsl:apply-templates>
        </div>
        <!-- The control panel -->
        <xsl:call-template name="control-box"/>
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
          <div id="tei-resources-box">
            <xsl:apply-templates select="text">
              <xsl:with-param name="language" select="$useLang"/>
            </xsl:apply-templates>
          </div>
        </div>
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
            <script src="{$common-base}jquery.scrollTo/jquery.scrollTo.min.js" type="text/javascript"></script>
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
  
  <xd:doc>
    <xd:desc>Attributes aren't handled in default mode.</xd:desc>
  </xd:doc>
  <xsl:template match="@*" priority="-10"/>
  
  <xd:doc>
    <xd:desc>In default mode and 'table-complex' mode, most elements are turned into an 
      HTML &lt;span&gt;, with data attributes used to communicate what the TEI element 
      and its attributes originally looked like.</xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="#default table-complex" priority="-7">
    <span>
      <xsl:call-template name="keep-calm-and-carry-on"/>
    </span>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>The &lt;teiHeader&gt; is treated separately from &lt;text&gt;. 'teiheader' 
        mode is used to create nested boxes, only with headings and a metadata focus. The 
        headings of each  &lt;teiHeader&gt; component will, with Javascript, become 
        buttons to expand or collapse their content.</xd:p>
      <xd:p>The control box doesn't act on the &lt;teiHeader&gt;.</xd:p>
    </xd:desc>
    <xd:param name="language">The language code passed on from an ancestor node. If the 
      current node has its own language code defined, that code will be used instead.</xd:param>
  </xd:doc>
  <xsl:template match="teiHeader" priority="91">
    <xsl:param name="language" as="xs:string" required="yes"/>
    <xsl:apply-templates select="fileDesc/titleStmt/title[1]" mode="teiheader">
      <xsl:with-param name="is-doc-heading" select="true()"/>
    </xsl:apply-templates>
    <xsl:variable name="useLang" 
      select="if ( @xml:lang ) then @xml:lang/data(.) else $language"/>
    <xsl:variable name="changedLang" as="xs:boolean" select="$useLang ne $language"/>
    <h2 class="expandable-heading box-outermost">
      <xsl:if test="$changedLang">
        <xsl:attribute name="lang" select="$useLang"/>
      </xsl:if>
      <xsl:call-template name="glossable-gi">
        <xsl:with-param name="is-heading" select="true()"/>
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:call-template>
    </h2>
    <div id="teiheader" class="expandable expandable-hidden">
      <xsl:if test="$changedLang">
        <xsl:attribute name="lang" select="$useLang"/>
      </xsl:if>
      <xsl:apply-templates mode="teiheader">
        <xsl:with-param name="depth" select="-1" tunnel="yes"/>
        <xsl:with-param name="has-ancestor-teiheader" select="true()" tunnel="yes"/>
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Since this stylesheet does not handle &lt;teiCorpus&gt;, &lt;text&gt; forms 
      the outermost 'box' of the output HTML, and should always initiate tunnelled depth 
      counts.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="language">The language code passed on from an ancestor node. If the 
      current node has its own language code defined, that code will be used instead.</xd:param>
  </xd:doc>
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
        <xsl:call-template name="glossable-gi">
          <xsl:with-param name="is-heading" select="true()"/>
          <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
        </xsl:call-template>
      </h2>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        <xsl:with-param name="language" select="$useLang" tunnel="yes"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Like &lt;text&gt;, &lt;floatingText&gt; is considered an outermost box. The 
      tunnelled depth starts over at 1.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="floatingText" mode="#default inside-p" priority="89">
    <xsl:param name="depth" select="0" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-outermost'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>&lt;front&gt;, &lt;body&gt;, and &lt;back&gt; are predictable children of
      &lt;text&gt;, and so they are classed as 'box-outer' rather than 'box-outermost'.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="front | body | back" mode="#default inside-p" priority="88">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:attribute name="class" select="'boxed box-outer'"/>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>&lt;group&gt; generally holds &lt;text&gt;s, so this box requires a 
      'box-tabularasa' class to set it off from its relatives. The tunnelled depth starts 
      over at 0.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
    <xd:param name="language">The language code passed on from an ancestor node. If the 
      current node has its own language code defined, that code will be used instead.</xd:param>
  </xd:doc>
  <xsl:template match="group" mode="#default inside-p" priority="87">
    <xsl:param name="depth" select="-1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="language" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
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
  
  <xd:doc>
    <xd:desc>Block-level TEI elements will be used to create boxes in the HTML output. 
      Since CSS doesn't allow selecting on ancestors of nodes, we calculate the depth 
      (nestedness) of the current node here.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="*[tps:is-chunk-level(.)]" mode="#default inside-p">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
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

  <xd:doc>
    <xd:desc>For the purposes of this view package, the HTML element associated with 
      &lt;tei:list&gt; is not &lt;ul&gt;, but a wrapper &lt;div&gt; or &lt;span&gt;. This 
      is because TEI allows elements inside &lt;list&gt; that HTML would have no capacity 
      to represent.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
    <xd:param name="has-ancestor-teiheader">A boolean value which indicates if the current 
      node occurs as a descendant of the &lt;teiHeader&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="list" mode="#default inside-p teiheader">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="listType" 
      select="if ( exists(label) ) then 'dl'
              else 'ul'"/>
    <xsl:variable name="listWrapper" select="if ( $has-ancestor-p ) then 'span' else $listType"/>
    <xsl:variable name="contents" as="node()*">
      <!-- Process any instances of model.divTop. -->
      <xsl:apply-templates select=" head | opener | signed | argument | byline 
                                  | dateline | docAuthor | docDate | epigraph 
                                  | meeting | salute" mode="#current">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
      </xsl:apply-templates>
      <!-- Process what should be list items. -->
      <xsl:element name="{$listWrapper}">
        <xsl:if test="$has-ancestor-p">
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
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$has-ancestor-teiheader">
        <xsl:copy-of select="$contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="boxWrapper" 
          select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
        <xsl:element name="{$boxWrapper}">
          <xsl:call-template name="set-box-attributes-by-depth">
            <xsl:with-param name="depth" select="$depth"/>
          </xsl:call-template>
          <xsl:copy-of select="$contents"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="list/item" mode="#default inside-p teiheader">
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="listItemType"
      select="if ( parent::list[label] ) then 'dd' else 'li'"/>
    <xsl:variable name="wrapper" 
      select=" if ( $has-ancestor-p ) then 'span' else $listItemType"/>
    <xsl:element name="{$wrapper}">
      <xsl:if test="$has-ancestor-p">
        <xsl:attribute name="class" select="concat('list-item-',$listItemType)"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$has-ancestor-teiheader">
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="keep-calm-and-carry-on"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="list/label" mode="#default inside-p teiheader">
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" 
      select=" if ( $has-ancestor-p ) then 'span' else 'dt'"/>
    <xsl:element name="{$wrapper}">
      <xsl:if test="$has-ancestor-p">
        <xsl:attribute name="class" select="'list-item-dt'"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$has-ancestor-teiheader">
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="keep-calm-and-carry-on"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
<!-- TABLES -->
  
  <xd:doc>
    <xd:desc>Like &lt;list&gt;, a TEI &lt;table&gt; becomes a boxed HTML wrapper around 
      tabular content. If the TEI table can be mapped onto an HTML table, 'table-simple' 
      mode is used on its content. Otherwise, 'table-complex' mode fakes an HTML table 
      using &lt;span&gt;s and CSS.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="table" priority="23" mode="#default inside-p">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="isTableComplex" 
      select="if ( not($has-ancestor-p) and not(*[not(self::head | self::row)]) ) then false() else true()"/>
    <xsl:variable name="wrapper" 
      select=" if ( $has-ancestor-p ) then 'span' else 'div'"/>
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
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="start" select="."/>
    <xsl:variable name="columns" as="xs:integer" 
      select="if ( @cols and xs:integer(@cols) gt 1 ) then @cols/data(.) else 1"/>
    <xsl:variable name="rows" as="xs:integer" 
      select="if ( @rows and xs:integer(@rows) gt 1 ) then @rows/data(.) else 1"/>
    <xsl:variable name="contents">
      <xsl:choose>
        <xsl:when test="node() and $has-ancestor-p">
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
  
  <xd:doc>
    <xd:desc>TEI elements which do not warrant an &lt;html:div&gt; or &lt;html:p&gt;, but 
      should have the CSS rule "display: block".</xd:desc>
  </xd:doc>
  <xsl:template match=" head | l | stage | salute | signed
                      | listBibl/bibl[tps:has-only-element-children(.)]/* | biblFull/* | biblStruct/*
                      | event/* | org/* | person/* | place/*
                      | argument | byline | docAuthor | docDate | docEdition 
                      | docImprint | docTitle[not(titlePart)] | titlePart
                      | anyElement | classRef | constraint/* | dataFacet | dataRef | elementRef 
                      | empty | macroRef | memberOf | listRef/ptr | textNode"
                mode="#default inside-p" priority="-5">
    <span class="block">
      <xsl:choose>
        <xsl:when test="not(node())">
          <xsl:call-template name="gloss-empty"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="keep-calm-and-carry-on"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
<!-- PARAGRAPHS AND ELEMENTS THAT MIGHT APPEAR IN THEM -->
  
  <xd:doc>
    <xd:desc>TEI &lt;p&gt;s are treated as a special kind of boxed element, with their 
      own class 'box-p'. They map easily onto HTML &lt;p&gt;s, but, since HTML doesn't 
      allow &lt;p&gt;s inside &lt;p&gt;s, &lt;span&gt; may be used instead.</xd:desc>
    <xd:param name="depth">A tunnelled parameter passed on from ancestor elements which 
      will render as boxes, used to calculate the depth of the current box from a box 
      representing &lt;text&gt; or &lt;floatingText&gt;.</xd:param>
    <xd:param name="has-ancestor-p">A boolean value which indicates if the current node 
      occurs as a descendant of &lt;p&gt;.</xd:param>
    <xd:param name="has-ancestor-teiheader">A boolean value which indicates if the current 
      node occurs as a descendant of the &lt;teiHeader&gt;.</xd:param>
  </xd:doc>
  <xsl:template match="p" mode="#default inside-p teiheader">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'p'"/>
    <xsl:choose>
      <xsl:when test="$has-ancestor-teiheader">
        <xsl:element name="{$wrapper}">
          <xsl:apply-templates mode="teiheader">
            <xsl:with-param name="has-ancestor-p" select="true()" tunnel="yes"/>
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$wrapper}">
          <xsl:attribute name="class" select="'boxed box-p'"/>
          <xsl:call-template name="set-data-attributes"/>
          <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
          <xsl:apply-templates mode="inside-p">
            <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
            <xsl:with-param name="has-ancestor-p" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
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
        <xsl:call-template name="glossable-gi"/>
        <xsl:if test="@*">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="@*" mode="show-att"/>
        </xsl:if>
        <xsl:value-of select="$interjectEnd"/>
      </span>
    </span>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Empty elements require placeholders. If no other template matches an element
      that happens to be empty, this one simply outputs a label with the TEI element 
      name and a list of attributes.</xd:desc>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
    <xd:param name="has-wrapper">An optional toggle indicating whether there is a wrapper for 
      the triggering element. If there is a wrapper, the data attributes identifying the 
      output &lt;span&gt; as such will be suppressed, since they would already occur on the 
      wrapper. The default is to assume there is no wrapper.</xd:param>
  </xd:doc>
  <xsl:template name="gloss-empty" match="*[not(*)][not(text())]" priority="-6" mode="#default inside-p">
    <xsl:param name="start" select="." as="node()"/>
    <xsl:param name="has-wrapper" select="false()" as="xs:boolean"/>
    <span class="label-explanatory">
      <xsl:if test="not($has-wrapper)">
        <xsl:call-template name="get-attributes">
          <xsl:with-param name="start" select="$start"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates select="$start/@*"/>
      <xsl:value-of select="$interjectStart"/>
      <xsl:call-template name="glossable-gi"/>
      <xsl:if test="$start/@*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$start/@*" mode="show-att"/>
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
          <span lang="en">
            <xsl:text>; described below.</xsl:text>
          </span>
        </xsl:when>
        <xsl:when test="preceding-sibling::figDesc">
          <span lang="en">
          <xsl:text>; described above.</xsl:text>
          </span>
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
  
  <xsl:template match="constraint | eg:egXML" mode="#default inside-p" priority="20">
    <xsl:param name="depth" select="2" as="xs:integer" tunnel="yes"/>
    <xsl:param name="has-ancestor-p" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="wrapper" select="if ( $has-ancestor-p ) then 'span' else 'div'"/>
    <xsl:element name="{$wrapper}">
      <xsl:call-template name="set-box-attributes-by-depth">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:variable name="contents" as="node()*">
        <xsl:choose>
          <xsl:when test="self::eg:egXML">
            <xsl:apply-templates mode="xml2code">
              <xsl:with-param name="ns-bestowed" select="namespace-uri()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="xml2code"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="preLike" select="if ( $has-ancestor-p ) then 'span' else 'pre'"/>
      <xsl:element name="{$preLike}">
        <xsl:attribute name="class" select="'preformatted'"/>
        <code><xsl:copy-of select="$contents"/></code>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="att | code | gi" mode="#default inside-p teiheader">
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <span class="encoded">
      <xsl:if test="not($has-ancestor-teiheader)">
        <xsl:call-template name="set-data-attributes"/>
      </xsl:if>
      <xsl:if test="self::att">
        <xsl:text>@</xsl:text>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>
  
  <xsl:template match="tag" mode="#default inside-p teiheader">
    <xsl:param name="has-ancestor-teiheader" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:variable name="useType">
      <xsl:variable name="validTypes" as="xs:string+" 
        select="('start', 'end', 'empty', 'pi', 'comment', 'ms')"/>
      <xsl:value-of select="if ( @type and @type = $validTypes ) then 
                              @type/data(.) 
                            else 'start'"/>
    </xsl:variable>
    <xsl:variable name="delimiterStart"
      select=" if ( $useType eq 'end' ) then '&lt;/'
          else if ( $useType eq 'pi' ) then '&lt;?'
          else if ( $useType eq 'comment' ) then '&lt;!--'
          else if ( $useType eq 'ms' ) then '&lt;]CDATA['
          else '&lt;'"/>
    <xsl:variable name="delimiterEnd"
      select=" if ( $useType eq 'empty' ) then '/&gt;'
          else if ( $useType eq 'pi' ) then '?&gt;'
          else if ( $useType eq 'comment' ) then '--&gt;'
          else if ( $useType eq 'ms' ) then ']]&gt;'
          else '&gt;'"/>
    <span class="encoded">
      <xsl:if test="not($has-ancestor-teiheader)">
        <xsl:call-template name="set-data-attributes"/>
      </xsl:if>
      <xsl:copy-of select="$delimiterStart"/>
      <xsl:apply-templates mode="#current"/>
      <xsl:copy-of select="$delimiterEnd"/>
    </span>
  </xsl:template>
  
  <xsl:template match="gap" mode="#default inside-p">
    <xsl:variable name="contentDivider" select="': '"/>
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-transcriptional'"/>
      <xsl:with-param name="contents" as="node()*">
        <span class="label-explanatory">
          <xsl:value-of select="$interjectStart"/>
          <xsl:call-template name="glossable-gi"/>
          <xsl:choose>
            <xsl:when test="desc">
              <xsl:value-of select="$contentDivider"/>
              <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:when test="@*">
              <xsl:text> </xsl:text>
              <!--<xsl:value-of select="$contentDivider"/>-->
              <xsl:apply-templates select="@*" mode="show-att"/>
            </xsl:when>
          </xsl:choose>
          <xsl:value-of select="$interjectEnd"/>
        </span>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="choice" mode="#default inside-p">
    <xsl:param name="familial-depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="additional-classes" select="'label-explanatory'" tunnel="yes"/>
      <xsl:with-param name="family-class" select="'family-choicepart'"/>
      <xsl:with-param name="contents">
        <xsl:value-of select="$interjectStart"/>
        <xsl:call-template name="glossable-gi"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="familial-depth" select="$familial-depth + 1" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:value-of select="$interjectEnd"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Whitespace inside &lt;choice&gt; is thrown away.</xd:desc>
  </xd:doc>
  <xsl:template match="choice/text()" mode="#default inside-p"/>
  
  <xsl:template match="choice/*[preceding-sibling::*]" mode="#default inside-p">
    <xsl:text> | </xsl:text>
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-choicepart'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-bibliographic-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-bibliographic'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-choicepart-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-choicepart'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-measurement-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-measurement'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-namelike-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-namelike'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-rhetorical-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-rhetorical'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[tps:is-transcriptional-candidate(.)]" mode="#default inside-p" priority="-4">
    <xsl:call-template name="make-familial-candidate">
      <xsl:with-param name="family-class" select="'family-transcriptional'"/>
    </xsl:call-template>
  </xsl:template>
  
  
<!-- MODE: CARRY-ON -->
  
  <xsl:template match="@*" name="make-data-attr" mode="carry-on" priority="-20">
    <xsl:variable name="nsResolved" 
      select="if ( local-name() eq name() ) then name() 
      else translate(name(),':','-')"/>
    <xsl:variable name="attrName" 
      select="lower-case(replace($nsResolved, '([a-z])([A-Z])', '$1-$2'))"/>
    <xsl:attribute name="data-tapas-att-{$attrName}" select="data(.)"/>
  </xsl:template>
  
  <xsl:template match="@xml:id" mode="carry-on">
    <xsl:attribute name="id" select="concat('tps-',data(.))"/>
    <xsl:call-template name="make-data-attr"/>
  </xsl:template>
  
  <xsl:template match="@xml:lang" mode="carry-on">
    <xsl:attribute name="lang" select="data(.)"/>
    <xsl:call-template name="make-data-attr"/>
  </xsl:template>
  
  
<!-- MODE: SHOW-ATT -->

  <xd:doc>
    <xd:desc>In "show-att" mode, each attribute is described by its name and its content. 
      This is useful for making empty elements visible in the output.</xd:desc>
    <xd:param name="attribute-data">An optional sequence of nodes to be used in place of 
      a simple export of the attribute's data.</xd:param>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
  </xd:doc>
  <xsl:template name="describe-attribute" match="@*" mode="show-att" priority="-19">
    <xsl:param name="attribute-data" as="node()*"/>
    <xsl:param name="start" select="." as="node()"/>
    <code>
      <xsl:text>@</xsl:text>
      <xsl:value-of select="name($start)"/>
      <xsl:text>="</xsl:text>
    </code>
    <xsl:choose>
      <xsl:when test="exists($attribute-data)">
        <xsl:copy-of select="$attribute-data"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="data(.)"/>
      </xsl:otherwise>
    </xsl:choose>
    <code>
      <xsl:text>"</xsl:text>
    </code>
    <xsl:if test="$start/position() ne last()">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>If an attribute is expected to contain one or more pointers (URLs, anchors), 
      each pointer gets its own HTML link when spelled out by a shown empty element.</xd:desc>
    <xd:param name="suppress-links">An optional toggle to suppress linking within the 
      spelled-out attribute. The default is to use linking.</xd:param>
  </xd:doc>
  <xsl:template match="@*[tps:has-pointer-data(.)]" mode="show-att">
    <xsl:param name="suppress-links" select="false()" as="xs:boolean"/>
    <xsl:variable name="pointerSeq" select="tokenize(data(.), '\s+')"/>
    <xsl:variable name="links" as="node()*">
      <xsl:choose>
        <xsl:when test="$suppress-links">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="1 to count($pointerSeq)">
            <xsl:variable name="index" select="."/>
            <xsl:variable name="urlVal" select="$pointerSeq[$index]"/>
            <a>
              <xsl:choose>
                <xsl:when test="starts-with($urlVal,'#')">
                  <xsl:variable name="modifiedAnchor" 
                    select="concat('#tps-', substring-after($urlVal,'#'))"/>
                  <xsl:attribute name="href" select="$modifiedAnchor"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="href" select="$urlVal"/>
                  <xsl:attribute name="target" select="'_blank'"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$urlVal"/>
            </a>
            <xsl:if test="$index ne count($pointerSeq)">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="describe-attribute">
      <xsl:with-param name="attribute-data" select="$links"/>
    </xsl:call-template>
  </xsl:template>


<!-- MODE: XML2CODE -->

  <xd:doc>
    <xd:desc>
      <xd:p>In "xml2code" mode, each element is string-ified for use in an HTML code 
        block.</xd:p>
      <xd:p>Since there is no easy way to serialize a portion of XML as text, I've chosen 
        to recreate elements using entity references and a strict pattern for escaped, 
        well-formed XML. The main weakness of this approach is that any non-significant 
        whitespace is removed from inside an element tag, which may affect the 
        readability of the encoding. Similarly, the template cannot distinguish between 
        self-closed tags and empty elements with both start and end tags.</xd:p>
    </xd:desc>
    <xd:param name="ns-bestowed">An optional parameter containing the namespace bestowed by 
      the parent element.</xd:param>
  </xd:doc>
  <xsl:template match="*" mode="xml2code" priority="-10">
    <xsl:param name="ns-bestowed" as="xs:anyURI?"/>
    <xsl:variable name="gi" select="local-name()"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="$gi"/>
    <xsl:if test="not(exists($ns-bestowed)) or $ns-bestowed ne namespace-uri()">
      <!--<xsl:message>Element <xsl:value-of select="$gi"/> is in namespace <xsl:value-of select="namespace-uri()"/></xsl:message>-->
      <xsl:text> xmlns="</xsl:text>
      <xsl:value-of select="namespace-uri()"/>
      <xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:if test="@*">
      <xsl:apply-templates select="@*" mode="#current"/>
    </xsl:if>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="ns-bestowed" select="namespace-uri()"/>
    </xsl:apply-templates>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="$gi"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
  
  <xsl:template match="@*" mode="xml2code">
    <xsl:variable name="contents" select="data(.)"/>
    <xsl:variable name="attrQuote">
      <xsl:choose>
        <xsl:when test="contains($contents, '&quot;')">
          <xsl:text>'</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>"</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="$attrQuote"/>
    <xsl:value-of select="$contents"/>
    <xsl:value-of select="$attrQuote"/>
  </xsl:template>


<!-- MODE: TEIHEADER -->
  
  <xsl:template match="*" mode="teiheader" priority="-30">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="teiheader">
    <xsl:param name="text-allowed" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:if test="$text-allowed">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="teiHeader/fileDesc | titleStmt" mode="teiheader">
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="is-hidden" select="false()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="editionStmt | profileDesc/*[not(self::langUsage)]" mode="teiheader">
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="fileDesc/extent | supportDesc/extent" mode="teiheader">
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="contents">
        <p>
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </p>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="publicationStmt" mode="teiheader">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="contents">
        <xsl:apply-templates select="* except availability" mode="#current"/>
        <xsl:apply-templates select="availability" mode="#current">
          <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:with-param>
      <xsl:with-param name="is-hidden" select="false()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="publicationStmt/availability" mode="teiheader">
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="is-hidden" select="false()"/>
      <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match=" sourceDesc | sourceDesc/recordingStmt | sourceDesc/scriptStmt 
                      | seriesStmt | notesStmt | encodingDesc 
                      | encodingDesc/appInfo | encodingDesc/charDecl | encodingDesc/classDecl
                      | encodingDesc/editorialDecl | correction | hyphenation | interpretation 
                      | normalization | punctuation | quotation | segmentation | stdVals
                      | encodingDesc/fsdDecl | encodingDesc/listPrefixDef 
                      | encodingDesc/projectDesc | encodingDesc/refsDecl 
                      | encodingDesc/samplingDecl | encodingDesc/transcriptionDesc 
                      | profileDesc | revisionDesc" mode="teiheader">
    <xsl:call-template name="make-teiheader-section"/>
  </xsl:template>
  
  <xsl:template match="profileDesc/langUsage" mode="teiheader">
    <xsl:choose>
      <xsl:when test="language">
        <xsl:call-template name="make-teiheader-section">
          <xsl:with-param name="contents">
            <dl>
              <xsl:apply-templates mode="#current"/>
            </dl>
          </xsl:with-param>
          <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-teiheader-section">
          <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="textDesc" mode="teiheader">
    <xsl:call-template name="make-teiheader-section">
      <xsl:with-param name="contents">
        <dl>
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="textDesc/*" mode="teiheader">
    <dt>
      <xsl:call-template name="glossable-gi"/>
    </dt>
    <xsl:for-each select="@*">
      <dd>
        <xsl:call-template name="describe-attribute"/>
      </dd>
    </xsl:for-each>
    <xsl:if test="text() or *">
      <dd>
        <xsl:apply-templates mode="#current"/>
      </dd>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="language" mode="teiheader">
    <dt>
      <xsl:value-of select="@ident"/>
    </dt>
    <dd>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dd>
  </xsl:template>
  
  <!--<xsl:template match="teiHeader/fileDesc/titleStmt" mode="teiheader">
    <h4 class="expandable-heading box-gen1">
      <xsl:call-template name="glossable-gi">
        <xsl:with-param name="is-heading" select="true()"/>
      </xsl:call-template>
    </h4>
    <div id="titleStmt" class="expandable">
      <dl>
        <xsl:apply-templates select="*" mode="#current"/>
      </dl>
    </div>
  </xsl:template>-->
  
  <xsl:template match="fileDesc/titleStmt/title[1]" mode="teiheader">
    <xsl:param name="is-doc-heading" select="false()" as="xs:boolean"/>
    <xsl:element name="{ if ( $is-doc-heading ) then 'h1' else 'p' }">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:if test="following-sibling::title">
        <small>
          <xsl:for-each select="following-sibling::title">
            <br></br>
            <xsl:apply-templates select="." mode="#current">
              <xsl:with-param name="is-allowed" select="true()"/>
              <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:for-each>
        </small>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="fileDesc/titleStmt/title[not(position() eq 1)]" mode="teiheader">
    <xsl:param name="is-allowed" select="false()" as="xs:boolean"/>
    <xsl:if test="$is-allowed">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="fileDesc/titleStmt//title" priority="-1" mode="teiheader">
    <xsl:param name="text-allowed" select="false()" as="xs:boolean" tunnel="yes"/>
    <xsl:if test="$text-allowed">
      <xsl:apply-templates mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="author | editor | funder | principal | sponsor" mode="teiheader">
    <dt>
      <xsl:call-template name="glossable-gi">
        <xsl:with-param name="is-heading" select="true()"/>
      </xsl:call-template>
    </dt>
    <dd><!-- XD: handle multiple names -->
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dd>
  </xsl:template>
  
  <xsl:template match="respStmt" mode="teiheader">
    <xsl:apply-templates select="resp" mode="#current">
      <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="* except resp" mode="#current">
      <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="respStmt/resp" mode="teiheader">
    <dt>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dt>
  </xsl:template>
  
  <xsl:template match="respStmt/name | respStmt/orgName | respStmt/persName" mode="teiheader">
    <dd>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </dd>
  </xsl:template>
  
  <xsl:template match=" editionStmt/edition | notesStmt[count(*) eq 1]/note 
                      | notesStmt[count(*) eq 1]/witDetail" mode="teiheader">
    <p>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </p>
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
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
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
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>
  
  <xsl:template match=" title 
                      | bibl[not(ancestor::p)][tps:has-only-element-children(.)]/*" 
                mode="teiheader" priority="-10">
    <span class="block">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>
  
  <xsl:template name="make-qualified-heading"
                match=" application | change | handNote | keywords | metSym
                      | notesStmt[count(*) gt 1]/note | notesStmt[count(*) gt 1]/witDetail 
                      | prefixDef | relatedItem | taxonomy" 
                mode="teiheader">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="hide-all" select="false()" as="xs:boolean"/>
    <xsl:variable name="gi" select="local-name()"/>
    <xsl:variable name="position" 
      select="count(preceding-sibling::*[local-name() eq $gi]) +  1"/>
    <xsl:variable name="identifier" 
      select="if ( @xml:id ) then data(@xml:id) else concat(local-name(),$position)"/>
    <xsl:call-template name="make-teiheading-with-attributes"/>
    <div id="{$identifier}">
      <xsl:attribute name="class">
        <xsl:text>expandable</xsl:text>
        <xsl:if test="$hide-all or $position gt 3">
          <xsl:text> expandable-hidden</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="text()[normalize-space() ne '']">
          <p>
            <xsl:apply-templates mode="#current">
              <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
            </xsl:apply-templates>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="depth" tunnel="yes" select="$depth + 1"/>
            <xsl:with-param name="text-allowed" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match=" geoDecl | metDecl | schemaRef | schemaSpec | styleDefDecl 
                      | tagsDecl | rendition | namespace | tagUsage | variantEncoding" 
                mode="teiheader">
    <xsl:call-template name="make-qualified-heading">
      <xsl:with-param name="hide-all" select="true()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="date[not(text()) and not(*)]" mode="teiheader" priority="10">
    <xsl:apply-templates select="@*" mode="teiheader"/>
  </xsl:template>
  
  <xsl:template match="@when" mode="teiheader">
    <span class="block">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>
  
  <xsl:template match="@from | @to | @notBefore | @notAfter" mode="teiheader">
    <span class="block">
      <xsl:call-template name="describe-attribute"/>
    </span>
  </xsl:template>
  
  
<!-- MODE: POSTPROCESSING -->
  
  <xd:doc>
    <xd:desc>In "postprocessing" mode, most elements are simply copied through as-is.</xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="postprocessing" priority="-10">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>If an &lt;html:span&gt; contains &lt;html:p&gt;s or &lt;html:div&gt;s, turn 
      it into an &lt;html:div&gt;, thus avoiding validity errors.</xd:desc>
  </xd:doc>
  <xsl:template match="html:span[@data-tapas-gi]
                                [descendant::html:p or descendant::html:div]" 
                mode="postprocessing">
    <div>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a legend for the colors which will always be assigned to certain TEI 
      elements, no matter the color scheme.</xd:desc>
    <xd:param name="boxed-elements">A sequence of @data-tapas-gi attributes which occur 
      on boxable HTML elements.</xd:param>
    <xd:param name="distinct-classes">A sequence of distinct classnames (strings) which 
      occur on the HTML elements represented by the parents of $boxed-elements.</xd:param>
  </xd:doc>
  <xsl:template match="html:div[@id eq 'legend-constants']" mode="postprocessing">
    <xsl:param name="boxed-elements" as="attribute()*" tunnel="yes"/>
    <xsl:param name="distinct-classes" as="xs:string+" tunnel="yes"/>
    <xsl:variable name="relevantClasses"
      select="$distinct-classes [matches(.,'^box-')]
                                [not(contains(., 'box-gen'))]"/>
    <xsl:variable name="rows" as="node()*">
      <xsl:for-each select="$relevantClasses">
        <xsl:variable name="thisClass" select="."/>
        <xsl:call-template name="create-legend-row">
          <xsl:with-param name="icon">
            <svg xmlns="http://www.w3.org/2000/svg" 
              width="{ $legend-icon-width + 2 }" height="{ $legend-icon-width + 2 }">
              <rect width="{$legend-icon-width}" height="{$legend-icon-width}" 
                transform="translate(1 1)" class="legend-key {$thisClass}">
              </rect>
            </svg>
          </xsl:with-param>
          <xsl:with-param name="desc">
            <xsl:variable name="classMatches"
              select="$boxed-elements/parent::*[tps:matches-classnames(.,$thisClass)]"/>
            <xsl:call-template name="set-legend-desc-by-identity">
              <xsl:with-param name="matched-elements" select="$classMatches"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="create-legend">
      <xsl:with-param name="rows" select="$rows"/>
    </xsl:call-template>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a legend for the 'depth-wise hierarchy' color scheme.</xd:desc>
    <xd:param name="boxed-elements">A sequence of @data-tapas-gi attributes which occur 
      on boxable HTML elements.</xd:param>
    <xd:param name="distinct-classes">A sequence of distinct classnames (strings) which 
      occur on the HTML elements represented by the parents of $boxed-elements.</xd:param>
  </xd:doc>
  <xsl:template match="html:div[@id eq 'legend-depthwise']" mode="postprocessing">
    <xsl:param name="boxed-elements" as="attribute()*" tunnel="yes"/>
    <xsl:param name="distinct-classes" as="xs:string+" tunnel="yes"/>
    <!-- The depth-wise classes are those which start with 'box-gen'. -->
    <xsl:variable name="relevantClasses" as="xs:string*">
      <xsl:variable name="criteriaMatches"
        select="$distinct-classes [matches(.,'^box-gen')]"/>
      <!-- The 'box-gen0' class should just about always occur at depth 10+ (unless a 
        generically-boxable element was placed as a sibling of <body>), and so that class 
        should be sorted last. -->
      <xsl:for-each select="$criteriaMatches">
        <xsl:sort data-type="number"
          select="if ( . eq 'box-gen0' ) then 99
                  else xs:integer(substring-after(.,'box-gen'))" 
          order="ascending"/>
        <xsl:copy/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="rows" as="node()*">
      <xsl:for-each select="$relevantClasses">
        <xsl:variable name="thisClass" select="."/>
        <xsl:call-template name="create-legend-row">
          <xsl:with-param name="icon">
            <svg xmlns="http://www.w3.org/2000/svg" 
              width="{ $legend-icon-width + 2 }" height="{ $legend-icon-width + 2 }">
              <rect width="{$legend-icon-width}" height="{$legend-icon-width}" 
                transform="translate(1 1)" class="legend-key {$thisClass}">
              </rect>
            </svg>
          </xsl:with-param>
          <xsl:with-param name="desc">
            <xsl:call-template name="set-legend-desc-depthwise">
              <xsl:with-param name="boxed-elements" select="$boxed-elements"/>
              <xsl:with-param name="current-types" select="$thisClass"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="create-legend">
      <xsl:with-param name="rows" select="$rows"/>
    </xsl:call-template>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a legend for the colors associated with certain families of TEI 
      elements.</xd:desc>
    <xd:param name="boxed-elements">A sequence of @data-tapas-gi attributes which occur 
      on boxable HTML elements.</xd:param>
    <xd:param name="distinct-classes">A sequence of distinct classnames (strings) which 
      occur on the HTML elements represented by the parents of $boxed-elements.</xd:param>
  </xd:doc>
  <xsl:template match="html:div[@id eq 'legend-familial']" mode="postprocessing">
    <xsl:param name="boxed-elements" as="attribute()*" tunnel="yes"/>
    <xsl:param name="distinct-classes" as="xs:string+" tunnel="yes"/>
    <xsl:variable name="all-familial"
      select="//html:div[@id eq 'tei-container']
              //html:*[@data-tapas-gi][@class[contains(.,'familial-candidate')]]"/>
    <xsl:variable name="distinctFamilies" as="xs:string*">
      <xsl:variable name="classes" select="$all-familial/@class/tokenize(data(.),'\s+')"/>
      <xsl:copy-of select="distinct-values($classes)"/>
    </xsl:variable>
    <xsl:variable name="relevantClasses"
      select="$distinctFamilies[matches(.,'^family-')]" as="xs:string*"/>
    <xsl:variable name="rows" as="node()*">
      <!-- First, make rows for the familial candidates themselves. -->
      <xsl:for-each select="$relevantClasses">
        <xsl:sort select="."/>
        <xsl:variable name="thisClass" select="."/>
        <xsl:call-template name="create-legend-row">
          <xsl:with-param name="icon">
            <svg xmlns="http://www.w3.org/2000/svg" 
              width="{ $legend-icon-width + 2 }" height="{ $legend-icon-width + 2 }">
              <rect width="{$legend-icon-width div 2}" height="{$legend-icon-width}" 
                transform="translate(1 1)" 
                class="legend-key familial-candidate {$thisClass} familial-candidate-dark">
              </rect>
              <rect width="{$legend-icon-width div 2}" height="{$legend-icon-width}" 
                transform="translate({($legend-icon-width div 2) + 1} 1)" 
                class="legend-key familial-candidate {$thisClass} familial-candidate-light">
              </rect>
            </svg>
          </xsl:with-param>
          <xsl:with-param name="desc">
            <xsl:variable name="classMatches"
              select="$all-familial[tps:matches-classnames(.,$thisClass)]"/>
            <xsl:if test="$thisClass = $css-class-map/@name">
              <xsl:copy-of select="$css-class-map[@name eq $thisClass]/node()"/>
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:call-template name="set-legend-desc-by-identity">
              <xsl:with-param name="matched-elements" select="$classMatches"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
      <!-- Then, create a row for the three variants of familial "box-gen"s. -->
      <xsl:for-each-group select="$distinct-classes[matches(.,'^box-gen')]" 
        group-by="xs:integer(substring-after(., 'box-gen')) mod 3">
        <xsl:call-template name="create-legend-row">
          <xsl:with-param name="icon">
            <svg xmlns="http://www.w3.org/2000/svg" 
              width="{ $legend-icon-width + 2 }" height="{ $legend-icon-width + 2 }">
              <xsl:variable name="useDepth" 
                select="if ( current-grouping-key() eq 0 ) then 3
                        else current-grouping-key()"/>
              <xsl:for-each select="1 to $useDepth">
                <xsl:variable name="thisClass" select="concat('box-gen',.)"/>
                <rect width="{$legend-icon-width}" height="{$legend-icon-width}"
                  transform="translate(1 1)"
                  class="legend-key boxed-gen {$thisClass}">
                </rect>
              </xsl:for-each>
            </svg>
          </xsl:with-param>
          <xsl:with-param name="desc">
            <xsl:call-template name="set-legend-desc-depthwise">
              <xsl:with-param name="boxed-elements" select="$boxed-elements"/>
              <xsl:with-param name="current-types" select="current-group()"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:call-template name="create-legend">
      <xsl:with-param name="rows" select="$rows"/>
    </xsl:call-template>
  </xsl:template>
  
  
<!-- SUPPLEMENTAL TEMPLATES -->
  
  <xd:doc>
    <xd:desc>Build out the control box and its widgets.</xd:desc>
  </xd:doc>
  <xsl:template name="control-box">
    <div id="control-panel" lang="en">
      <h2 class="expandable-heading">Controls</h2>
      <div id="controls-container" class="expandable">
        <!-- Legend and color view selector -->
        <div class="control-widget">
          <h3 class="expandable-heading">Legend</h3>
          <div id="color-scheme" class="expandable">
            <div id="color-scheme-selector-container" class="control-widget-component">
              <fieldset id="color-scheme-selector" disabled="disabled">
                <legend>Color scheme</legend>
                <xsl:call-template name="make-radio-button">
                  <xsl:with-param name="fieldset-name" select="'color-scheme'"/>
                  <xsl:with-param name="value" select="'depthwise'"/>
                  <xsl:with-param name="label" select="'Depth-wise hierarchy'"/>
                  <xsl:with-param name="is-checked" select="true()"/>
                </xsl:call-template>
                <xsl:call-template name="make-radio-button">
                  <xsl:with-param name="fieldset-name" select="'color-scheme'"/>
                  <xsl:with-param name="value" select="'familial'"/>
                  <xsl:with-param name="label" select="'Familial elements'"/>
                  <xsl:with-param name="is-checked" select="false()"/>
                </xsl:call-template>
              </fieldset>
            </div>
            <div id="color-scheme-legend" class="control-widget-component">
              <div id="legend-depthwise"></div>
              <div id="legend-familial"></div>
              <div id="legend-constants"></div>
            </div>
          </div>
        </div>
        <!-- Clicked element properties -->
        <div class="control-widget">
          <h3 class="expandable-heading">Selected element</h3>
          <dl id="gi-properties" class="control-widget-component expandable"></dl>
        </div>
        <!-- Elements by frequency -->
        <div class="control-widget">
          <h3 class="expandable-heading">Elements by frequency</h3>
          <div id="gi-frequencies" class="control-widget-component expandable">
            <fieldset id="gi-option-selector" disabled="disabled">
              <legend>Mark</legend>
              <xsl:call-template name="gi-counting-robot">
                <xsl:with-param name="start" select="text"/>
              </xsl:call-template>
            </fieldset>
          </div>
        </div>
        <!-- Zoom -->
        <div class="control-widget">
          <h3 class="expandable-heading">Zoom</h3>
          <div id="zoom-container" class="control-widget-component expandable expandable-hidden">
            <div class="slidebar">
              <span class="slidebar-label">-</span>
              <input id="zoom-slide" title="Zoom control slider"
                type="range" min="20" max="100" step="1" value="100" 
                disabled="disabled"/>
              <span class="slidebar-label">+</span>
            </div>
          </div>
        </div>
        <!-- Text contrast -->
        <div class="control-widget">
          <h3 class="expandable-heading">Text contrast</h3>
          <div id="text-contrasts" class="control-widget-component expandable expandable-hidden">
            <xsl:variable name="tab-index" select="2"/>
            <fieldset id="text-contrast-selector" disabled="disabled">
              <legend>Visibility</legend>
              <xsl:for-each select="( 'high', 'mid', 'low', 'none' )">
                <xsl:variable name="value" select="."/>
                <xsl:call-template name="make-radio-button">
                  <xsl:with-param name="fieldset-name" select="'contrast-type'"/>
                  <xsl:with-param name="value" select="$value"/>
                  <xsl:with-param name="is-checked" 
                    select="if ( $contrast-default eq $value ) then true() else false()"/>
                  <xsl:with-param name="tab-index" 
                    select="if ( $contrast-default eq $value ) then $tab-index else 9999"/>
                  <xsl:with-param name="label"
                    select="if ( $value eq 'none' ) then 'none (invisible text)' else $value"/>
                </xsl:call-template>
              </xsl:for-each>
            </fieldset>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>For a given element, determine the number of preceding elements of the same 
      type that exist within &lt;text&gt;.</xd:desc>
    <xd:param name="element">The element on which to perform this template. The default 
      is the current node.</xd:param>
  </xd:doc>
  <xsl:template name="count-preceding-of-type">
    <xsl:param name="element" select="." as="element()"/>
    <xsl:variable name="gi" select="$element/local-name(.)"/>
    <xsl:call-template name="glossable-gi">
      <xsl:with-param name="start" select="$element"/>
    </xsl:call-template>
    <xsl:text> #</xsl:text>
    <xsl:value-of select="count(preceding::*[local-name(.) eq $gi][ancestor::text]) + 1"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a wrapper for a tabular legend.</xd:desc>
    <xd:param name="rows">The &lt;html:tr&gt;s which should populate the legend.</xd:param>
  </xd:doc>
  <xsl:template name="create-legend">
    <xsl:param name="rows" as="node()*"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <table>
        <tbody>
          <xsl:copy-of select="$rows"/>
        </tbody>
      </table>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create an HTML table row for use in a legend.</xd:desc>
    <xd:param name="desc">The description of the phenomenon keyed to this row.</xd:param>
    <xd:param name="icon">A representation of the phenomenon keyed to this row.</xd:param>
  </xd:doc>
  <xsl:template name="create-legend-row">
    <xsl:param name="icon" as="node()"/>
    <xsl:param name="desc" as="node()*"/>
    <tr class="legend">
      <td>
        <xsl:copy-of select="$icon"/>
      </td>
      <td class="legend-desc">
        <xsl:copy-of select="$desc"/>
      </td>
    </tr>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Apply templates on attributes.</xd:desc>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
  </xd:doc>
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
  
  <xd:doc>
    <xd:desc>Count number of each type of element within a given element (the default is 
      the current node).</xd:desc>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
  </xd:doc>
  <xsl:template name="gi-counting-robot">
    <xsl:param name="start" select="." as="node()+"/>
    <xsl:variable name="fieldset-name" select="'element'"/>
    <xsl:variable name="allElements" 
      select="$start/(descendant-or-self::tei:* | descendant-or-self::eg:egXML)/local-name(.)"/>
    <xsl:variable name="distinctGIs" select="distinct-values($allElements)"/>
    <xsl:call-template name="make-radio-button">
      <xsl:with-param name="fieldset-name" select="$fieldset-name"/>
      <xsl:with-param name="value" select="'none'"/>
      <xsl:with-param name="label">defaults only</xsl:with-param>
      <xsl:with-param name="is-checked" select="true()"/>
    </xsl:call-template>
    <xsl:variable name="options" as="item()*">
      <xsl:for-each select="$distinctGIs">
        <xsl:variable name="gi" select="."/>
        <xsl:variable name="count" select="count($allElements[. eq $gi])"/>
        <xsl:call-template name="make-radio-button">
          <xsl:with-param name="fieldset-name" select="$fieldset-name"/>
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
  
  <xd:doc>
    <xd:desc>Output the name of a given element, with enough context to allow TEI 
      element names to be glossed via Javascript.</xd:desc>
    <xd:param name="is-heading">An optional toggle on when a glossable element name is 
      being used as a heading. Nothing is currently done with this information.</xd:param>
    <xd:param name="language">The language code passed on from an ancestor node.</xd:param>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
  </xd:doc>
  <xsl:template name="glossable-gi">
    <xsl:param name="is-heading" select="false()" as="xs:boolean"/>
    <xsl:param name="language" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:param name="start" select="." as="node()"/>
    <code>
      <xsl:choose>
        <xsl:when test="$start[self::tei:*]">
          <xsl:variable name="gi" select="$start/local-name()"/>
          <xsl:attribute name="class" select="'glossable'"/>
          <xsl:attribute name="data-tapas-glossable-gi" select="$gi"/>
          <xsl:attribute name="data-tapas-glossable-langdefault" select="$language"/>
          <xsl:value-of select="$gi"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$start/name()"/>
        </xsl:otherwise>
      </xsl:choose>
    </code>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Set data attributes, using the convenience template 'set-data-attributes'. 
      Then apply templates on child nodes.</xd:desc>
  </xd:doc>
  <xsl:template name="keep-calm-and-carry-on">
    <xsl:call-template name="set-data-attributes"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a representation of a phrase-level element that should be categorized as a 
      member of a tag family.</xd:desc>
    <xd:param name="contents">The node(s) which should be used as the content of the section.</xd:param>
    <xd:param name="family-class">The main part of the familial class name.</xd:param>
    <xd:param name="familial-depth">A number representing the depth of the element from 
      another in its family.</xd:param>
  </xd:doc>
  <xsl:template name="make-familial-candidate">
    <xsl:param name="contents" as="node()*"/>
    <xsl:param name="family-class" as="xs:string" required="yes"/>
    <xsl:param name="familial-depth" select="1" as="xs:integer" tunnel="yes"/>
    <span>
      <xsl:call-template name="set-classes-by-family">
        <xsl:with-param name="family-class" select="$family-class"/>
        <xsl:with-param name="family-depth" select="$familial-depth"/>
      </xsl:call-template>
      <xsl:call-template name="set-data-attributes"/>
      <xsl:choose>
        <xsl:when test="$contents">
          <xsl:copy-of select="$contents"/>
        </xsl:when>
        <xsl:when test="tps:is-empty(.)">
          <xsl:call-template name="gloss-empty">
            <xsl:with-param name="has-wrapper" select="true()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current">
            <xsl:with-param name="familial-depth" select="$familial-depth + 1" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a labelled radio button for the control box.</xd:desc>
    <xd:param name="fieldset-name">The name used for the fieldset and the radio button.</xd:param>
    <xd:param name="value">The string value of this radio button.</xd:param>
    <xd:param name="label">An optional label to use for this radio button. If left 
      unspecified, the value parameter is used to populate the label too.</xd:param>
    <xd:param name="is-checked">An optional toggle to have this radio button pre-selected. 
      The default is to keep the button unselected.</xd:param>
    <xd:param name="tab-index">An optional integer to use as a tab-index, used in a 
      browser to determine the order in which HTML components are tabbed-to.</xd:param>
  </xd:doc>
  <xsl:template name="make-radio-button">
    <xsl:param name="fieldset-name" as="xs:string" required="yes"/>
    <xsl:param name="value" as="xs:string" required="yes"/>
    <xsl:param name="label" select="$value"/>
    <xsl:param name="is-checked" select="false()" as="xs:boolean"/>
    <xsl:param name="tab-index" select="9999" as="xs:integer"/>
    <label>
      <input type="radio" name="{$fieldset-name}" value="{$value}">
        <xsl:if test="$is-checked">
          <xsl:attribute name="checked" select="'checked'"/>
        </xsl:if>
        <xsl:if test="$tab-index ne 9999">
          <xsl:attribute name="tab-index" select="$tab-index"/>
        </xsl:if>
      </input>
      <span class="label-desc">
        <xsl:copy-of select="$label"/>
      </span>
    </label>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create an expandable section from part of the &lt;teiHeader&gt;, using depth-wise 
      color-coding.</xd:desc>
    <xd:param name="contents">The node(s) which should be used as the content of the section.</xd:param>
    <xd:param name="depth">A number representing the depth of the element from &lt;teiHeader&gt;</xd:param>
    <xd:param name="is-hidden">An optional toggle to have the section automatically expanded. 
      By default, sections are collapsed by Javascript.</xd:param>
  </xd:doc>
  <xsl:template name="make-teiheader-section">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="contents" as="node()*">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="depth" tunnel="yes" 
          select="if ( $depth eq -1 ) then 1 else $depth + 1"/>
      </xsl:apply-templates>
    </xsl:param>
    <xsl:param name="is-hidden" select="true()" as="xs:boolean"/>
    <xsl:variable name="identifier">
      <xsl:value-of select="lower-case(local-name())"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="generate-id()"/>
    </xsl:variable>
    <xsl:call-template name="make-teiheading"/>
    <div id="{$identifier}" 
      class="expandable{ if ( $is-hidden ) then ' expandable-hidden' else '' }">
      <xsl:copy-of select="$contents"/>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a heading to be used for sections within the &lt;teiHeader&gt;.</xd:desc>
    <xd:param name="depth">A number representing the depth of the element from &lt;teiHeader&gt;</xd:param>
    <xd:param name="heading">The node(s) which should be used as the content of the heading. 
      If this parameter isn't provided, the heading text will consist of the glossed element 
      name.</xd:param>
  </xd:doc>
  <xsl:template name="make-teiheading">
    <xsl:param name="depth" select="1" as="xs:integer" tunnel="yes"/>
    <xsl:param name="heading" as="node()*">
      <xsl:call-template name="glossable-gi">
        <xsl:with-param name="is-heading" select="true()"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:variable name="headerN">
      <xsl:variable name="depthwise" select="$depth + 3"/>
      <xsl:value-of 
        select=" if ( $depth eq -1 ) then 3 
            else if ( $depthwise le 6 ) then $depthwise 
            else 6"/>
    </xsl:variable>
    <xsl:variable name="boxClass" 
      select="if ( $depth eq -1 ) then 'box-outer' 
              else concat('box-gen', $depth mod 9) "/>
    <xsl:element name="h{$headerN}">
      <xsl:attribute name="class">
        <xsl:text>expandable-heading </xsl:text>
        <xsl:value-of select="$boxClass"/>
      </xsl:attribute>
      <xsl:copy-of select="$heading"/>
    </xsl:element>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>A convenience template for creating a heading with not just the name of the 
      element, but the attributes on it.</xd:desc>
    <xd:param name="heading">The node(s) which should be used as the content of the heading, 
      to which attributes will be appended. If this parameter isn't provided, the heading text 
      will consist of the glossed element name.</xd:param>
  </xd:doc>
  <xsl:template name="make-teiheading-with-attributes">
    <xsl:param name="heading" as="node()*">
      <xsl:call-template name="glossable-gi">
        <xsl:with-param name="is-heading" select="true()"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:call-template name="make-teiheading">
      <xsl:with-param name="heading">
        <xsl:copy-of select="$heading"/>
        <xsl:text> </xsl:text>
        <span class="heading-attr">
          <xsl:apply-templates select="@*" mode="show-att">
            <xsl:with-param name="suppress-links" select="true()"/>
          </xsl:apply-templates>
        </span>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a data attribute to store the name of the current TEI element.</xd:desc>
    <xd:param name="start">The node on which to perform this template. The default is the 
      current node.</xd:param>
  </xd:doc>
  <xsl:template name="save-gi">
    <xsl:param name="start" select="." as="node()"/>
    <xsl:attribute name="data-tapas-gi" select="local-name($start)"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Set all of the usual attributes for depth-wise boxes.</xd:desc>
    <xd:param name="depth">A number representing the depth of the element from 
      &lt;text&gt; or &lt;floatingText&gt;</xd:param>
  </xd:doc>
  <xsl:template name="set-box-attributes-by-depth">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:call-template name="set-box-classes-depthwise">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:call-template>
    <xsl:call-template name="set-data-attributes"/>
    <xsl:attribute name="data-tapas-box-depth" select="$depth"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Set a color class for a boxed element, based on its depth in the hierarchy.</xd:desc>
    <xd:param name="depth">A number representing the depth of the element from 
      &lt;text&gt; or &lt;floatingText&gt;</xd:param>
  </xd:doc>
  <xsl:template name="set-box-classes-depthwise">
    <xsl:param name="depth" as="xs:integer" required="yes"/>
    <xsl:variable name="colorNum" select="($depth - 1) mod 9"/>
    <xsl:attribute name="class">
      <xsl:text>boxed boxed-gen box-gen</xsl:text><xsl:value-of select="$colorNum"/>
    </xsl:attribute>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Set color classes for an element family member, using minimal depth cues.</xd:desc>
    <xd:param name="additional-classes">An optional string representing other, 
      whitespace-delimited HTML classes to be assigned to the output element. These will be 
      applied before the family class.</xd:param>
    <xd:param name="family-class">The main part of the familial class name.</xd:param>
    <xd:param name="family-depth">A number representing the depth of the element from another 
      in its family.</xd:param>
  </xd:doc>
  <xsl:template name="set-classes-by-family">
    <xsl:param name="additional-classes" select="''" as="xs:string" tunnel="yes"/>
    <xsl:param name="family-class" as="xs:string"/>
    <xsl:param name="family-depth" as="xs:integer"/>
    <xsl:variable name="version" select="$family-depth mod 2"/>
    <xsl:attribute name="class">
      <xsl:if test="normalize-space($additional-classes) ne ''">
        <xsl:value-of select="$additional-classes"/><xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>familial-candidate </xsl:text>
      <xsl:value-of select="$family-class"/>
      <xsl:text> familial-candidate-</xsl:text>
      <xsl:value-of select="if ( $version eq 1 ) then 'dark' else 'light'"/>
    </xsl:attribute>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Set data attributes, saving the TEI element's name and attribute values. 
      This is a convenience template for 'save-gi' followed by 'get-attributes'.</xd:desc>
  </xd:doc>
  <xsl:template name="set-data-attributes">
    <xsl:call-template name="save-gi"/>
    <xsl:call-template name="get-attributes"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create a list of element names for use in a legend description.</xd:desc>
    <xd:param name="matched-elements">A sequence of elements matched to the current 
      legend entry.</xd:param>
  </xd:doc>
  <xsl:template name="set-legend-desc-by-identity">
    <xsl:param name="matched-elements" as="node()*"/>
    <xsl:variable name="distinctGIs"
      select="distinct-values($matched-elements/@data-tapas-gi)"/>
    <xsl:variable name="numDistinct" select="count($distinctGIs)"/>
    <xsl:if test="$numDistinct gt 0">
      <xsl:choose>
        <!-- If there is more than one element for this description, create a list. -->
        <xsl:when test="$numDistinct gt 1">
          <ul>
            <xsl:variable name="sortedGIs" as="xs:string+">
              <xsl:for-each select="$distinctGIs">
                <xsl:sort select="."/>
                <xsl:value-of select="."/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="$sortedGIs">
              <xsl:variable name="gi" select="."/>
              <xsl:variable name="index" select="index-of($sortedGIs, $gi)"/>
              <li>
                <span class="encoded encoded-gi">
                  <xsl:value-of select="$gi"/>
                </span>
                <xsl:if test="$index ne $numDistinct">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <!-- If there is only one kind of element matched, don't bother to wrap that gi 
          in an HTML list. -->
        <xsl:otherwise>
          <span class="encoded encoded-gi">
            <xsl:value-of select="$distinctGIs"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Add an explanation of a depth-based color class to a legend key.</xd:desc>
    <xd:param name="boxed-elements">A sequence of '@data-tapas-gi's from HTML boxed 
      elements.</xd:param>
    <xd:param name="current-types">The CSS class(es) which should be matched for this depth.</xd:param>
  </xd:doc>
  <xsl:template name="set-legend-desc-depthwise">
    <xsl:param name="boxed-elements" as="attribute()+" required="yes"/>
    <xsl:param name="current-types" as="xs:string+" required="yes"/>
    <xsl:variable name="matches" select="$boxed-elements/parent::html:*
                                          [tps:matches-classnames(.,$current-types)]"/>
    <xsl:variable name="sortedDepths" as="xs:string*">
      <xsl:variable name="depths" 
        select="distinct-values($matches/@data-tapas-box-depth/data(.))" as="xs:integer*"/>
      <xsl:for-each select="$depths">
        <xsl:sort select="." order="ascending"/>
        <xsl:copy-of select="xs:string(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>container at depth</xsl:text>
    <xsl:value-of select="if ( count($sortedDepths) gt 1 ) then 's' else ''"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="string-join($sortedDepths,', ')"/>
    <!--<small> from closest ancestor <span class="encoded encoded-gi">text</span> or 
      <span class="encoded encoded-gi">floatingText</span></small>-->
  </xsl:template>
  
</xsl:stylesheet>
