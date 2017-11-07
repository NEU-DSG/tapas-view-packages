<?xml version="1.0" encoding="UTF-8"?>
<!-- XProc pipeline to validate with both RELAX NG and Schematron, and return error messages -->
<p:declare-step version="1.0" name="main" type="tapas:validity-report"
   xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
   xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0">
   <p:input port="source" primary="true"/>
   <p:input port="grammar"/>
   <p:input port="rules"/>
   <p:output port="result" primary="true" sequence="true">
      <p:pipe step="both" port="result"/>
   </p:output>
   <p:option name="dtd-attribute-values" select="'false'"/>
   <p:option name="dtd-id-idref-warnings" select="'false'"/>
   <p:option name="assert-valid" select="'false'"/> <!-- yes, false by default! -->

  <p:group name="both">
    <p:output port="result" primary="true" sequence="true"/>
    <p:group>
      <p:try name="try">
        <p:group>
          <p:output port="result" primary="true">
            <p:pipe step="v-rng" port="result"/>
          </p:output>
          <p:validate-with-relax-ng name="v-rng" assert-valid="true">
            <p:input port="source">
              <p:pipe step="main" port="source"/>
            </p:input>
            <p:input port="schema">
              <p:pipe step="main" port="grammar"/>
            </p:input>
            <p:with-option name="dtd-attribute-values" select="$dtd-attribute-values"/>
            <p:with-option name="dtd-id-idref-warnings" select="$dtd-id-idref-warnings"/>
          </p:validate-with-relax-ng>
        </p:group>
        <p:catch name="catch">
          <p:output port="result" primary="true">
            <p:pipe step="copy-rng-errors" port="result"/>
          </p:output>
          <p:identity name="copy-rng-errors">
            <p:input port="source">
              <p:pipe step="catch" port="error"/>
            </p:input>
          </p:identity>
        </p:catch>
      </p:try>
      <p:filter name="filter" select="node()[ancestor-or-self::c:errors]"/>
    </p:group>
    <p:try>
      <p:group>
        <p:output port="result">
          <p:pipe port="result" step="v-sch"/>
        </p:output>
        <p:validate-with-schematron name="v-sch">
          <p:input port="parameters">
            <p:empty/>
          </p:input>
          <p:input port="source">
            <p:pipe step="main" port="source"/>
          </p:input>
          <p:input port="schema">
            <p:pipe step="main" port="rules"/>
          </p:input>
          <p:with-option name="assert-valid" select="'false'"/>
        </p:validate-with-schematron>
      </p:group>
      <p:catch name="catch">
        <p:output port="result" primary="true">
          <p:pipe step="copy-sch-errors" port="result"/>
        </p:output>
        <p:identity name="copy-sch-errors">
          <p:input port="source">
            <p:pipe step="catch" port="error"/>
          </p:input>
        </p:identity>
      </p:catch>
    </p:try>
  </p:group>
<!--  <p:pack>
    <p:input port="source">
      <p:pipe port="result" step="filter"/>
    </p:input>
    <p:input port="alternate">
      <p:pipe port="result" step="v-sch"/>
    </p:input>
    <p:with-option name="wrapper" select="'c:wrapper'"/>
  </p:pack>
--></p:declare-step>
