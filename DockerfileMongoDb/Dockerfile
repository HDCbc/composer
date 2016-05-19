# Dockerfile for the HDC's ComposerDb service
#
#
# Mongo database for HDC-collected aggregate data.
#
# Example:
# sudo docker pull healthDataCoalition/composerDb
# sudo docker run -d --name composerDb -h composerDb --restart=always \
#   -v /path/for/composerDb/:/data/:rw \
#   healthDataCoalition/composerDb:latest
#
#
FROM mongo:3.2
MAINTAINER derek.roberts@gmail.com


# Environment variables
#
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive


# Install cron and add it to Mongo's existing entrypoint.sh
#
RUN apt-get update; \
    apt-get install -y \
    cron; \
    rm -rf /var/lib/apt/lists/*; \
    sed -i 's/set -e/set -e\n\n\n# Start cron\nservice cron start\n/g' /entrypoint.sh


# Create Mongo maintenance script and add to cron
#
RUN SCRIPT=/mongoMaintenance.sh; \
    ( \
      echo '#!/bin/bash'; \
      echo '#'; \
      echo 'set -e -o nounset'; \
      echo ''; \
      echo ''; \
      echo '# Wait for Mongod to start (important at boot)'; \
      echo '#'; \
      echo 'sleep 30'; \
      echo ''; \
      echo ''; \
      echo '# Set indexes to prevent duplicates'; \
      echo '#'; \
      echo 'mongo query_composer_development --eval \'; \
      echo '  "db.endpoints.ensureIndex({ base_url : 1 }, { unique: true });"'; \
      echo 'mongo query_composer_development --eval \'; \
      echo '  "db.queries.ensureIndex({ title : 1 }, { unique: true });"'; \
      echo 'mongo query_composer_development --eval \'; \
      echo '  "db.users.ensureIndex({ username : 1 }, { unique: true });"'; \
      echo ''; \
      echo ''; \
      echo '# Maintenance account'; \
      echo '#'; \
      echo 'mongo query_composer_development --eval '"'"'db.users.insert({ '; \
      echo '  "first_name" : "HDC", "last_name" : "Maintenance", "username" : '; \
      echo '  "maintenance", "email" : "admin@hdcbc.ca", "encrypted_password" : '; \
      echo '  "\$2a\$10\$mWm0Lp5dcbtX1IzH2C0ayOefiAxO7ZlNCPJqFT10ZlZBQeK31PnbW", '; \
      echo '  "agree_license" : true, "approved" : true, admin : "false" '; \
      echo '});'"'"; \
      echo ''; \
      echo '# Dump DB'; \
      echo '#'; \
      echo 'mongodump --out /data/dump/'; \
    )  \
      >> ${SCRIPT}; \
    chmod +x ${SCRIPT}; \
    ( \
      echo '# Run database dump script (boot, 2 PST = 10 UTC)'; \
      echo '@reboot '${SCRIPT}; \
      echo '0 10 * * * '${SCRIPT}; \
    ) \
      | crontab -


# Volume
#
RUN mkdir -p /data/dump/
VOLUME /data/dump
