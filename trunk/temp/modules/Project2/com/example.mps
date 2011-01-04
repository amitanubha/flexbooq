<?xml version="1.0" encoding="UTF-8"?>
<model modelUID="r:906c29f4-26b0-444f-9e3d-698ca6b1d50b(com.example)">
  <persistence version="4" />
  <refactoringHistory />
  <language namespace="2d3d83fe-bb56-4c31-a57c-6d0c98bc04ce(com.realaxy.actionScript)" />
  <language namespace="3a27ae5e-9c30-4977-a146-ffce86d2005c(com.realaxy.actionScript.logging)" />
  <languageAspect modelUID="r:01bbc137-6286-4a58-a683-2021a2f7824a(com.realaxy.actionScript.typesystem)" version="3" />
  <languageAspect modelUID="r:60f0fc0e-2e8e-4bcf-94ae-1146ef7fc044(com.realaxy.actionScript.dataFlow)" version="22" />
  <languageAspect modelUID="r:49784cba-a384-4286-b969-08d540fbc32f(com.realaxy.actionScript.structure)" version="51" />
  <languageAspect modelUID="r:34718987-8b1e-4975-b8d7-67b22c35c5c2(com.realaxy.actionScript.actions)" version="2" />
  <languageAspect modelUID="r:81f0ca78-d516-436f-b54b-8970fc616f40(com.realaxy.actionScript.editor)" version="0" />
  <languageAspect modelUID="r:9dc9c33a-5b25-436a-8f84-855f38c32f14(com.realaxy.actionScript.behavior)" version="2" />
  <languageAspect modelUID="r:00000000-0000-4000-0000-011c89590288(jetbrains.mps.lang.core.structure)" version="0" />
  <languageAspect modelUID="r:00000000-0000-4000-0000-011c89590283(jetbrains.mps.lang.core.constraints)" version="2" />
  <languageAspect modelUID="r:fbe79660-97b4-428d-b1be-fe20f98872b6(com.realaxy.actionScript.logging.structure)" version="2" />
  <language-engaged-on-generation namespace="3a27ae5e-9c30-4977-a146-ffce86d2005c(com.realaxy.actionScript.logging)" />
  <maxImportIndex value="4" />
  <import index="1" modelUID="f:swc_stub#(@swc_stub)" version="-1" />
  <import index="2" modelUID="f:swc_stub#flash.display(flash.display@swc_stub)" version="-1" />
  <import index="3" modelUID="f:swc_stub#flash.metadata(flash.metadata@swc_stub)" version="-1" />
  <import index="4" modelUID="f:swc_stub#flash.events(flash.events@swc_stub)" version="-1" />
  <node type="com.realaxy.actionScript.structure.ClassConcept:51" id="6731619548248559631">
    <property name="name:51" value="Main" />
    <node role="outOfPackageButton:51" type="com.realaxy.actionScript.structure.OutOfPackageAddButton:51" id="6731619548248559632" />
    <node role="constructor:51" type="com.realaxy.actionScript.structure.ConstructorDeclaration:51" id="6731619548248559633">
      <node role="returnType:51" type="com.realaxy.actionScript.structure.VoidType:51" id="6731619548248559634" />
      <node role="body:51" type="com.realaxy.actionScript.structure.StatementList:51" id="6731619548248559635">
        <node role="statement:51" type="com.realaxy.actionScript.logging.structure.LogStatement:2" id="3908655293890639533">
          <property name="severity:2" value="trace" />
          <node role="expression:2" type="com.realaxy.actionScript.structure.StringLiteral:51" id="3908655293890639534">
            <property name="value:51" value="hello" />
          </node>
        </node>
      </node>
    </node>
    <node role="visibility:51" type="com.realaxy.actionScript.structure.PublicVisibility:51" id="6731619548248559637" />
    <node role="implementedInterface:51" type="com.realaxy.actionScript.structure.DynamicClassifierType:51" id="6731619548248559639">
      <property name="isAllowEmpty:51" value="true" />
    </node>
    <node role="superclass:51" type="com.realaxy.actionScript.structure.ClassifierType:51" id="6731619548248559640">
      <property name="name:51" value="Sprite" />
      <link role="reference:51" targetNodeId="2.~Sprite" />
    </node>
  </node>
</model>

