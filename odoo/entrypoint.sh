#!/bin/bash
set -e

# Set default values
: ${HOST:=db}
: ${PORT:=5432}
: ${USER:=odoo}
: ${PASSWORD:=odoo}

# Wait for PostgreSQL to be ready
until PGPASSWORD=$PASSWORD psql -h "$HOST" -U "$USER" -p "$PORT" -d postgres -c '\q'; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up - executing command"

# Execute Odoo
case "$1" in
    -- | odoo)
        shift
        if [[ "$*" == *"scaffold"* ]]; then
            exec /opt/odoo/odoo-bin "$@"
        else
            exec /opt/odoo/odoo-bin -c $ODOO_RC "$@"
        fi
        ;;
    -*)
        exec /opt/odoo/odoo-bin -c $ODOO_RC "$@"
        ;;
    *)
        exec "$@"
esac
