If want to configure the GitLab Runner service without needing superuser (SU) privileges. Here's a step-by-step guide based on the instructions you provided:

1. **Disable execution privileges for the su binary**: This step ensures that the su command cannot be executed, thereby preventing the GitLab Runner script from using SU privileges.
   ```bash
   sudo chmod -x /usr/bin/su
   ```

2. **Ensure execution privileges for the su command are revoked**: Verify that the su command indeed doesn't have execution privileges.
   ```bash
   sudo ls -la /usr/bin/su
   ```

3. **Update ownership of GitLab Runner configuration files**: This ensures that the GitLab Runner user owns its configuration files.
   ```bash
   sudo chown -R gitlab-runner:gitlab-runner /etc/gitlab-runner/
   ```

4. **Adjust ownership of GitLab Runner home directory**: Similarly, update ownership of the GitLab Runner home directory.
   ```bash
   sudo chown -R gitlab-runner:gitlab-runner /home/gitlab-runner/
   ```

5. **Reload systemd manager configuration**: This step ensures that systemd recognizes the changes made to the GitLab Runner configuration.
   ```bash
   sudo systemctl daemon-reload
   ```

6. **Restart GitLab Runner service to apply changes**: Restart the GitLab Runner service to apply the ownership changes made.
   ```bash
   sudo systemctl restart gitlab-runner.service
   ```

7. **Check the GitLab Runner service**: Verify that the GitLab Runner service is running as expected.
   ```bash
   sudo systemctl status gitlab-runner.service
   ```

By following these steps, you should be able to configure the GitLab Runner service without needing superuser privileges. Remember to replace "gitlab-runner" with the appropriate username if you're using a different one.
