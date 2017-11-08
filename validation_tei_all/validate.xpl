<?xml version="1.0" encoding="UTF-8"?>
<!-- XProc pipeline to return error messages from both RELAX NG and Schematron validation -->
<p:declare-step version="1.0" name="main" type="tapas:validity-report"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0">
  <p:input port="source" primary="true"/>
  <!-- TEI input file -->
  <p:input port="grammar"/>
  <!-- TEI RELAX NG (XML syntax) grammar -->
  <p:input port="rules"/>
  <!-- TEI ISO Schematron schema [1] -->
  <p:output port="result" primary="true" sequence="true">
    <p:pipe step="post-process" port="result"/>
  </p:output>
  <p:documentation> The output is a singe XML document which (I think) should match the following
    declaration: element tapas:errors { RNG?, SCH } RNG = element c:errors { c:error+ } SCH =
    element svrl:schematron-output { [2] } That is, there will be no "c:errors" child unless there
    were errors found by RELAX NG validation; there will be a full SVRL report whether or not any
    assertions or reports generated messages. Note: If the RELAX NG validator generates error output
    based on the embedded Schematron in the RELAX NG schema, they are summarily discarded. </p:documentation>
  <p:documentation> [1] When run in oXygen, duplicate namespace declarations do not seem to be a
    problem. (They are in `probatron`, although the spec does not say they should be.) I have not
    tested in eXist, yet. [2] The SCH output is in the Schematron validation report language; see
    Annex D of ISO 19757-3:2016 </p:documentation>

  <p:group name="get-rng-errors">
    <p:output port="result">
      <p:pipe port="result" step="filter-rng"/>
    </p:output>
    <p:try name="try-rng">
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
          <p:with-option name="dtd-attribute-values" select="'false'"/>
          <p:with-option name="dtd-id-idref-warnings" select="'false'"/>
        </p:validate-with-relax-ng>
      </p:group>
      <p:catch name="catch">
        <p:output port="result" primary="true">
          <p:pipe step="copy-errors" port="result"/>
        </p:output>
        <p:identity name="copy-errors">
          <p:input port="source">
            <p:pipe step="catch" port="error"/>
          </p:input>
        </p:identity>
      </p:catch>
    </p:try>
    <p:filter name="filter-rng" select="node()[ancestor-or-self::c:errors]"/>
  </p:group>

  <p:group name="get-sch-errors">
    <p:output port="result">
      <p:pipe port="result" step="get-svrl-report"/>
    </p:output>
    <p:validate-with-schematron name="v-sch" assert-valid="false">
      <p:input port="source">
        <p:pipe step="main" port="source"/>
      </p:input>
      <p:input port="schema">
        <p:pipe step="main" port="rules"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-option name="phase" select="'#ALL'"/>
    </p:validate-with-schematron>
    <p:sink>
      <p:input port="source">
        <p:pipe port="result" step="v-sch"/>
      </p:input>
    </p:sink>
    <p:identity name="get-svrl-report">
      <p:input port="source">
        <p:pipe port="report" step="v-sch"/>
      </p:input>
    </p:identity>
  </p:group>

  <p:pack wrapper="tapas:errors" name="take-both">
    <p:input port="source">
      <p:pipe port="result" step="get-rng-errors"/>
    </p:input>
    <p:input port="alternate">
      <p:pipe port="result" step="get-sch-errors"/>
    </p:input>
  </p:pack>

  <p:xslt name="post-process">
    <p:input port="source">
      <p:pipe port="result" step="take-both"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="process_messages.xslt"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
