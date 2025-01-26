<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Marks</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .marks-form {
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .marks-form h3 {
            text-align: center;
            color: #333;
        }
        .marks-form input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .marks-form button {
            width: 100%;
            padding: 10px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
        }
        .subject-input {
            margin-bottom: 15px;
            padding: 10px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        #performanceTable {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }
        #performanceTable th, 
        #performanceTable td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        #performanceTable thead {
            background-color: #f2f2f2;
        }
        .error {
            color: red;
            font-size: 14px;
            margin-top: -10px;
        }
    </style>
</head>
<body>
<%
    String username = (String) session.getAttribute("userEmail");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<div class="marks-form">
    <h3>Hi <%= username.split("@")[0] %>, Upload Your Marks</h3>
    <form id="marksForm">
        <label for="subjectCount">Number of Subjects:</label>
        <input type="number" id="subjectCount" min="1" max="10" required>
        <span id="errorSubjectCount" class="error"></span>
        <button type="button" onclick="generateSubjects()">Generate Subjects</button>
        
        <div id="subjectsContainer"></div>
        <button type="button" id="calculateBtn" onclick="calculatePerformance()" style="display:none;">Calculate Performance</button>
        <button type="button" id="resetBtn" onclick="resetForm()" style="display:none;">Reset</button>
    </form>

    <div id="performanceResult"></div>
</div>

<script>
    function generateSubjects() {
        const subjectCount = document.getElementById('subjectCount').value;
        const container = document.getElementById('subjectsContainer');
        const calculateBtn = document.getElementById('calculateBtn');
        const resetBtn = document.getElementById('resetBtn');
        const errorSubjectCount = document.getElementById('errorSubjectCount');
        
        if (!subjectCount || subjectCount < 1 || subjectCount > 10) {
            errorSubjectCount.textContent = "Please enter a valid number of subjects (1-10).";
            return;
        }

        errorSubjectCount.textContent = "";
        container.innerHTML = ''; // Clear previous subjects
        
        for (let i = 1; i <= subjectCount; i++) {
            const subjectDiv = document.createElement('div');
            subjectDiv.className = 'subject-input';
            subjectDiv.innerHTML = `
                <label>Subject ${i} Name:</label>
                <input type="text" name="subjectName" required>
                <label>Maximum Marks:</label>
                <input type="number" name="maxMarks" min="1" required>
                <label>Obtained Marks:</label>
                <input type="number" name="obtainedMarks" min="0" required>
            `;
            container.appendChild(subjectDiv);
        }
        
        calculateBtn.style.display = 'block';
        resetBtn.style.display = 'block';
    }

    function calculatePerformance() {
        const subjectNames = document.getElementsByName('subjectName');
        const maxMarks = document.getElementsByName('maxMarks');
        const obtainedMarks = document.getElementsByName('obtainedMarks');
        
        let totalMaxMarks = 0;
        let totalObtainedMarks = 0;
        let performanceData = [];

        for (let i = 0; i < subjectNames.length; i++) {
            const name = subjectNames[i].value.trim();
            const max = parseFloat(maxMarks[i].value);
            const obtained = parseFloat(obtainedMarks[i].value);

            if (!name || max <= 0 || obtained < 0 || obtained > max) {
                alert(`Invalid data for Subject ${i + 1}. Please check and correct the input.`);
                return;
            }
            
            const percentage = ((obtained / max) * 100).toFixed(2); // Correct percentage calculation
            totalMaxMarks += max;
            totalObtainedMarks += obtained;

            performanceData.push({
                name: name,
                maxMarks: max,
                obtainedMarks: obtained,
                percentage: percentage,
                grade: getGrade(percentage)
            });
        }

        const overallPercentage = ((totalObtainedMarks / totalMaxMarks) * 100).toFixed(2); // Overall percentage calculation
        const overallGrade = getGrade(overallPercentage);

        displayPerformance(performanceData, overallPercentage, overallGrade);
    }

    function getGrade(percentage) {
        if (percentage >= 90) return 'A+';
        if (percentage >= 80) return 'A';
        if (percentage >= 70) return 'B';
        if (percentage >= 60) return 'C';
        if (percentage >= 50) return 'D';
        return 'F';
    }

    function displayPerformance(data, overallPercentage, overallGrade) {
        const resultDiv = document.getElementById('performanceResult');
        
        let tableHtml = `
            <table id="performanceTable">
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Max Marks</th>
                        <th>Obtained Marks</th>
                        <th>Percentage</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
        `;

        data.forEach(subject => {
            tableHtml += `
                <tr>
                    <td>${subject.name}</td>
                    <td>${subject.maxMarks}</td>
                    <td>${subject.obtainedMarks}</td>
                    <td>${subject.percentage}%</td>
                    <td>${subject.grade}</td>
                </tr>
            `;
        });

        tableHtml += `
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="3"><strong>Overall Performance</strong></td>
                        <td><strong>${overallPercentage}%</strong></td>
                        <td><strong>${overallGrade}</strong></td>
                    </tr>
                </tfoot>
            </table>
        `;

        resultDiv.innerHTML = tableHtml;
    }

    function resetForm() {
        document.getElementById('marksForm').reset();
        document.getElementById('subjectsContainer').innerHTML = '';
        document.getElementById('performanceResult').innerHTML = '';
        document.getElementById('calculateBtn').style.display = 'none';
        document.getElementById('resetBtn').style.display = 'none';
    }
</script>
</body>
</html>
