import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication

import yaml

from bitbucket_pipes_toolkit import Pipe, get_variable, get_logger


logger = get_logger()


class NotValidVariable(Exception):
    pass


DEFAULT_SMTP_PORT = 587
DEFAULT_TIMEOUT = '10'
SMTP_OK_STATUS_CODE = 250
STANDARD_SMTP_PORTS = (25, 465, 587, 2525)

DEFAULT_TEXT_REPOSITORY = "Bitbucket Pipe Notification"
DEFAULT_TEXT_MESSAGE = "Email sent from Bitbucket Pipeline"
BASE_SUCCESS_MESSAGE = 'The mail has been sent successfully'
BASE_FAILED_MESSAGE = 'Failed to send email'

schema = {
    'USERNAME': {'type': 'string', 'required': True},
    'PASSWORD': {'type': 'string', 'required': True},
    'FROM': {'type': 'string', 'required': True},
    'TO': {'type': 'string', 'required': True},
    'BODY_PLAIN': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
    'BODY_HTML': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
    'SUBJECT': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
    'ATTACHMENTS': {'type': 'string', 'required': False, 'nullable': True, 'default': None},
    'HOST': {'type': 'string', 'required': True},
    'PORT': {'type': 'integer', 'required': False, 'default': DEFAULT_SMTP_PORT},
    'TLS': {'type': 'boolean', 'required': False, 'default': True},
    'DEBUG': {'type': 'boolean', 'required': False, 'default': False}
}


class EmailNotify(Pipe):

    def add_attachments(self, message, attachments=None):
        for attachment in attachments or []:
            base_name = os.path.basename(attachment)
            try:
                with open(attachment, "rb") as f:
                    part = MIMEApplication(
                        f.read(),
                        Name=base_name
                    )
                part['Content-Disposition'] = f'attachment; filename="{base_name}"'
                message.attach(part)
            except FileNotFoundError:
                self.fail(f'Failed to add an attachment. No such file {base_name}')

    def run(self):
        super().run()
        username = self.get_variable('USERNAME')
        password = self.get_variable('PASSWORD')
        from_email = self.get_variable('FROM')
        to_email = self.get_variable('TO')
        host = self.get_variable('HOST')
        attachments = self.get_variable('ATTACHMENTS')

        port = self.get_variable('PORT')
        use_tls = self.get_variable('TLS')

        if port not in STANDARD_SMTP_PORTS:
            logger.warning((
                f'Non standard SMTP PORT using: {port}. '
                f'SMTP standard ports are '
                f'{(", ".join(str(i) for i in STANDARD_SMTP_PORTS))}.'
            ))

        debug = self.get_variable('DEBUG')
        timeout = get_variable('TIMEOUT', default=DEFAULT_TIMEOUT)

        if timeout is not None and is_valid_timeout(timeout):
            timeout = float(timeout)

        workspace = get_variable('BITBUCKET_WORKSPACE', default='local')
        repo = get_variable('BITBUCKET_REPO_SLUG', default='local')
        build = get_variable('BITBUCKET_BUILD_NUMBER', default='local')
        branch = get_variable('BITBUCKET_BRANCH', default='local')

        default_subject = (
            f'{DEFAULT_TEXT_REPOSITORY}'
            f'{(f" for {branch}" if branch != "local" else f"")}'
        )
        subject = self.get_variable('SUBJECT') or default_subject

        default_body_plain = (
            f"{DEFAULT_TEXT_MESSAGE} "
            f"<a href='https://bitbucket.org/{workspace}/{repo}"
            f"/addon/pipelines/home#!/results/{build}'>build #{build}</a>"
        )

        body_plain = self.get_variable('BODY_PLAIN') or default_body_plain
        body_html_filename = self.get_variable('BODY_HTML')
        body_html = body_plain

        if body_html_filename is not None:
            try:
                with open(body_html_filename, 'r') as f:
                    body_html = f.read()
            except FileNotFoundError as e:
                self.fail(message=f'{BASE_FAILED_MESSAGE}: {str(e)}')

        # create a message
        msg = MIMEMultipart('alternative')
        msg['FROM'] = from_email
        msg['TO'] = to_email
        msg['Subject'] = subject

        # send both html and text
        part1 = MIMEText(body_plain, 'plain', _charset='utf-8')
        part2 = MIMEText(body_html, 'html', _charset='utf-8')

        msg.attach(part1)
        msg.attach(part2)

        if attachments is not None:
            self.add_attachments(msg, attachments.split(','))

        logger.info('Sending email...')

        result = None

        try:
            smtp = smtplib.SMTP(host, port, timeout=timeout)
            smtp.set_debuglevel(debug)
            smtp.ehlo()
            if use_tls:
                smtp.starttls()
                smtp.ehlo()
            smtp.login(username, password)
            smtp.send_message(msg)
            result = smtp.noop()
            smtp.quit()
        # connection error or timeout
        except OSError as e:
            self.fail(message=(
                f'{BASE_FAILED_MESSAGE} to {to_email}. '
                f'Check your configuration settings'
                f'{(f": {e}" if debug else f".")}'
            ))

        if result is None or result[0] != SMTP_OK_STATUS_CODE:
            self.fail(message=(
                f'{BASE_FAILED_MESSAGE} to {to_email}. '
                f'{(f": response {result}" if debug else f".")}'
            ))

        self.success(message=f'{BASE_SUCCESS_MESSAGE} to {to_email}')


def is_valid_timeout(str_value):
    if is_positive_number(str_value):
        return True
    else:
        raise NotValidVariable(
            'Wrong TIMEOUT value. '
            'TIMEOUT must be greater than 0.')


def is_positive_number(str_value):
    try:
        return float(str_value) > 0
    except ValueError:
        return False


if __name__ == '__main__':
    with open('/pipe.yml', 'r') as metadata_file:
        metadata = yaml.safe_load(metadata_file.read())
    pipe = EmailNotify(pipe_metadata=metadata, schema=schema, check_for_newer_version=True)
    pipe.run()
