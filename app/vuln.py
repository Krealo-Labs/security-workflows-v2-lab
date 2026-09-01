"""
=============================================================================
FIXTURES VULNERABLES DELIBERADOS - NO USAR COMO REFERENCIA

Cada funcion contiene una vulnerabilidad intencional de la OWASP Top 10
para verificar que Semgrep (p/owasp-top-ten) la detecta.
Este codigo NUNCA debe ejecutarse ni desplegarse.
=============================================================================
"""

import hashlib
import os
import pickle
import sqlite3
import subprocess

import requests
from flask import Flask, request

app = Flask(__name__)


# FIXTURE 1 - Inyeccion SQL por concatenacion de strings
@app.route("/usuario")
def obtener_usuario():
    user_id = request.args.get("id")
    conexion = sqlite3.connect("app.db")
    cursor = conexion.cursor()
    consulta = "SELECT * FROM usuarios WHERE id = '" + user_id + "'"
    cursor.execute(consulta)
    return str(cursor.fetchall())


# FIXTURE 2 - Inyeccion de comandos del sistema operativo
@app.route("/ping")
def hacer_ping():
    host = request.args.get("host")
    resultado = subprocess.check_output("ping -c 1 " + host, shell=True)
    return resultado


# FIXTURE 3 - Deserializacion insegura de datos del usuario
@app.route("/sesion", methods=["POST"])
def cargar_sesion():
    datos = request.get_data()
    sesion = pickle.loads(datos)
    return str(sesion)


# FIXTURE 4 - Algoritmo de hash obsoleto para contrasenas
def guardar_contrasena(contrasena):
    hash_debil = hashlib.md5(contrasena.encode()).hexdigest()
    return hash_debil


# FIXTURE 5 - Path traversal por ruta controlada por el usuario
@app.route("/archivo")
def leer_archivo():
    nombre = request.args.get("nombre")
    ruta = os.path.join("/var/data/", nombre)
    with open(ruta, "r") as f:
        return f.read()


# FIXTURE 6 - SSRF por URL controlada por el usuario
@app.route("/proxy")
def proxy_remoto():
    url = request.args.get("url")
    respuesta = requests.get(url)
    return respuesta.text


# FIXTURE 7 - Verificacion TLS deshabilitada y modo debug en produccion
def consultar_api_interna():
    return requests.get("https://api.interna.local/datos", verify=False).json()


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
