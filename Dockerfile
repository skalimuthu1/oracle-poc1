# Oracle Database Free 23c (gvenzl) base image
FROM gvenzl/oracle-free:latest

# 1) Set SYS/SYSTEM/PDBADMIN password for first startup (dev only)
ENV ORACLE_PASSWORD=app_123

# 2) Auto-create an application user
ENV APP_USER=APP
ENV APP_USER_PASSWORD=app_123


# 3) Copy init scripts (executed automatically in lexicographic order)
COPY --chown=oracle:dba init/ /docker-entrypoint-initdb.d/
