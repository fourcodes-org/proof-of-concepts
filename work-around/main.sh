#!/usr/bin/env bash

for fn   in system-auth password-auth;
do file='/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$fn' 
  if !grep '^h*passwordh+(requisite|required|sufficient)h+pam_unix.so(h+[^# r]+)?h+sha512b.$' '$file'; then 
    if '^h*passwordh+(requisite|required|sufficient)h+pam_unix.so(h+[^# r]+)?h+(md5|blowfish|bigcrypt|sha256)b.$' '$file'; then 
        sed - ri 's/(md5|blowfish|bigcrypt|sha256)/sha512/' '$file'
    else
        sed -ri 's/(^s*passwords+(requisite|required|sufficient)s+pam_unix.sos+)(.*)$/1sha512 3/' $file 
    fi 
  fi 
done

# authselect apply - changes
