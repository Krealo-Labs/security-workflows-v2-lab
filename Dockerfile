# =============================================================================
# FIXTURES VULNERABLES DELIBERADOS - NO USAR COMO REFERENCIA
#
# Cada instruccion marcada contiene una mala practica intencional para
# verificar que Trivy (scan-type: config) la detecta.
# Esta imagen NUNCA debe construirse ni desplegarse.
# =============================================================================

# FIXTURE 1 - Imagen base sin version fijada
FROM ubuntu:latest

# FIXTURE 2 - Contenedor corriendo como superusuario
USER root

# FIXTURE 4 - Secreto embebido en la imagen
ENV AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
ENV DB_PASSWORD="SuperSecreto123"

# FIXTURE 8 - Instalacion sin fijar versiones ni limpiar la cache de apt
RUN apt-get update && apt-get install -y \
    curl \
    openssh-server \
    sudo

# FIXTURE 7 - Descarga y ejecucion de un script remoto sin verificar
RUN curl -sSL http://example.com/install.sh | bash

# FIXTURE 5 - ADD con URL remota en lugar de COPY
ADD https://example.com/app.tar.gz /opt/app.tar.gz

COPY app/ /opt/app/

# FIXTURE 6 - Puerto SSH expuesto desde el contenedor
EXPOSE 22
EXPOSE 8080

# FIXTURE 3 - Sin instruccion HEALTHCHECK

CMD ["python3", "/opt/app/vuln.py"]
