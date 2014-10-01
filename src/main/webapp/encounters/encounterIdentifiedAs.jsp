<%@ page contentType="text/html; charset=utf-8" language="java"
	import="org.ecocean.servlet.ServletUtilities,com.drew.imaging.jpeg.JpegMetadataReader, com.drew.metadata.Directory, com.drew.metadata.Metadata, com.drew.metadata.Tag, org.ecocean.*,org.ecocean.servlet.ServletUtilities,org.ecocean.Util,org.ecocean.Measurement, org.ecocean.Util.*, org.ecocean.genetics.*, org.ecocean.tag.*, java.awt.Dimension, javax.jdo.Extent, javax.jdo.Query, java.io.File, java.text.DecimalFormat, java.util.*, org.ecocean.security.Collaboration"%>
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

<%!

  //shepherd must have an open trasnaction when passed in
  public String getNextIndividualNumber(Encounter enc, Shepherd myShepherd, String context) {
    String returnString = "";
    try {
      String lcode = enc.getLocationCode();
      if ((lcode != null) && (!lcode.equals(""))) {

        //let's see if we can find a string in the mapping properties file
        Properties props = new Properties();
        //set up the file input stream
        //props.load(getClass().getResourceAsStream("/bundles/newIndividualNumbers.properties"));
        props=ShepherdProperties.getProperties("newIndividualNumbers.properties", "",context);

        //let's see if the property is defined
        if (props.getProperty(lcode) != null) {
          returnString = props.getProperty(lcode);


          int startNum = 1;
          boolean keepIterating = true;

          //let's iterate through the potential individuals
          while (keepIterating) {
            String startNumString = Integer.toString(startNum);
            if (startNumString.length() < 3) {
              while (startNumString.length() < 3) {
                startNumString = "0" + startNumString;
              }
            }
            String compositeString = returnString + startNumString;
            if (!myShepherd.isMarkedIndividual(compositeString)) {
              keepIterating = false;
              returnString = compositeString;
            } else {
              startNum++;
            }

          }
          return returnString;

        }


      }
      return returnString;
    } 
    catch (Exception e) {
      e.printStackTrace();
      return returnString;
    }
  }

%>


