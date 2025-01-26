<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Portal</title>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
    margin: 0;
    font-family: Arial, sans-serif;
    background-image: url('1.jpg'); /* Replace with your image */
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    
} 
        .sidebar {
            width: 250px;
            padding: 20px;
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
        }
        .sidebar img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin: 0 auto;
            display: block;
            border: 3px solid white;
        }
        .sidebar h3 {
            text-align: center;
            margin: 10px 0 5px;
            font-family: Times New Roman;
        }
        .main-content {
            flex: 1;
            padding: 20px;
            background: #f4f4f4;
        }
        .main-content h2 {
            margin-top: 0;
            font-family: Times New Roman;
            font-size: 40px;
        }
        .main-content p {
            font-size: 25px;
            font-family: Times New Roman;
        }
        .activities {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .activity-card {
            padding: 50px;
            background: white;
            border-radius: 50px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.2s;
        }
        .activity-card:hover {
            transform: scale(1.05);
        }
        .activity-card h4 {
            margin: 10px 0;
            font-size: 25px;
        }
        .activity-card i {
            font-size: 2rem;
            color: #3498db;
        }
        .activity-card a {
            
            color: black;
        }
        .logout a{
            font-family: Times New Roman;
            position: fixed;
            top: 0;
            right: 0;
        }
    </style>
</head>
<body>
<%
    String username = (String) session.getAttribute("userEmail");
    if (username == null) {
        response.sendRedirect("login.jsp"); // Redirect to login if not logged in
        return;
    }

    String name = null, profilePicture = null;

    try {
        // Database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

        // Fetch user details
        String query = "SELECT name FROM users WHERE email = ?";
        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            profilePicture = rs.getString("profilePicture");
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<div class="sidebar">
    <img src="<%= profilePicture != null ? profilePicture : "user.jpeg" %>" alt="Profile Picture">
    <h3><%= name != null ? name : "User" %></h3>
    

</div>


</div>

<div class="main-content">
    <h2>Welcome, <%= name != null ? name : "User" %>!</h2>
    <p>Here are your activities:</p>
    <div class="activities">
        <div class="activity-card">
            <i class="fas fa-clock"></i>
            <h4> <a href="pomodoro.jsp">Pomodoro</a></h4>
        </div>
        <div class="activity-card">
            <i class="fas fa-calendar-alt"></i>
            <h4><a href="dailyplanner.jsp">Daily Planner</a></h4>
        </div>
        <div class="activity-card">
            <i class="fas fa-users"></i>
            <h4><a href="groupstudy.jsp">Group Study</a></h4>
        </div>
        <div class="activity-card">
            <i class="fas fa-book"></i>
            <h4><a href="studymaterials.jsp">Study Materials</a></h4>
        </div>
        <div class="activity-card">
            <i class="fas fa-chart-line"></i>
            <h4><a href="academicPerformance.jsp">Academic Performance</a></h4>
        </div>
    </div>
</div>
    <div class="logout"><a href="logout.jsp" style="text-decoration: none; color: black; border-radius: 5px;">Logout</a></div>

<!-- Font Awesome for activity icons -->
<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
</body>
</html>
