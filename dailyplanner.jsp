<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Planner</title>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .planner-container {
            background: white;
            padding: 40px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
            border-radius: 10px;
        }

        .planner-container h2 {
            text-align: center;
            font-size: 30px;
            margin-bottom: 20px;
        }

        .planner-container textarea {
            width: 100%;
            height: 200px;
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 16px;
            resize: none;
            margin-bottom: 20px;
        }

        .planner-container button {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            font-size: 18px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .planner-container button:hover {
            background-color: #45a049;
        }

        .result {
            margin-top: 30px;
        }

        .tasks-list {
            margin-top: 30px;
        }

        .tasks-list li {
            margin-bottom: 10px;
        }

        .complete-btn {
            background-color: #3498db;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .complete-btn:hover {
            background-color: #2980b9;
        }

        .completed-task {
            text-decoration: line-through;
            color: #888;
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

    String name = null;
    String dailyPlan = null;
    boolean isFormSubmitted = false;

    // Database connection
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet tasksResultSet = null;

    try {
        // Establishing database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

        // Fetch user details
        String query = "SELECT name FROM users WHERE email = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
        }

        // Insert daily plan into the database when form is submitted
        if (request.getMethod().equalsIgnoreCase("POST")) {
            if (request.getParameter("dailyPlan") != null && !request.getParameter("dailyPlan").trim().isEmpty()) {
                dailyPlan = request.getParameter("dailyPlan");

                // Insert the daily plan
                String insertQuery = "INSERT INTO daily_planner (user_email, task_description, is_completed) VALUES (?, ?, ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
                insertStmt.setString(1, username);
                insertStmt.setString(2, dailyPlan);
                insertStmt.setBoolean(3, false); // Default to not completed
                insertStmt.executeUpdate();
                isFormSubmitted = true;
            }
        }

        // Fetch user's tasks from the database
        String tasksQuery = "SELECT * FROM daily_planner WHERE user_email = ?";
        stmt = conn.prepareStatement(tasksQuery);
        stmt.setString(1, username);
        tasksResultSet = stmt.executeQuery();

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<div class="planner-container">
    <h2>Daily Planner</h2>

    <!-- Form to submit daily plan -->
    <form method="POST">
        <textarea name="dailyPlan" placeholder="Enter your daily tasks and goals..." required></textarea>
        <button type="submit">Submit Plan</button>
        <h3 align="center"><a href="studentPortal.jsp">Back to Portal</a></h3>
    </form>

    <%
        if (isFormSubmitted) {
    %>
    <div class="result">
        <h3>Daily Plan Submitted Successfully!</h3>
        <p>Your plan has been saved to the database.</p>
    </div>
    
    <%
        }
    %>

    <div class="tasks-list">
        <h3>Your Tasks:</h3>
        <ul>
            <%
                // Display all tasks for the logged-in user
                while (tasksResultSet.next()) {
                    int taskId = tasksResultSet.getInt("id");
                    String taskDescription = tasksResultSet.getString("task_description");
                    boolean isCompleted = tasksResultSet.getBoolean("is_completed");
            %>
            <li class="<%= isCompleted ? "completed-task" : "" %>">
                <%= taskDescription %>
                <%
                    if (!isCompleted) {
                %>
                    <form method="POST" style="display:inline;">
                        <input type="hidden" name="taskId" value="<%= taskId %>">
                        <button type="submit" name="markCompleted" class="complete-btn">Mark as Completed</button>                        
                          
   
                    </form>
                <%
                    } else {
                %>
                    <span style="color:green;">Completed</span>
                    
                <%
                    }
                %>
            </li>
            <%
                }
            %>
        </ul>
    </div>
</div>

<%
    // Handle marking a task as completed
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("markCompleted") != null) {
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        try {
            String updateQuery = "UPDATE daily_planner SET is_completed = ? WHERE id = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setBoolean(1, true); // Mark as completed
            updateStmt.setInt(2, taskId);
            updateStmt.executeUpdate();
            response.sendRedirect("dailyplanner.jsp"); // Refresh the page after marking the task as completed
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Closing resources
    if (tasksResultSet != null) {
        tasksResultSet.close();
    }
    if (stmt != null) {
        stmt.close();
    }
    if (conn != null) {
        conn.close();
    }
%>

</body>
</html>
