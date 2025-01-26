<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <link rel="stylesheet" href="style.css">
    <script>
        function redirectToPortal() {
            alert("You have registered successfully!");
            window.location.href = "studentPortal.jsp"; // Redirect to the student portal
        }
    </script>
</head>
<body>
<%
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String message = null;
    String errorMessage = null;

    // Database connection settings
    String url = "jdbc:mysql://localhost:3306/website";
    String dbUser = "root";
    String dbPassword = "aarathi2002";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (name != null && email != null && password != null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

                // Check if the user already exists
                String query = "SELECT * FROM users WHERE email = ?";
                PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setString(1, email); 
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    errorMessage = "User with this email already exists.";
                } else {
                    // Insert new user into the database
                    query = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, name);
                    stmt.setString(2, email);
                    stmt.setString(3, password); // Remember to hash the password in a real application
                    int rows = stmt.executeUpdate();

                    if (rows > 0) {
                        session.setAttribute("userEmail", email); // Set session for the new user
                        out.println("<script>redirectToPortal();</script>");
                    } else {
                        errorMessage = "Error occurred during registration.";
                    }
                }

                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
                errorMessage = "An error occurred.";
            }
        } else {
            errorMessage = "Please fill in all fields.";
        }
    }
%>

<div class="login-signup-box">
    <h3>Sign Up</h3>
    <form action="signup.jsp" method="post">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name" required>

        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required>

        <button type="submit">Sign Up</button>
    </form>

    <% if (errorMessage != null) { %>
        <p style="color: red;">
            <%= errorMessage %>
        </p>
    <% } %>
</div>
</body>
</html> 