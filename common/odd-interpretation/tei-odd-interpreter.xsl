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
  
  <xsl:variable name="defaultLanguage" select="'en'"/>
  <xsl:variable name="teiODD" select="doc('p5subset.xml')"/>
  
  
<!-- FUNCTIONS -->
  
  <!-- Given an element name and an identifier for a transcription language, come up 
    with a human-readable descriptor of the element, in the given language if 
    possible. -->
  <xsl:function name="tps:get-element-gloss" as="xs:string?">
    <xsl:param name="element-name" as="xs:string"/>
    <xsl:param name="language" as="xs:string"/>
    <xsl:variable name="teiSpec" select="$teiODD//elementSpec[@ident/data(.) eq $element-name]"/>
    <xsl:variable name="useLang">
      <xsl:variable name="mainPart" select="if ( contains($language,'-') ) then 
                                              substring-before($language, '-')
                                            else $language"/>
      <xsl:variable name="lowercased" select="lower-case($mainPart)"/>
      <xsl:value-of 
        select=" if ( $lowercased = ('de', 'ger', 'deu') )  then 'de'
            else if ( $lowercased = ('en', 'eng') )         then 'en'
            else if ( $lowercased = ('es', 'spa') )         then 'es'
            else if ( $lowercased = ('fr', 'fre', 'fra') )  then 'fr'
            else if ( $lowercased = ('it', 'ita') )         then 'it'
            else if ( $lowercased = ('ja', 'jpn') )         then 'ja'
            else if ( $lowercased = ('ko', 'kor') )         then 'ko'
            else $lowercased"/>
    </xsl:variable>
    <xsl:if test="$teiSpec">
      <xsl:choose>
        <xsl:when test="$teiSpec/gloss[@xml:lang/lower-case(.) eq $language]">
          <xsl:value-of select="$teiSpec/gloss[@xml:lang/lower-case(.) eq $language]"/>
        </xsl:when>
        <xsl:when test="$teiSpec/gloss[@xml:lang/lower-case(.) eq $useLang]">
          <xsl:value-of select="$teiSpec/gloss[@xml:lang/lower-case(.) eq $useLang]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$element-name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:function>
  
<!-- TEMPLATES -->
  
  <!-- Gloss a given element. -->
  <xsl:template name="gloss-gi">
    <xsl:param name="isHeading" select="false()" as="xs:boolean"/>
    <xsl:param name="start" select="." as="node()"/>
    <xsl:param name="language" as="xs:string" required="yes" tunnel="yes"/>
    <xsl:variable name="gloss" select="tps:get-element-gloss(local-name($start), $language)"/>
    <xsl:value-of select="if ( $isHeading ) then
                            concat(upper-case(substring($gloss,1,1)), substring($gloss,2))
                          else $gloss"/>
  </xsl:template>
  
</xsl:stylesheet>