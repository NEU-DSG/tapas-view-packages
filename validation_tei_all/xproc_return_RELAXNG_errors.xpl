<?xml version="1.0" encoding="UTF-8"?>
<!-- XProc pipeline to validate with RELAX NG -->
<p:declare-step version="1.0" name="main" type="l:relax-ng-report"
   xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
   xmlns:l="http://xproc.org/library">
   <p:input port="source" primary="true"/>
   <p:input port="schema"/>
   <p:output port="result" primary="true" sequence="true">
      <p:pipe step="filter" port="result"/>
   </p:output>
   <p:option name="dtd-attribute-values" select="'false'"/>
   <p:option name="dtd-id-idref-warnings" select="'false'"/>
   <p:option name="assert-valid" select="'false'"/> <!-- yes, false by default! -->

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
               <p:pipe step="main" port="schema"/>
            </p:input>
            <p:with-option name="dtd-attribute-values" select="$dtd-attribute-values"/>
            <p:with-option name="dtd-id-idref-warnings" select="$dtd-id-idref-warnings"/>
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
   <p:filter name="filter" select="node()[ancestor-or-self::c:errors]"/>
</p:declare-step>