<div id="whole_indentified_as_block">
	<% if (enc.isAssignedToMarkedIndividual().equals("Unassigned")) { %>
	<p class="para">
		<%=encprops.getProperty("identified_as") %>
		<%=enc.isAssignedToMarkedIndividual()%>
		<%
                                    if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
                                    %>
		<a id="identity" class="launchPopup"><img align="absmiddle"
			width="20px" height="20px" style="border-style: none;"
			src="../images/Crystal_Clear_action_edit.png" /></a>
		<% } %>
	</p>
	<%
      } 
      else {
      %>
	<p class="para">

		<%=encprops.getProperty("identified_as") %>
		<a
			href="../individuals.jsp?langCode=<%=langCode%>&number=<%=enc.isAssignedToMarkedIndividual()%><%if(request.getParameter("noscript")!=null){%>&noscript=true<%}%>"><%=enc.isAssignedToMarkedIndividual()%></a>
		<%
                                    if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
                                    %>
		<a id="identity" class="launchPopup"><img align="absmiddle"
			width="20px" height="20px" style="border-style: none;"
			src="../images/Crystal_Clear_action_edit.png" /></a>
		<%
                                    }
                                    %>
		<br /> <br /> <img align="absmiddle"
			src="../images/Crystal_Clear_app_matchedBy.gif">
		<%=encprops.getProperty("matched_by") %>:
		<%=enc.getMatchedBy()%>
		<%
                                    if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
                                    %>
		<a id="matchedBy" class="launchPopup"><img align="absmiddle"
			width="20px" height="20px" style="border-style: none;"
			src="../images/Crystal_Clear_action_edit.png" /></a>
	<div id="dialogMatchedBy"
		title="<%=encprops.getProperty("matchedBy")%>" style="display: none">
		<table>
			<tr>
				<td align="left" valign="top">
					<form name="setMBT" action="../EncounterSetMatchedBy" method="post">
						<select name="matchedBy" id="matchedBy">
							<option value="Unmatched first encounter"><%=encprops.getProperty("unmatchedFirstEncounter")%></option>
							<option value="Visual inspection"><%=encprops.getProperty("visualInspection")%></option>
							<option value="Pattern match" selected><%=encprops.getProperty("patternMatch")%></option>
						</select> 
						<input name="number" type="hidden" value="<%=num%>" /> 
						<input	name="setMB" type="button" id="setMB" value="<%=encprops.getProperty("set")%>" 
						onclick = "reloadEntireDiv('encounterIdentifiedAs.jsp', $(document.forms.setMBT) , 'whole_indentified_as_block', 'dialogMatchedBy' ) "
						/>
					</form>
				</td>
			</tr>
		</table>
	</div>
	<script>
                                        $("a#matchedBy").click(function() {
                                        	 var dlgMatchedBy = $("#dialogMatchedBy").dialog({
                                                 autoOpen: false,
                                                 draggable: false,
                                                 resizable: false,
                                                 width: 600,
                                                 close: function(){ $(this).dialog("close"); $(this).dialog("destroy")  }
                                             });

                                            dlgMatchedBy.dialog("open");
                                        });
                                    </script>
	<%
                                     }
                                    %>
	</p>
	<%
                                } //end else
                                
                                if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
                                %>
	<div id="dialogIdentity"
		title="<%=encprops.getProperty("manageIdentity")%>"
		style="display: none">
		<p>
			<em><%=encprops.getProperty("identityMessage") %></em>
		</p>

		<%
                                    if((enc.isAssignedToMarkedIndividual()==null)||(enc.isAssignedToMarkedIndividual().equals("Unassigned"))){
                                    %>

		<table border="1" cellpadding="1" cellspacing="0"
			bordercolor="#FFFFFF">
			<tr>
				<td align="left" valign="top" class="para"><font
					color="#990000"> <img align="absmiddle"
						src="../images/tag_small.gif" /><br /> <strong><%=encprops.getProperty("add2MarkedIndividual")%>:</strong>
				</font></td>
			</tr>
			<tr>
				<td align="left" valign="top">
					<form name="add2shark" action="../IndividualAddEncounter"
						method="post">
						<%=encprops.getProperty("individual")%>: <input name="individual"
							type="text" size="10" maxlength="50" /><br />
						<%=encprops.getProperty("matchedBy")%>:<br /> <select
							name="matchType" id="matchType">
							<option value="Unmatched first encounter"><%=encprops.getProperty("unmatchedFirstEncounter")%></option>
							<option value="Visual inspection"><%=encprops.getProperty("visualInspection")%></option>
							<option value="Pattern match" selected><%=encprops.getProperty("patternMatch")%></option>
						</select> <br /> <input name="noemail" type="checkbox" value="noemail" />
						<%=encprops.getProperty("suppressEmail")%><br /> <input
							name="number" type="hidden" value="<%=num%>" /> <input
							name="action" type="hidden" value="add" /> <input name="Add"
							type="button" id="Add" value="<%=encprops.getProperty("add")%>"
                            onclick = "reloadEntireDiv('encounterIdentifiedAs.jsp', $(document.forms.add2shark) , 'whole_indentified_as_block', 'dialogIdentity' ) " />
					</form>
				</td>
			</tr>
		</table>
		<br /> <strong>--<%=encprops.getProperty("or") %>--
		</strong> <br />
		<br />
		<%
                                    }
                                    //Remove from MarkedIndividual if not unassigned
                                    if((!enc.isAssignedToMarkedIndividual().equals("Unassigned")) && CommonConfiguration.isCatalogEditable(context)) {
                                    %>
		<table cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">
			<tr>
				<td align="left" valign="top" class="para">
					<table>
						<tr>
							<td><font color="#990000"> <img align="absmiddle"
									src="../images/cancel.gif" />
							</font></td>
							<td><strong> <%=encprops.getProperty("removeFromMarkedIndividual")%>
							</strong></td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td align="left" valign="top">
					<form action="../IndividualRemoveEncounter" method="post"	name="removeShark" onsubmit="return false;">
						<input name="number" type="hidden" value="<%=num%>" /> 
						<input	name="action" type="hidden" value="remove" /> 
						<input type="button" name="Submit"	value="<%=encprops.getProperty("remove")%>" 
							onclick = "reloadEntireDiv('encounterIdentifiedAs.jsp', $(document.forms.removeShark) , 'whole_indentified_as_block', 'dialogIdentity' ) "
							/>
					</form>
				</td>
			</tr>
		</table>
		<br />
		<%
                                    }
                                    if((enc.isAssignedToMarkedIndividual()==null)||(enc.isAssignedToMarkedIndividual().equals("Unassigned"))){
                                    %>

		<table border="1" cellpadding="1" cellspacing="0"
			bordercolor="#FFFFFF">
			<tr>
				<td align="left" valign="top" class="para"><font
					color="#990000"> <img align="absmiddle"
						src="../images/tag_small.gif" /> <strong><%=encprops.getProperty("createMarkedIndividual")%>:</strong>
				</font></td>
			</tr>
			<tr>
				<td align="left" valign="top">
					<form name="createShark" method="post" action="../IndividualCreate">
						<input name="number" type="hidden" value="<%=num%>" /> <input
							name="action" type="hidden" value="create" /> <input
							name="individual" type="text" id="individual" size="10"
							maxlength="50"
							value="<%=getNextIndividualNumber(enc, myShepherd,context)%>" /><br />
						<input name="noemail" type="checkbox" value="noemail" />
						<%=encprops.getProperty("suppressEmail")%><br /> <input
							name="Create" type="button" id="Create"
							value="<%=encprops.getProperty("create")%>"
							onclick = "reloadEntireDiv('encounterIdentifiedAs.jsp', $(document.forms.createShark) , 'whole_indentified_as_block', 'dialogIdentity' ) "
							/>
					</form>
				</td>
			</tr>
		</table>
		<% } %>
	</div>
	<script>
        $("a#identity").click(function() {
        	var dlgIdentity = $("#dialogIdentity").dialog({
                autoOpen: false,
                draggable: false,
                resizable: false,
                width: 600,
                close: function(){ $(this).dialog("close"); $(this).dialog("destroy")  }
            });
            dlgIdentity.dialog("open");
        });
    </script>
	<%
                        }
                        %>
</div>