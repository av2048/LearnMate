<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<%
    // Invalidate the current session to log the user out
    if (session != null) {
        session.invalidate();
    }
    // Redirect to the index.html page
    response.sendRedirect("index.html");
%>

