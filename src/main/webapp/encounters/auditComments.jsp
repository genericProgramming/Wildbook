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
<div id="dialogAutoComments" title="<%=encprops.getProperty("auto_comments")%>" style="display:none">
	<table>
	  <tr>
	    <td valign="top">
	      <%
	      String rComments="";
	      if(enc.getRComments()!=null){rComments=enc.getRComments();}
	      %>
	      <div style="text-align:left;border:1px solid black;width:575px;height:400px;overflow-y:scroll;overflow-x:scroll;">
	            <p class="para"><%=rComments.replaceAll("\n", "<br />")%></p>
	      </div>
	      <% if(isOwner && CommonConfiguration.isCatalogEditable(context)){ %>
		      <form action="../EncounterAddComment" method="post" name="addComments" onsubmit="return false;">
		        <p class="para">
		          <input name="user" type="hidden" value="<%=request.getRemoteUser()%>" id="user" />
		          <input name="number" type="hidden" value="<%=enc.getEncounterNumber()%>" id="number" />
		          <input name="action" type="hidden" value="enc_comments" id="action" />
		        </p>
		        <p>
		          <textarea name="autocomments" cols="50" id="autocomments"></textarea> <br/>
		          <input name="Submit" type="button" value="<%=encprops.getProperty("add_comment")%>"
		          onclick="reloadComments()" 
		          />
		        </p>
		      </form>
	      <% } %>
	    </td>
	  </tr>
	</table>
	<script type="text/javascript">
		 function reloadComments(){
		  // call the reload function to submit the comments
		  ajaxSubmit( function(){} , function() {
		   // reload this div with the data submitted
		   $.get( "auditComments.jsp", $(document.forms.addComments).serialize(), function(data){
			   console.log(data);
			   console.log($("#dialogAutoComments"));
			   comments = data;
			   // update the dialog
			   $("#dialogAutoComments").dialog("destroy");
			   $("#dialogAutoComments").replaceWith(data);
		       dlgAutoComments = $("#dialogAutoComments").dialog({
		             autoOpen: false,
		             draggable: false,
		             resizable: false,
		             width: 600
		           });
		   }, 'html');
		  }, $(document.forms.addComments), 'dialogAutoComments');
		 }
		 
		 var dlgAutoComments = $("#dialogAutoComments").dialog({
             autoOpen: false,
             draggable: false,
             resizable: false,
             width: 600
           });
		 
		$("a#autocomments").click(function() {
		  dlgAutoComments.dialog("open");
		});
	</script>
</div>

