const sgMail = require('@sendgrid/mail');
require('dotenv').config();
sgMail.setApiKey(process.env.SENDGRID_API_KEY); // Store in .env

exports.sendNotificationEmail = async(toEmail, centerType)=>{
  const msg = {
    to: toEmail,
    from:'ighata08@gmail.com',// Verified sender
    subject: 'Emergency Center Registered',
    text: `Your ${centerType} emergency center has been successfully registered.
            We will send you an email of the approval after we study the application`,
    html: `<strong>Your ${centerType} emergency center has been successfully registered.
            We will send you an email of the approval after we study the application</strong>`,
  };
  try {
    await sgMail.send(msg);
    console.log('Email sent');
  } catch (error) {
    console.error(error.response?.body || error);
  }
}

exports.approvalNotificationEmail =  async(toEmail, centerType)=> {
  const msg = {
    to: toEmail,
    from: 'ighata08@gmail.com', // Verified sender
    subject: 'Your request has been approved',
    text: `Your ${centerType} emergency center has been approved and activated.
            Now you can sign into your account.`,
    html: `<strong>Your ${centerType} emergency center has been approved and activated.
            Now you can sign into your account.</strong>`,
  };

  try {
    await sgMail.send(msg);
    console.log('Email sent');
  } catch (error) {
    console.error(error.response?.body || error);
  }
}


