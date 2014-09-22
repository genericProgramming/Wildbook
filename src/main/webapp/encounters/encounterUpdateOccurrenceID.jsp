<%@ page contentType="text/html; charset=utf-8" language="java"
         import="org.ecocean.servlet.ServletUtilities,com.drew.imaging.jpeg.JpegMetadataReader, com.drew.metadata.Directory, com.drew.metadata.Metadata, com.drew.metadata.Tag, org.ecocean.*,org.ecocean.servlet.ServletUtilities,org.ecocean.Util,org.ecocean.Measurement, org.ecocean.Util.*, org.ecocean.genetics.*, org.ecocean.tag.*, java.awt.Dimension, javax.jdo.Extent, javax.jdo.Query, java.io.File, java.text.DecimalFormat, java.util.*, org.ecocean.security.Collaboration" %>
<%
    String context="context0";
    context=ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    // get the encouner number
    String num = request.getParameter("number").replaceAll("\\+", "").trim();
    Encounter enc = myShepherd.getEncounter(num);
    boolean isOwner = ServletUtilities.isUserAuthorizedForEncounter(enc, request);

    String langCode=ServletUtilities.getLanguageCode(request);
    Properties encprops = ShepherdProperties.getProperties("encounter.properties", langCode, context);
%>
<div id="wholeEncounterDiv">
<p class="para">
    <img width="24px" height="24px" align="absmiddle" src="../images/occurrence.png" />&nbsp;<%=encprops.getProperty("occurrenceID") %>:
    <%
    if(myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())!=null){
    %>
        <a href="../occurrence.jsp?number=<%=myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber()).getOccurrenceID() %>"><%=myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber()).getOccurrenceID() %></a>    
    <%  
    }
    else{
    %>
        <%=encprops.getProperty("none_assigned") %>
    <%
    }

    if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
    %>
        <a id="occurrence" class="launchPopup"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="../images/Crystal_Clear_action_edit.png" /></a>
    <%
    }
    %>
</p>

<%
if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
%>
                        
<div id="dialogOccurrence" title="<%=encprops.getProperty("assignOccurrence")%>" style="display:none">  

<p><em><%=encprops.getProperty("occurrenceMessage")%></em></p>
 
<!-- start Occurrence management section-->           
    <% //Remove from occurrence if assigned
    if((myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())!=null) && isOwner) {
    %>
    <table border="0" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">
    <tr>
        <td align="left" valign="top" class="para">
      <table>
        <tr>
          <td><font color="#990000"><img align="absmiddle" src="../images/cancel.gif"/></font></td>
          <td><strong><%=encprops.getProperty("removeFromOccurrence")%>
          </strong></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td align="left" valign="top">
      <form action="../OccurrenceRemoveEncounter" method="post" name="removeOccurrence" onsubmit="return false;">
        <input name="number" type="hidden" value="<%=num%>" /> 
        <input name="action" type="hidden" value="remove" /> 
        <input type="button" name="Submit" value="<%=encprops.getProperty("remove")%>" 
            onclick = "updateAndRefreshOccurrence($(document.forms.removeOccurrence))"
        />
      </form>
    </td>
  </tr>
</table>
<br /> <% }
    //create new Occurrence with name
    if(isOwner && (myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())==null)){  
    %>
<table border="0" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">
  <tr>
    <td align="left" valign="top" class="para">
        <font color="#990000">
            <strong><%=encprops.getProperty("createOccurrence")%></strong></font></td>
  </tr>
  <tr>
    <td align="left" valign="top">
      <form name="createOccurrence" method="post" action="../OccurrenceCreate">
        <input name="number" type="hidden" value="<%=num%>" /> 
        <input name="action" type="hidden" value="create" /> 
        <%=encprops.getProperty("newOccurrenceID")%><br />
        <input name="occurrence" type="text" id="occurrence" size="10" maxlength="50" value="" />
        <br />
        <input name="Create" type="button" id="Create" value="<%=encprops.getProperty("create")%>" 
         onclick = "updateAndRefreshOccurrence($(document.forms.createOccurrence))"
        />
      </form>
    </td>
  </tr>
</table>
<br/>   
<strong>--<%=encprops.getProperty("or") %>--</strong>   
<br />
<br />
  <table border="0" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">
    <tr>
      <td align="left" valign="top" class="para"><font color="#990000">
      
        <strong><%=encprops.getProperty("add2Occurrence")%></strong></font></td>
    </tr>
    <tr>
      <td align="left" valign="top">
        <form name="add2occurrence" action="../OccurrenceAddEncounter" method="post">
        <%=encprops.getProperty("occurrenceID")%>: <input name="occurrence" type="text" size="10" maxlength="50" /><br /> 
                                                                            
            <input name="number" type="hidden" value="<%=num%>" /> 
            <input name="action" type="hidden" value="add" />
          <input name="Add" type="button" id="Add" value="<%=encprops.getProperty("add")%>" 
          onclick = "updateAndRefreshOccurrence($(document.forms.add2occurrence))"
          />
          </form>
      </td>
    </tr>
  </table>
 <%
 }
    
%>      
    
<!-- end Occurrence management section -->            
              
</div>
                                <!-- popup dialog script -->
<script>
$("a#occurrence").click(function() {
 var dlgOccurrence = $("#dialogOccurrence").dialog({
	      autoOpen: false,
	      draggable: false,
	      resizable: false,
	      width: 600,
	      close: function(){ $(this).dialog("close"); $(this).dialog("destroy")  }
	    });
  dlgOccurrence.dialog("open");
});
function updateAndRefreshOccurrence(form_object){
    reloadEntireDiv('encounterUpdateOccurrenceID.jsp', form_object , 'wholeEncounterDiv', 'dialogOccurrence' );
}
</script>   
<!-- end set occurrenceID -->  
<%
}
%>
</div>