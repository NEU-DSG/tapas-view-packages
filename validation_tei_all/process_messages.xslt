<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xpath-default-namespace="http://www.w3.org/ns/xproc-step"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">

  <!-- Read in a document of error messages, write out readable HTML thereof -->
  
  <xsl:param name="fullHTML" select="'false'"/> <!-- set to 'true' to get browsable output for debugging -->
  <xsl:param name="css" select="'styles.css'"/>
  <xsl:variable name="root" select="/" as="node()"/>
  
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
      <title>TAPAS TEI error msgs</title>
      <meta charset="UTF-8"></meta>
      <link rel="stylesheet" type="text/css" href="{$css}"></link>
    </head>
  </xsl:template>
  
  <xsl:template name="contentDiv">
    <!-- The only 2 values TEI P5 uses for sch:*/@role are 'warning' and 'nonfatal'. -->
    <xsl:variable name="errors" select="//c:error|//svrl:text[not( ../@role ) or ../@role eq 'nonfatal']"/>
    <xsl:variable name="warnings" select="//svrl:text[../@role eq 'warning']"/>
    <div class="validation-tei_all-pkg">
      <xsl:choose>
        <xsl:when test="not( $errors ) and not( $warnings )">
          <h1>Whoo-hoo!</h1>
          <h2>No errors, no warnings</h2>
        </xsl:when>
        <xsl:when test="not( $errors ) and $warnings">
          <h1>Excellent</h1>
          <h2>No errors</h2>
          <h2>Warnings</h2>
          <xsl:apply-templates select="$warnings"/>
        </xsl:when>
        <xsl:otherwise>
          <h1>Messages</h1>
          <h2>Errors</h2>
          <xsl:apply-templates select="$errors"/>
          <xsl:if test="$warnings">
            <h2>Warnings</h2>
            <xsl:apply-templates select="$warnings"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="c:error">
    <p>
      <xsl:text>Error flagged on line </xsl:text>
      <xsl:value-of select="@line"/>
      <xsl:text> at column </xsl:text>
      <xsl:value-of select="@column"/>
      <xsl:text>:</xsl:text>
      <br/>
      <xsl:value-of select="substring-after( normalize-space(.),'org.xml.sax.SAXParseException: ')"/>
    </p>
  </xsl:template>

  <xsl:template match="svrl:*">
    <p>Schematron warning temporarily ignored here.</p>
  </xsl:template>
  
</xsl:stylesheet>