FROM odoo:19.0

# change to the root user
USER root
RUN apt-get update 
RUN apt-get install -y pkg-config libxml2-dev libxmlsec1-dev libxmlsec1-openssl python3-pip python3-qrcode git nano
RUN apt-get install -y gcc python3-dev
RUN apt-get install -y python3-wheel
RUN apt-get install -y iputils-ping

RUN chown odoo:odoo /etc/odoo/odoo.conf
RUN pip3 install --break-system-packages pdf2image

USER odoo
