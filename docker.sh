exec docker run $docker_run_args -u root --name $_container_name $_image_name /bin/bash -c "
    set -e
    groupadd -f -g $(id -g) $(id -g -n)
    id $(whoami) 2>/dev/null || useradd -M -d /tmp -u $(id -u) -g $(id -g) $(whoami)
    groupadd -f sudo-without-passwd
    gpasswd -a $(whoami) sudo-without-passwd
    gpasswd -a $(whoami) root 2>/dev/null || :
    echo %sudo-without-passwd ALL=\(ALL:ALL\) NOPASSWD: ALL >> /etc/sudoers    
    
    echo /lib64 >> /etc/ld.so.conf.d/zz_local_anaconda.conf
    echo /usr/lib64 >> /etc/ld.so.conf.d/zz_local_anaconda.conf
    echo /lib >> /etc/ld.so.conf.d/zz_local_anaconda.conf
    echo /usr/lib >> /etc/ld.so.conf.d/zz_local_anaconda.conf
    echo /tools/python3.10/$(uname -m)/lib >> /etc/ld.so.conf.d/zz_local_anaconda.conf
    ldconfig 2>/dev/null || :
    
    #    export PATH=/tools/test_platform/sccache/sccache_0.2.15-2/\$(uname -m)/\$(cat /etc/os-release|grep -E '^(ID|VERSION_ID)=' | sort | awk -F '=' '{ print \$NF }' | xargs | tr -d ' '):\$PATH 
    
    mkdir -p /var/log && touch /var/log/command.log && chmod 666 /var/log/command.log
    sed -r -i /ENV_PATH/d /etc/login.defs
    sed -r -i /ENV_SUPATH/d /etc/login.defs
    echo ENV_PATH PATH=\$PATH >> /etc/login.defs
    echo ENV_SUPATH PATH=\$PATH >> /etc/login.defs    
    
    if [ -f \"/etc/bash.bashrc\" ]; then
      cat >> /etc/bash.bashrc << EOF
        new_path=\"\$PATH\"
        if [ \"\\\$PATH\" = \"\\\${PATH/\\\$new_path/}\" ]; then
          export PATH=\$PATH:\\\$PATH
        fi
EOF
    fi    
    
    if [ x$kick_docker_config_ass_hole = x1 ]; then
      rmdir -p --ignore-fail-on-non-empty $_TARGET_DIR 2>/dev/null || :
#      rm -vf $_TARGET_DIR || rmdir -v $_TARGET_DIR || :
      ln -sfvT $_source_dir $_TARGET_DIR
      # use 'su -P' could change work directoy, however, ubuntu16.04 does not support it
    else
      cd $_TARGET_DIR
    fi
    
#    su -p $(whoami) -c \"
#    set -x
#      echo \$PATH
#      echo \\\$PATH
#      SCCACHE_NO_DAEMON=1 SCCACHE_START_SERVER=1 sccache &
#    \"
    echo alias ls=\'ls --color\' >> /etc/bash.bashrc
    echo alias ll=\'ls -l\' >> /etc/bash.bashrc
    echo alias la=\'ls -a -l\' >> /etc/bash.bashrc
    echo echo $_container_name > /bin/myname && chmod +x /bin/myname    
    
    su >/dev/null 2>&1 -P -c \\\"echo\\\" || su_pty_not_work=1    
    
    if [ -z \"$_cmd\" ]; then
      if [ x\$su_pty_not_work = x1 ]; then
        exec su -p $(whoami)
      else
        # su -P works for ubuntu20.04, but not work as expected in others (CTRL-C will terminate shell directly)
        exec su -p $(whoami) --session-command \"
          cd $_TARGET_DIR
          exec \\\$SHELL
        \"
      fi
    else
      su -p $(whoami) -c \"
        set -e
        cd $_TARGET_DIR
        time $_cmd
      \"
    fi
  "
