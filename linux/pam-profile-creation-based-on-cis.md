

```bash
authselect apply-changes -b --backup=password-complelex-bfore-backup.backup
authselect current
authselect create-profile bca-cp -b sssd
authselect select custom/bca-cp
authselect current
authselect enable-feature with-faillock
authselect current
authselect apply-changes

# config file
vim /etc/authselect/custom/bca-cp/system-auth
vim /etc/authselect/custom/bca-cp/password-auth

authselect apply-changes

# Modify the existing line
password requisite pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3
password requisite pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3

grep pam_pwquality.so /etc/pam.d/system-auth /etc/pam.d/password-auth

# Modify the existing line

auth required pam_faillock.so preauth silent deny=5 unlock_time=900
auth required pam_faillock.so authfail deny=5 unlock_time=900
auth required pam_faillock.so preauth silent deny=5 unlock_time=900
auth required pam_faillock.so authfail deny=5 unlock_time=900

rep -E '^\s*auth\s+required\s+pam_faillock.so\s+' /etc/pam.d/password-auth /etc/pam.d/system-auth 

# Modify the existing line

password requisite pam_pwhistory.so try_first_pass local_users_only enforce_for_root retry=3 remember=5
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=5

grep -P '^\h*password\h+(requisite|sufficient)\h+(pam_pwhistory\.so|pam_unix\.so)\h+([^#\n\r]+\h+)?remember=([5-9]|[1-9][0-9]+)\h*(\h+.*)?$' /etc/pam.d/system-auth /etc/pam.d/password-auth


```
