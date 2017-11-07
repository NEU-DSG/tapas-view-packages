<?xml version="1.0" encoding="UTF-8"?>
<!-- XProc pipeline to validate with Schematron and return the SVRL report -->
<p:declare-step version="1.0" name="main" type="tapas:schematron-report"
  xmlns:p="http://www.w3.org/ns/xproc" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tapas="http://www.wheatoncollege.edu/TAPAS/1.0">
  <!-- Note: the svrl namespace is what we output. It is not actually used here -->
  <!-- in this pipeline, so does not have to be declared, above. I've done so   -->
  <!-- just to remind us of the output. -->
  <p:input port="source" primary="true" sequence="false"/> <!-- input XML -->
  <p:input port="schema" sequence="false"/> <!-- input Schematron schema -->
  <p:output port="result" sequence="false">
    <p:pipe step="get-svrl-report" port="result"/>
  </p:output>

  <p:validate-with-schematron name="v-sch" assert-valid="false">
    <p:input port="source">
      <p:pipe step="main" port="source"/>
    </p:input>
    <p:input port="schema">
      <p:pipe step="main" port="schema"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:with-option name="phase" select="'#ALL'"/>
  </p:validate-with-schematron>

  <!-- take primary "result" output from v-sch, and throw it out -->
  <p:sink>
    <p:input port="source">
      <p:pipe port="result" step="v-sch"/>
    </p:input>
  </p:sink>
  
  <!-- take secondary "report" output from v-sch, and copy to output -->
  <p:identity name="get-svrl-report">
    <p:input port="source">
      <p:pipe port="report" step="v-sch"/>
    </p:input>
  </p:identity>
  
</p:declare-step>
