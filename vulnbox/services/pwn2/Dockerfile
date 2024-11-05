FROM pwn.red/jail
COPY --from=ubuntu / /srv
COPY main /srv/app/run
RUN touch /tmp/main.db
RUN chmod 777 /tmp/main.db

EXPOSE 5501
ENV JAIL_PORT=5501