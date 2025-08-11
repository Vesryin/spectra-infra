FROM flyway/flyway:9.4

COPY ./sql /flyway/sql

ENV FLYWAY_LOCATIONS=filesystem:/flyway/sql
ENV FLYWAY_BASELINE_ON_MIGRATE=true
ENV FLYWAY_BASELINE_VERSION=0

ENTRYPOINT ["flyway"]
CMD ["migrate"]
