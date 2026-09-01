# ⚠️ LABORATORIO DE PRUEBAS — CÓDIGO VULNERABLE A PROPÓSITO

> ## 🛑 ESTE REPOSITORIO NO ES CÓDIGO REAL
>
> Todo el contenido de este repositorio contiene **vulnerabilidades deliberadas**.
> Existe con un único fin: verificar que el workflow de seguridad
> [`security-workflows-v2`](https://github.com/Krealo-Labs/security-workflows-v2)
> detecta lo que dice detectar.
>
> **No copies nada de aquí. No despliegues nada de aquí. No lo uses como referencia.**

---

## Para qué existe

Un escáner de seguridad que no reporta nada puede significar dos cosas: que el código está limpio, o que el escáner está roto. Sin un caso de prueba con resultado conocido de antemano, no hay forma de distinguirlas.

Este repositorio provee ese resultado conocido: cada archivo contiene fallas específicas y documentadas, y sabemos exactamente qué debe reportar cada herramienta.

## Qué contiene

| Archivo | Herramienta que lo evalúa | Fixtures |
|---|---|---|
| `infra/main.tf` | Trivy (`config`) | 7 malas configuraciones de AWS |
| `Dockerfile` | Trivy (`config`) | 8 malas prácticas de contenedor |
| `package-lock.json` | Trivy (`fs --scanners vuln`) | 4 dependencias con CVE conocido |
| `app/vuln.py` | Semgrep (`p/owasp-top-ten`) | 7 vulnerabilidades OWASP |

Cada fixture está numerado y comentado dentro de su archivo, para poder cotejar uno a uno lo detectado contra lo esperado.

### Detalle de los fixtures

**`infra/main.tf`** — S3 sin cifrado · SSH abierto a `0.0.0.0/0` · RDS pública y sin cifrar · política IAM con `Action: *` sobre `Resource: *` · EBS sin cifrado · S3 con ACL `public-read` · balanceador con listener HTTP.

**`Dockerfile`** — imagen `:latest` · `USER root` · sin `HEALTHCHECK` · secretos en `ENV` · `ADD` con URL remota · `EXPOSE 22` · `curl | bash` · `apt-get` sin fijar versiones ni limpiar caché.

**`package-lock.json`** — `lodash@4.17.15` · `minimist@1.2.0` · `axios@0.21.0` · `ejs@3.1.6`.

**`app/vuln.py`** — inyección SQL · inyección de comandos · deserialización con `pickle` · hash MD5 para contraseñas · path traversal · SSRF · TLS deshabilitado y `debug=True`.

## Cómo se usa

1. Se abre un Pull Request hacia `main`.
2. `.github/workflows/security.yml` invoca la plantilla local `security-scan-v2.yml`.
3. Se coteja lo reportado por cada job contra la tabla de fixtures esperados.
4. Se revisa que la pestaña **Security → Code scanning** muestre las cuatro categorías: `secrets`, `container-iac`, `dependencies` y `sast`.

## Nota sobre el escaneo de secretos

El workflow ejecuta TruffleHog con `--only-verified`, que reporta únicamente credenciales cuya validez fue confirmada contra el proveedor. Una credencial inventada no se reporta, por realista que sea su formato.

Es el comportamiento correcto en producción —evita falsos positivos— pero implica que este laboratorio no puede validar ese job con una credencial ficticia. Esa parte se verifica por separado.
