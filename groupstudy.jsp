<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Group Study</title>
    <link rel="stylesheet" href="style.css">
    <script>
        // Function to show success message using a popup and then redirect
        function showSuccessMessage() {
            alert("Group study session created successfully! Invitations have been sent.");
            window.location.href = "studentPortal.jsp";  // Redirect to student portal after the alert
        }
    </script>
</head>
<body>
<%
    String username = (String) session.getAttribute("userEmail");
    if (username == null) {
        response.sendRedirect("login.jsp"); // Redirect to login if not logged in
        return;
    }

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String studyTopic = request.getParameter("studyTopic");
        String description = request.getParameter("description");
        String invitees = request.getParameter("invitees"); // comma-separated list of emails

        if (studyTopic != null && !studyTopic.trim().isEmpty()) {
            try {
                // Database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

                // Insert group study session into database
                String query = "INSERT INTO group_study_sessions (hostEmail, studyTopic, description) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setString(1, username);
                stmt.setString(2, studyTopic);
                stmt.setString(3, description);
                int rows = stmt.executeUpdate();

                if (rows > 0) {
                    // Get the generated session ID
                    ResultSet rs = stmt.getGeneratedKeys();
                    int sessionId = 0;
                    if (rs.next()) {
                        sessionId = rs.getInt(1);
                    }

                    // Simulate sending invites (without actually sending emails)
                    if (invitees != null && !invitees.trim().isEmpty()) {
                        String[] emails = invitees.split(",");
                        for (String email : emails) {
                            // No email is sent, but a dummy invite record is added
                            String inviteQuery = "INSERT INTO group_study_invitations (sessionId, inviteeEmail) VALUES (?, ?)";
                            PreparedStatement inviteStmt = conn.prepareStatement(inviteQuery);
                            inviteStmt.setInt(1, sessionId);
                            inviteStmt.setString(2, email.trim());
                            inviteStmt.executeUpdate();
                        }
                    }

                    // Set the success message
                    message = "Group study session created and invitations sent!";
                } else {
                    message = "Failed to create group study session.";
                }

                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
                message = " ";
            }
        } else {
            message = "Study topic is required.";
        }
    }
%>

<div class="container">
    <h2>Create Group Study Session</h2>
    <% if (message != null) { %>
        <p style="color: blue; text-align: center;"><%= message %></p>
        <script>
            // Display the success message popup after the session is created
            showSuccessMessage();
        </script>
    <% } %>
    <form method="post">
        <label for="studyTopic">Study Topic</label>
        <input type="text" id="studyTopic" name="studyTopic" required>

        <label for="description">Description</label>
        <textarea id="description" name="description" rows="4" required></textarea>

        <label for="invitees">Invitees (comma-separated emails)</label>
        <input type="text" id="invitees" name="invitees" placeholder="example1@gmail.com, example2@gmail.com">

        <button type="submit">Create Session</button>
    </form>
</div>
</body>
</html>
