# Email Notify

Send email with a specific message.

Note: We recommend using the pipe with your own email server or third-party providers that support massive email notifications (Sendgrid, AWS SES, ...). Some free accounts from vendors such as Gmail or Outlook have special policies about security and rate limiting that could affect configuring and using the pipe. Make sure you read about it and understand their policies before using them.

Note: Google accounts will not be supported with less secure apps according to [Google changes for less secure apps](https://support.google.com/accounts/answer/6010255?hl=en#more-secure-apps-how). To make this pipe work with Google accounts its necessary to set up [Google app password](https://support.google.com/mail/answer/185833?hl=en-GB).

## YAML Definition

Add the following snippet to the after-script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: atlassian/email-notify:0.8.0
  variables:
    USERNAME: '<string>'
    PASSWORD: '<string>'
    FROM: '<string>'
    TO: '<string>'
    HOST: '<string>'
    # PORT: '<string>' # Optional.
    # TLS: '<boolean>' # Optional.
    # SUBJECT: '<string>' # Optional.
    # BODY_PLAIN: '<string>' # Optional.
    # BODY_HTML: '<string>' # Optional.
    # ATTACHMENTS: '<string>' # Optional.
    # DEBUG: '<boolean>' # Optional.
```


## Variables

| Variable      | Usage                                                                                                                                                                                                                                                                                    |
|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| USERNAME (**) | The username to authenticate with.                                                                                                                                                                                                                                                       |
| PASSWORD (**) | The password to authenticate with.                                                                                                                                                                                                                                                       |
| FROM (**)     | The email address to send email from.                                                                                                                                                                                                                                                    |
| TO (**)       | The email address to send email to.                                                                                                                                                                                                                                                      |
| HOST (**)     | The remote host with SMTP server to connect to.                                                                                                                                                                                                                                          |
| PORT          | The port of the remote host with SMTP server to connect to. Default: `587`                                                                                                                                                                                                               |
| TLS           | Put the SMTP connection in TLS (Transport Layer Security) mode. Default: `true`                                                                                                                                                                                                          |
| SUBJECT       | The subject of the email. Default: `Bitbucket Pipe Notification for ${BITBUCKET_BRANCH}`.                                                                                                                                                                                                |
| BODY_PLAIN    | Text that stored in the body part of the email as 'plain' text. Default: `Email send from Bitbucket Pipeline <a href='https://bitbucket.org/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}/addon/pipelines/home#!/results/${BITBUCKET_BUILD_NUMBER}'>build#${BITBUCKET_BUILD_NUMBER}</a>` |
| BODY_HTML     | The name of file with html content that will be in the body part of the email as 'html'. This requires a template file to be present in your repository.                                                                                                                                 |
| ATTACHMENTS   | A list of comma separated file names to send as attachments.                                                                                                                                                                                                                             |
| DEBUG         | Turn on extra debug information. Default: `false`.                                                                                                                                                                                                                                       |

_(*) = required variable._
_(**) = required variable. If this variable is configured as a repository, account or environment variable, it doesnâ€™t need to be declared in the pipe as it will be taken from the context. It can still be overridden when using the pipe._


## Details

Pipe email-notify connects to SMTP server provided in HOST variable.
You can use default configuration of the pipe email-notify or customize it with your own text, attachments.


## Prerequisites

To use email-notify you need to choose your favorite SMTP server:
- [SendGrid](https://sendgrid.com/solutions/smtp-service/)
- [SendPulse](https://sendpulse.com/integrations/api/smtp)
- [Amazon SES](https://aws.amazon.com/ses/)
- [Google](https://support.google.com/a/answer/176600?hl=en)
- [Microsoft](https://support.office.com/en-us/article/pop-imap-and-smtp-settings-for-outlook-com-d088b986-291d-42b8-9564-9c414e2aa040)
- [Yahoo](https://help.yahoo.com/kb/SLN4724.html)


## Examples

### Basic example:

Example sending email:

```yaml
script:
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example@example.com'
      HOST: 'smtp.gmail.com'
```

Example sending to multiple recipients:

```yaml
script:
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example1@example.com, example2@example.com, example3@example.com'
      HOST: 'smtp.gmail.com'
```

### Advanced examples:
Here we pass extra arguments to the email-notify command to use custom email's subject and enable extra debugging:

```yaml
script:
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example@example.com'
      HOST: 'smtp.gmail.com'
      PORT: 587
      SUBJECT: 'Bitbucket Pipe Notification for your-bitbucket-brunch'
      DEBUG: true
```

Example with alternate email's body with html template from the file and usage in `after-script` part of pipelines:

```yaml
after-script:
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example@example.com'
      HOST: 'smtp.gmail.com'
      PORT: 587
      BODY_HTML: 'email_template.html'
```

Example sending attachments:

```
script:
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example@example.com'
      HOST: 'smtp.gmail.com'
      ATTACHMENTS: 'file1.txt,file2.txt'
 
```

Example sending notification with a build status. $BITBUCKET_EXIT_CODE is an [environment variables in the build container][variables and secrets]:

```
after-script:
  - ALERT_TYPE="success"
  - if [[ $BITBUCKET_EXIT_CODE -ne 0 ]]; then ALERT_TYPE="error" ; fi
  - pipe: atlassian/email-notify:0.8.0
    variables:
      USERNAME: 'myemail@example.com'
      PASSWORD: $PASSWORD
      FROM: 'myemail@example.com'
      TO: 'example1@example.com'
      HOST: 'smtp.gmail.com'
      SUBJECT: '${ALERT_TYPE}:Bitbucket Pipe Notification for ${BITBUCKET_BRANCH}'
```
