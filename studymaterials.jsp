<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Study Materials</title>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #333;
        }
        form {
            margin-bottom: 20px;
        }
        form input, form button {
            display: block;
            width: 100%;
            margin: 10px 0;
            padding: 10px;
            font-size: 1rem;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table th, table td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
        }
        table th {
            background-color: #f4f4f4;
        }
        .reminder {
            color: red;
            font-weight: bold;
        }
        .completed {
            color: green;
            font-weight: bold;
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

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String materialName = request.getParameter("materialName");

        if (materialName != null && materialName.trim().length() > 0) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

                String query = "INSERT INTO study_materials (userEmail, materialName) VALUES (?, ?)";
                PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setString(1, username);
                stmt.setString(2, materialName);
                int rows = stmt.executeUpdate();

                if (rows > 0) {
                    message = "Study material added successfully!";
                } else {
                    message = "Failed to add study material.";
                }

                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
                message = "An error occurred while saving the material.";
            }
        } else {
            message = "Material name is required.";
        }
    }

    // Handle marking a study material as completed
    if ("GET".equalsIgnoreCase(request.getMethod()) && request.getParameter("markCompleteId") != null) {
        int materialId = Integer.parseInt(request.getParameter("markCompleteId"));
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

            String updateQuery = "UPDATE study_materials SET isCompleted = true WHERE id = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setInt(1, materialId);
            updateStmt.executeUpdate();

            conn.close();

            message = "Material marked as completed!";
        } catch (Exception e) {
            e.printStackTrace();
            message = "An error occurred while marking the material as completed.";
        }
    }

    // Fetch study materials
    List materials = new ArrayList();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/website?useSSL=false", "root", "aarathi2002");

        String query = "SELECT id, materialName, isCompleted FROM study_materials WHERE userEmail = ?";
        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map material = new HashMap();
            material.put("id", rs.getString("id"));
            material.put("name", rs.getString("materialName"));
            material.put("isCompleted", rs.getBoolean("isCompleted") ? "Yes" : "No");
            materials.add(material);
        }

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<div class="container">
    <h1>Study Materials</h1>
    <% if (message != null) { %>
        <p style="color: blue; text-align: center;"><%= message %></p>
    <% } %>
    <form method="post">
        <input type="text" name="materialName" placeholder="Material Name" required>
        <button type="submit">Add Material</button>
    </form>
    <table>
        <thead>
            <tr>
                <th>Material</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Iterator it = materials.iterator(); it.hasNext(); ) { 
                   Map material = (Map)it.next(); %>
                <tr>
                    <td><%= material.get("name") %></td>
                    <td class="<%= "No".equals(material.get("isCompleted")) ? "reminder" : "completed" %>">
                        <%= "Yes".equals(material.get("isCompleted")) ? "Completed" : "Incomplete" %>
                    </td>
                    <td>
                        <% if ("No".equals(material.get("isCompleted"))) { %>
                            <a href="?markCompleteId=<%= material.get("id") %>">Mark Complete</a>
                        <% } %>
                    </td>
        <h3><a href="studentPortal.jsp">Back to Portal</a></h3>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>
</body>
</html>