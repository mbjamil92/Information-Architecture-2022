 #generate app password @google -https://myaccount.google.com/security
import email
import smtplib
from datetime import datetime

gmail_user = 'nayaksurbhi17@gmail.com'
gmail_password = ''
now = datetime.now() # current date and time


sent_from = gmail_user
to = ['snayak@mail.yu.edu']
subject = 'Batch Process Completed on: ' + now.strftime("%m/%d/%Y - %H:%M:%S")
body = 'Your Batch Job Processed with 0 Errors'

email_text = """\
From: %s
To: %s
Subject: %s

%s
""" % (sent_from, to, subject, body)

try:
    server = smtplib.SMTP('smtp.gmail.com', 587) 
    server.ehlo()
    server.starttls() 
    server.login(gmail_user, gmail_password)
    server.sendmail(sent_from, to, email_text)
    server.close()
    print ('Email successfully sent')
except:
    print ('Error: your email did not send')