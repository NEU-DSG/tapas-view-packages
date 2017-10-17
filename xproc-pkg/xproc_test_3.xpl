<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0"
  name="main"
  type="tapas:relax-ng-report">
  
  <p:input port="source" primary="true"/>
  <p:input port="schema">
    <p:document href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng"/>
  </p:input>
  <p:output port="result" primary="true"/>
  <p:output port="report" sequence="true">
    <p:pipe step="try" port="report"/>
  </p:output>
  <p:option name="dtd-attribute-values" select="'false'"/>
  <p:option name="dtd-id-idref-warnings" select="'false'"/>
  <p:option name="assert-valid" select="'false'"/>
  <!-- yes, false by default! -->

  <!--<p:xinclude/>-->

  <p:try name="try">
    <p:group>
      <p:output port="result" primary="true">
        <p:pipe step="v-rng" port="result"/>
      </p:output>
      <p:output port="report">
        <p:empty/>
      </p:output>
      <p:validate-with-relax-ng name="v-rng" assert-valid="true">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="main" port="schema"/>
        </p:input>
        <p:with-option name="dtd-attribute-values" select="$dtd-attribute-values"/>
        <p:with-option name="dtd-id-idref-warnings" select="$dtd-id-idref-warnings"/>
      </p:validate-with-relax-ng>
    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true">
        <p:pipe step="copy-source" port="result"/>
      </p:output>
      <p:output port="report">
        <p:pipe step="copy-errors" port="result"/>
      </p:output>
      <p:identity name="copy-source">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>
      <p:identity name="copy-errors">
        <p:input port="source">
          <p:pipe step="catch" port="error"/>
        </p:input>
      </p:identity>
    </p:catch>
  </p:try>

  <p:choose>
    <p:when test="$assert-valid = 'true' and /c:result != '0'">
      <!-- This isn't very efficient, but it's an error case so that's
           probably ok. In any event, it assures that l:relax-ng-report
           raises the same errors that the validation raises. -->
      <p:validate-with-relax-ng name="v-rng" assert-valid="true">
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="main" port="schema"/>
        </p:input>
        <p:with-option name="dtd-attribute-values" select="$dtd-attribute-values"/>
        <p:with-option name="dtd-id-idref-warnings" select="$dtd-id-idref-warnings"/>
      </p:validate-with-relax-ng>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:pipe step="try" port="result"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

</p:declare-step>
