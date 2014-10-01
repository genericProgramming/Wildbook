/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.servlet;

import org.ecocean.CommonConfiguration;
import org.ecocean.Encounter;
import org.ecocean.Shepherd;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;


public class EncounterAddComment extends HttpServlet {

  public void init(ServletConfig config) throws ServletException {
    super.init(config);
  }


  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }


  private void setDateLastModified(Encounter enc) {
    String strOutputDateTime = ServletUtilities.getDate();
    enc.setDWCDateLastModified(strOutputDateTime);
  }


  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String context="context0";
    context=ServletUtilities.getContext(request);
    Shepherd myShepherd = new Shepherd(context);
    //set up for response
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    boolean locked = false;

    boolean isOwner = true;

    myShepherd.beginDBTransaction();
    if ((request.getParameter("number") != null) && (request.getParameter("user") != null) && (request.getParameter("autocomments") != null) && (myShepherd.isEncounter(request.getParameter("number")))) {

      Encounter commentMe = myShepherd.getEncounter(request.getParameter("number"));
      setDateLastModified(commentMe);
      try {

        commentMe.addComments("<p><em>" + request.getParameter("user") + " on " + (new java.util.Date()).toString() + "</em><br>" + request.getParameter("autocomments") + "</p>");
      } catch (Exception le) {
        locked = true;
        le.printStackTrace();
        myShepherd.rollbackDBTransaction();
      }


      out.println(ServletUtilities.getHeader(request));
      if (!locked) {
        myShepherd.commitDBTransaction();
        out.println("<strong>Success:</strong> I have successfully added your comments.");
        out.println("<p><a href=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/encounter.jsp?number=" + request.getParameter("number") + "\">Return to encounter #" + request.getParameter("number") + "</a></p>\n");
        String message = "A new comment has been added to encounter #" + request.getParameter("number") + ". The new comment is: \n" + request.getParameter("autocomments");
        ServletUtilities.informInterestedParties(request, request.getParameter("number"), message,context);
      } else {
        out.println("<strong>Failure:</strong> I did NOT add your comments. Another user is currently modifying the entry for this encounter. Please try to add your comments again in a few seconds.");
        // removing the unnecessary links
      }
      out.println(ServletUtilities.getFooter(context));


    } else {
      out.println(ServletUtilities.getHeader(request));
      out.println("<strong>Error:</strong> I don't have enough information to add your comments.");
      // removing the unnecessary links
      out.println(ServletUtilities.getFooter(context));
    }
    myShepherd.closeDBTransaction();


    out.close();
    myShepherd.closeDBTransaction();
  }
}
	
	
