# SSH Multi-Thread Brute-Forcer

Script interactivo en Bash para realizar ataques de fuerza bruta al protocolo SSH utilizando hilos.

## Requisitos
* `sshpass` (Instalar con: `sudo apt install sshpass`)

## Uso
1. Dale permisos de ejecución:
   ```bash
   chmod +x ssh_brute.sh

 
Markdown

# SSH Multi-Thread Brute-Forcer

Script interactivo en Bash para realizar ataques de fuerza bruta al protocolo SSH utilizando hilos.

## Requisitos
* `sshpass` (Instalar con: `sudo apt install sshpass`)

## Uso
1. Dale permisos de ejecución:
   ```bash
   chmod +x ssh_brute.sh

    Ejecuta el script:
    Bash

    ./ssh_brute.sh

Ejemplo de Entrada

Al ejecutar el script, completa los campos de la siguiente manera:

    IP de la víctima: <IP>

    Usuario: <user>

    Diccionario: /usr/share/wordlists/rockyou.txt

    Hilos: 10

Características

    Multi-hilo: Control de procesos simultáneos para mayor velocidad.

    Interactivo: Solicita datos dinámicamente.

    Auto-Stop: Mata todos los hilos al encontrar la contraseña válida.
