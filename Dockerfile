# Dockerfile for the PDC's Composer (a.k.a. Hub) service
#
#
# Composer for aggregate data queries. Links to ComposerDb.
#
# Example:
# sudo docker pull pdcbc/composer
# sudo docker run -d --name=composer -h composer --restart=always \
#   --link composerdb:database \
#   -p 2774:22 \
#   -p 3002:3002 \
#   -v /pdc/config/composer:/config:rw \
#   -v /pdc/config/composer_keys:/etc/ssh:rw \
#   healthdatacoalition/composer
#
# Linked containers
# - Mongo database:  --link composerdb:database
#
# External ports
# - AutoSSH:         -p <hostPort>:22
# - Web UI:          -p <hostPort>:3002
#
# Folder paths
# - authorized_keys: -v </path/>:/home/autossh/.ssh/:ro
# - SSH keys:        -v </path/>:/etc/ssh/:rw
#
#
FROM phusion/passenger-ruby19
MAINTAINER derek.roberts@gmail.com


# Environment variables
#
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive


# Keep outgoing (admin tunnel) connections from timing out
#
RUN ( \
      echo ""; \
      echo "# Keep connections alive, 60 second interval"; \
      echo "# "; \
      echo "Host *"; \
      echo "ServerAliveInterval 60"; \
  ) | tee -a /etc/ssh/ssh_config


# Enable ssh and create user for autossh tunnel
#
RUN adduser --quiet --disabled-password --home /home/autossh autossh 2>&1; \
    rm -f /etc/service/sshd/down; \
    sed -i 's/^#AuthorizedKeysFile.*/AuthorizedKeysFile\t\/config\/authorized_keys/' \
      /etc/ssh/sshd_config


# Prepare /app/ folder
#
WORKDIR /app/
COPY . .
RUN sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml; \
    chown -R app:app /app/; \
    /sbin/setuser app bundle install --path vendor/bundle; \
    cd /app/util/demographicsImporter/; \
    npm install mongodb -g; \
    npm link mongodb


# Create startup script and make it executable
#
RUN SRV=rails; \
    mkdir -p /etc/service/${SRV}/; \
    ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo ""; \
      echo "# Start service"; \
      echo "#"; \
      echo "cd /app/"; \
      echo "exec /sbin/setuser app bundle exec rails server -p 3002"; \
    )  \
      >> /etc/service/${SRV}/run; \
    chmod +x /etc/service/${SRV}/run


# Support script for delayed_job and ssh-keygen
#
RUN SRV=support; \
    mkdir -p /etc/service/${SRV}/; \
    ( \
      echo '#!/bin/bash'; \
      echo ''; \
      echo ''; \
      echo '# Create RSA key if not present'; \
      echo 'if [ ! -s /config/ssh_host_rsa_key ]'; \
      echo 'then'; \
      echo '  ssh-keygen -b 4096 -t rsa -f /config/ssh_host_rsa_key -q -N ""'; \
      echo 'fi'; \
      echo ''; \
      echo ''; \
      echo '# Start delayed job'; \
      echo '#'; \
      echo 'cd /app/'; \
      echo 'rm /app/tmp/pids/server.pid > /dev/null'; \
      echo 'exec /sbin/setuser app bundle exec /app/script/delayed_job run'; \
      echo '/sbin/setuser app bundle exec /app/script/delayed_job stop > /dev/null'; \
    )  \
      >> /etc/service/${SRV}/run; \
    chmod +x /etc/service/${SRV}/run


# Batch query scheduling in cron
#
RUN ( \
      echo "# Run batch queries (23 PST = 7 UTC)"; \
      echo "0 7 * * * /app/util/run_batch_queries.sh"; \
    ) \
      | crontab -


# Run Command
#
CMD ["/sbin/my_init"]


# Ports and volumes
#
EXPOSE 2774
EXPOSE 3002
#
RUN mkdir -p /config/
VOLUME /config
VOLUME /etc/ssh
