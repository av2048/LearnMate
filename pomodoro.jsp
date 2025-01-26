<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pomodoro Timer</title>
    <link rel="stylesheet" href="style.css">
    <style>
        body {
            margin: 0;
            font-family: Times New Roman;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: #2c3e50;
            color: teal;
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 20px;
        }
        .timer {
            font-size: 4rem;
            margin-bottom: 20px;
        }
        .controls {
            display: flex;
            gap: 15px;
        }
        .controls button {
            padding: 10px 20px;
            font-size: 1rem;
            border: none;
            border-radius: 5px;
            background-color: #3498db;
            color: #fff;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .error-message {
            color: red;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    // Explicit null handling for session
    String username = null;
    try {
        username = (String) session.getAttribute("userEmail");
        if (username == null || username.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize error message
    String errorMessage = "";
    try {
        // Any additional server-side initialization can go here
    } catch (Exception e) {
        errorMessage = "An error occurred: " + e.getMessage();
    }
%>

<div class="container">
    <h1>Pomodoro Timer</h1>
    
    <% if (!errorMessage.isEmpty()) { %>
        <div class="error-message"><%= errorMessage %></div>
    <% } %>

    <div class="timer" id="timer">25:00</div>

    <div class="controls">
        <button id="start">Start</button>
        <button id="pause">Pause</button>
        <button id="reset">Reset</button>
    </div>
</div>

<script>
    // Defensive programming with comprehensive null checks
    document.addEventListener('DOMContentLoaded', function() {
        // Cache DOM elements with null checks
        var timerDisplay = document.getElementById('timer');
        var startButton = document.getElementById('start');
        var pauseButton = document.getElementById('pause');
        var resetButton = document.getElementById('reset');

        // Validate all required elements exist
        if (!timerDisplay || !startButton || !pauseButton || !resetButton) {
            console.error('One or more critical DOM elements are missing');
            alert('Page initialization error. Please reload.');
            return;
        }

        // Core timer logic with comprehensive error handling
        var totalWorkTime = 0;
        var totalSeconds = 25 * 60;
        var interval = null;
        var isRunning = false;
        var freezeInterval = null;
        
        function createOverlay() {
        var overlay = document.createElement('div');
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.width = '100%';
        overlay.style.height = '100%';
        overlay.style.backgroundColor = 'rgba(0,0,0,0.5)';
        overlay.style.zIndex = '1000';
        overlay.style.display = 'flex';
        overlay.style.justifyContent = 'center';
        overlay.style.alignItems = 'center';
        overlay.style.color = 'white';
        overlay.style.fontSize = '2rem';
        overlay.textContent = 'Break Time! Please wait...';
        document.body.appendChild(overlay);
        return overlay;
    }
    
        function safeUpdateDisplay() {
            try {
                var minutes = Math.floor(totalSeconds / 60);
                var seconds = totalSeconds % 60;
                timerDisplay.textContent = 
                    (minutes < 10 ? '0' : '') + minutes + ':' + 
                    (seconds < 10 ? '0' : '') + seconds;
            } catch (e) {
                console.error('Display update failed', e);
            }
        }

        function startTimer() {
            if (!isRunning) {
                isRunning = true;
                interval = setInterval(function() {
                    if (totalSeconds > 0) {
                        totalSeconds--;
                        totalWorkTime++;
                        if (totalWorkTime >= 120) {
                        pauseTimer();
                        freezeWebsite();
                        return;
                    }
                        safeUpdateDisplay();
                    } else {
                        clearInterval(interval);
                        alert('Time is up!');
                        resetTimer();
                    }
                }, 1000);
            }
        }
        
        function freezeWebsite() {
        var overlay = createOverlay();
        var freezeTime = 60; // 1 minute freeze

        freezeInterval = setInterval(function() {
            if (freezeTime > 0) {
                overlay.textContent = `Break Time! Please wait... (${freezeTime} seconds)`;
                freezeTime--;
            } else {
                clearInterval(freezeInterval);
                document.body.removeChild(overlay);
                resetTimer();
                startTimer();
            }
        }, 1000);
    }

        function pauseTimer() {
            if (interval) {
                clearInterval(interval);
                isRunning = false;
            }
        }

        function resetTimer() {
            if (interval) {
                clearInterval(interval);
            }
            totalSeconds = 25 * 60;
            totalWorkTime = 0;
            isRunning = false;
            safeUpdateDisplay();
        }

        // Safe event binding
        if (startButton) startButton.addEventListener('click', startTimer);
        if (pauseButton) pauseButton.addEventListener('click', pauseTimer);
        if (resetButton) resetButton.addEventListener('click', resetTimer);

        // Initial display
        safeUpdateDisplay();
    });
</script>
<h3><a href="studentPortal.jsp">Back to Portal</a></h3>
</body>
</html>