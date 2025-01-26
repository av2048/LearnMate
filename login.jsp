<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String errorMessage = null;

    // If the form is submitted
    if (email != null && password != null) {
        // Database connection settings
        String url = "jdbc:mysql://localhost:3306/website";
        String dbUser = "root";
        String dbPassword = "aarathi2002";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

            String query = "SELECT * FROM users WHERE email = ? AND password = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                // Valid user, set session and redirect to user portal
                session.setAttribute("userEmail", email);
                response.sendRedirect("studentPortal.jsp");
            } else {
                // Invalid user, set error message
                errorMessage = "Invalid email or password.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "An error occurred. Please try again.";
        }
    }

%>

<div class="login-signup-box">
    <h3>Login</h3>
    <form action="login.jsp" method="post">
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required>

        <button type="submit">Login</button>

        <% if (errorMessage != null) { %>
            <p style="color: red;">
                <%= errorMessage %>
            </p>
        <% } %>
    </form>

    <p>Don't have an account? <a href="signup.jsp">Sign up here</a>.</p>
</div>

</body>
</html>