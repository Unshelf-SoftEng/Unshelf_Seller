const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Create a transporter for sending emails
const transporter = nodemailer.createTransport({
  service: "Gmail", // or your email service
  auth: {
    user: "your_email@gmail.com", // your email
    pass: "your_password", // your email password
  },
});

exports.sendCustomPasswordResetEmail = functions.https.onCall(
    async (data, context) => {
      const {email, userName} = data;

      // Generate the password reset link
      const resetLink = await admin.auth().generatePasswordResetLink(email);

      // Create the email content with HTML
      const emailHtml = `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Your Password</title>
        <style>
          .email-body {
            font-family: Arial, sans-serif;
            color: #333333;
            line-height: 1.6;
            padding: 20px;
          }
          .button {
            display: inline-block;
            padding: 10px 20px;
            font-size: 16px;
            color: #ffffff;
            background-color: #4CAF50;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 15px;
          }
        </style>
      </head>
      <body>
        <div class="email-body">
          <p>Hi ${userName},</p>
          <p>We received a request to reset your Unshelf 
          password for your account associated with ${email}.
          To proceed, please click the link below:</p>
          <p><a href='${resetLink}' class="button">Reset Your Password</a></p>
          <p>If the button above doesn’t work, 
          copy and paste the following link into your browser:</p>
          <p><a href='${resetLink}'>${resetLink}</a></p>
          <p>If you didn’t ask to reset your password, 
          please ignore this email or 
          let us know by contacting our support team.</p>
          <p>Thanks,</p>
          <p>The Unshelf Team</p>
          <p><small>Please do not reply to this email. 
          This mailbox is not monitored, 
          and you will not receive a response.</small></p>
        </div>
      </body>
      </html>
    `;

      // Set up email options
      const mailOptions = {
        from: "noreply@unshelf-d4567.firebaseapp.com",
        to: email,
        subject: "Reset your password",
        html: emailHtml,
      };

      try {
      // Send the email
        await transporter.sendMail(mailOptions);
        return {
          success: true,
          message: "Password reset email sent successfully!",
        };
      } catch (error) {
        return {
          success: false,
          message: "Error sending email: " + error.message,
        };
      }
    },
);
