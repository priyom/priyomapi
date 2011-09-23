<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" xmlns:tagsLib="urn:tagsLib" xmlns:BlogLibrary="urn:BlogLibrary"
  xmlns:myfunctionlib="urn:myfunctionlib"
  exclude-result-prefixes="msxml  umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes  Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings  Exslt.ExsltSets tagsLib BlogLibrary ">


<xsl:output method="xml" omit-xml-declaration="yes"/>
<xsl:param name="currentPage"/>
<msxml:script implements-prefix="myfunctionlib" language="C#">
<msxml:assembly name="PriyomAPI1"/>
<msxml:assembly name="PriyomAPI"/>
<msxml:assembly name="Microsoft.Practices.EnterpriseLibrary.Caching"/>
<msxml:assembly name="System.Web"/>
<msxml:using namespace="PriyomAPI"/>
<msxml:using namespace="Microsoft.Practices.EnterpriseLibrary.Caching"/>
<msxml:using namespace="System.Web"/>
<![CDATA[
public XmlDocument GetTheDoc(int input)
{
            GetXmlDoc._manager1 = PriyomAPI.Global.manager1;
            return GetXmlDoc.Getme("call/getTransmissionsByYear?stationId=1&year="+input);

}
]]>
</msxml:script>

<xsl:variable name="Year" select="/macro/Year"/>
<xsl:variable name="temp" select="myfunctionlib:GetTheDoc($Year)" />
<xsl:template match="/">
<table>
  <xsl:apply-templates select="$temp//priyom-transmission-export" />
</table>
</xsl:template>
<xsl:template match="/priyom-transmission-export">
<th>
  Date
</th>
<th>
  Hour (UTC)
</th>
<th>
  Callsign(s)
</th>
<th>
  Key Group
</th>
<th>
  Latin transcript
</th>
<th>
  Cyrillic transcript
</th>
<th>
  Comments
</th>
<xsl:for-each select="transmission">
  <tr>
    <xsl:call-template name="process-transmission"/>
  </tr>
</xsl:for-each>
</xsl:template>
    
<xsl:template name="process-transmission">
  <xsl:variable name="link" select="Recording"/>
  <td>      
    <xsl:copy-of select="umbraco.library:FormatDateTime(Timestamp/text(),'MMMM dd, yyyy')"/>  
  </td>
  <td>
     <xsl:copy-of select="umbraco.library:FormatDateTime(Timestamp/text(),'hh:mm')"/>  
  </td>
    <td>      
    <xsl:copy-of select="Callsign [@lang=not(string(.))]/text()"/>/<xsl:copy-of select="Callsign [@lang='ru']/text()"/>  
  </td>
  <td>
  <p>
    <xsl:for-each select="Contents/group[@class='id'][@name='s28-leading']/item">
      <xsl:copy-of select="concat(text(),' ')" />
    </xsl:for-each>
  </p>
  </td>
  <td>
    <p>
      <xsl:if test="$link != not(node())">
        <a href="{$link}">
           <xsl:for-each select="Contents/group[@class='data'][@name='s28-blocks']">
             <p>
               <xsl:for-each select="item[@lang=not(string(.))][@class='codeword']">  
                 <xsl:copy-of select="concat(text(),' ')" />
                </xsl:for-each>
                <xsl:for-each select="item[@class='number']">
                 <xsl:copy-of select="concat(text(),' ')" />
                </xsl:for-each>
             </p>
          </xsl:for-each>
        </a>  
      </xsl:if>
      <xsl:if test="$link = not(node())">
           <xsl:for-each select="Contents/group[@class='data'][@name='s28-blocks']">
              <p>
                <xsl:for-each select="item[@lang=not(string(.))][@class='codeword']">  
                  <xsl:copy-of select="concat(text(),' ')" />
                 </xsl:for-each>
                 <xsl:for-each select="item[@class='number']">
                  <xsl:copy-of select="concat(text(),' ')" />
                 </xsl:for-each>
              </p>
           </xsl:for-each>
      </xsl:if>
    </p>
    <xsl:if test="$link != not(node())">
    <p>
      <audio src="{$link}" controls="controls" preload="none"></audio>
    </p>
    </xsl:if>
  </td>
  <td>
   <xsl:for-each select="Contents/group[@class='data'][@name='s28-blocks']">
     <xsl:copy-of select="concat(item[@lang='ru'][@class='codeword']/text(),' ')" />
   </xsl:for-each>   
  </td>
  <td>
    <xsl:copy-of select="Remarks/text()"/>  
  </td>
</xsl:template>

</xsl:stylesheet>