from flask import Flask, request
from database import create_tables, get_connection
import sqlite3
from dotenv import load_dotenv
import os

app = Flask(__name__)

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"), override=True)

EMAIL_ADDRESS = os.getenv("EMAIL_ADDRESS")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")

def send_confirmation_email(to_email, incident_id):
    import smtplib
    from email.mime.text import MIMEText

    subject = "Incident Report Submitted Successfully"

    body = f"""
Hello,

Your cybersecurity incident report has been successfully registered.

Incident ID: {incident_id}
Status: Pending

Thank you for using the Cybersecurity Incident Reporting System.

This is an automated confirmation email.
"""

    message = MIMEText(body)
    message["Subject"] = subject
    message["From"] = EMAIL_ADDRESS
    message["To"] = to_email

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(
                EMAIL_ADDRESS,
                to_email,
                message.as_string()
            )

        print("Confirmation email sent successfully.")

    except Exception as e:
        print("Email sending failed:", e)

create_tables()


@app.route("/")
def home():
    return "Cybersecurity Incident Reporting System Backend is Running!"

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    name = data.get("name")
    email = data.get("email")
    mobile = data.get("mobile")
    password = data.get("password")

    if not name or not email or not mobile or not password:
        return {"message": "All fields are required"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO users (name, email, mobile, password)
            VALUES (?, ?, ?, ?)
            """,
            (name, email, mobile, password)
        )

        connection.commit()

        return {"message": "Registration successful"}, 201

    except sqlite3.IntegrityError:
        return {"message": "Email already registered"}, 409

    finally:
        connection.close()


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    identifier = data.get("identifier")
    password = data.get("password")

    if not identifier or not password:
        return {"message": "Email/mobile and password are required"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    user = cursor.execute(
        """
        SELECT * FROM users
        WHERE (email = ? OR mobile = ?) AND password = ?
        """,
        (identifier, identifier, password)
    ).fetchone()

    connection.close()

    if user:
        return {
            "message": "Login successful",
            "name": user["name"],
            "email": user["email"],
            "mobile": user["mobile"]
        }, 200

    return {"message": "Invalid email/mobile or password"}, 401
@app.route("/forgot-password", methods=["POST"])
def forgot_password():
    data = request.get_json()

    identifier = data.get("identifier")

    if not identifier:
        return {"message": "Email or mobile number is required"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    user = cursor.execute(
        """
        SELECT * FROM users
        WHERE email = ? OR mobile = ?
        """,
        (identifier, identifier)
    ).fetchone()

    connection.close()

    if user:
        return {"message": "User found. You can reset your password."}, 200

    return {"message": "No account found with this email or mobile number"}, 404
@app.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.get_json()

    identifier = data.get("identifier")
    new_password = data.get("new_password")

    if not identifier or not new_password:
        return {"message": "Email/mobile and new password are required"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    user = cursor.execute(
        """
        SELECT * FROM users
        WHERE email = ? OR mobile = ?
        """,
        (identifier, identifier)
    ).fetchone()

    if not user:
        connection.close()
        return {"message": "No account found with this email or mobile number"}, 404

    cursor.execute(
        """
        UPDATE users
        SET password = ?
        WHERE email = ? OR mobile = ?
        """,
        (new_password, identifier, identifier)
    )

    connection.commit()
    connection.close()

    return {"message": "Password reset successful"}, 200
@app.route("/reports", methods=["POST"])
def create_report():
    data = request.get_json()

    incident_id = data.get("incident_id")
    full_name = data.get("full_name")
    email = data.get("email")
    mobile = data.get("mobile")
    incident_type = data.get("incident_type")
    date = data.get("date")
    time = data.get("time")
    description = data.get("description")
    severity = data.get("severity")
    status = "Pending"

    if not all([
        incident_id,
        full_name,
        email,
        mobile,
        incident_type,
        date,
        time,
        description,
        severity
    ]):
        return {"message": "All fields are required"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO reports (
                incident_id,
                full_name,
                email,
                mobile,
                incident_type,
                date,
                time,
                description,
                severity,
                status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                incident_id,
                full_name,
                email,
                mobile,
                incident_type,
                date,
                time,
                description,
                severity,
                status
            )
        )

        connection.commit()

        send_confirmation_email(email, incident_id)

        return {
            "message": "Incident report submitted successfully",
            "incident_id": incident_id
        }, 201

    except sqlite3.IntegrityError:
        return {"message": "Incident ID already exists"}, 409

    finally:
        connection.close()
@app.route("/reports", methods=["GET"])
def get_all_reports():
    connection = get_connection()
    cursor = connection.cursor()

    reports = cursor.execute(
        """
        SELECT * FROM reports
        ORDER BY id DESC
        """
    ).fetchall()

    connection.close()

    return {
        "reports": [dict(report) for report in reports]
    }, 200

@app.route("/reports/user/<email>", methods=["GET"])
def get_user_reports(email):
    connection = get_connection()
    cursor = connection.cursor()

    reports = cursor.execute(
        """
        SELECT * FROM reports
        WHERE email = ?
        ORDER BY id DESC
        """,
        (email,)
    ).fetchall()

    connection.close()

    return {
        "reports": [dict(report) for report in reports]
    }, 200
@app.route("/reports/<incident_id>/status", methods=["PUT"])
def update_report_status(incident_id):
    data = request.get_json()

    status = data.get("status")

    if status not in ["Pending", "Investigating", "Resolved"]:
        return {"message": "Invalid status"}, 400

    connection = get_connection()
    cursor = connection.cursor()

    report = cursor.execute(
        """
        SELECT * FROM reports
        WHERE incident_id = ?
        """,
        (incident_id,)
    ).fetchone()

    if not report:
        connection.close()
        return {"message": "Report not found"}, 404

    cursor.execute(
        """
        UPDATE reports
        SET status = ?
        WHERE incident_id = ?
        """,
        (status, incident_id)
    )

    connection.commit()
    connection.close()

    return {
        "message": "Report status updated successfully",
        "incident_id": incident_id,
        "status": status
    }, 200
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)