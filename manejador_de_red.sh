#!/bin/bash

# Verificación de privilegios
if [[ $EUID -ne 0 ]]; then
   echo "Error: Se requieren privilegios de root."
   exit 1
fi

# Verificación de dependencias
if ! command -v nmcli &> /dev/null; then
    echo "Error: nmcli (NetworkManager) no está instalado."
    exit 1
fi

mostrar_interfaces() {
    echo -e "\n--- Estado de Interfaces ---"
    nmcli device status
}

cambiar_estado() {
    mostrar_interfaces
    read -p "Interfaz: " iface
    read -p "Estado [up/down]: " estado
    nmcli device "$estado" "$iface"
}

configurar_ip() {
    local tipo=$1
    local id=$2 # SSID o Interface
    local pass=$3
    local con_name="Config_$id"

    # Eliminar conexión previa si existe para evitar conflictos
    nmcli connection delete "$con_name" &> /dev/null

    read -p "¿DHCP o Estática? [d/e]: " modo
    if [[ "$modo" == "e" ]]; then
        read -p "IP/Prefijo (ej. 192.168.1.10/24): " ip
        read -p "Gateway: " gw
        read -p "DNS (ej. 8.8.8.8): " dns
        
        if [[ "$tipo" == "wifi" ]]; then
            nmcli device wifi connect "$id" password "$pass" name "$con_name" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gw" ipv4.dns "$dns"
        else
            nmcli connection add type ethernet ifname "$id" con-name "$con_name" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gw" ipv4.dns "$dns"
            nmcli connection up "$con_name"
        fi
    else
        if [[ "$tipo" == "wifi" ]]; then
            nmcli device wifi connect "$id" password "$pass" name "$con_name" ipv4.method auto
        else
            nmcli connection add type ethernet ifname "$id" con-name "$con_name" ipv4.method auto
            nmcli connection up "$con_name"
        fi
    fi
}

conectar() {
    mostrar_interfaces
    read -p "Interfaz a usar: " iface
    tipo=$(nmcli -t -f GENERAL.TYPE dev show "$iface" | head -n1 | cut -d: -f2)

    if [[ "$tipo" == "wifi" ]]; then
        nmcli device set "$iface" managed yes
        nmcli device wifi rescan
        nmcli device wifi list
        read -p "SSID: " ssid
        read -sp "Password: " pswd
        configurar_ip "wifi" "$ssid" "$pswd"
    elif [[ "$tipo" == "ethernet" ]]; then
        configurar_ip "ethernet" "$iface" ""
    fi
}

while true; do
    echo -e "\n1. Listar | 2. Estado | 3. Conectar | 4. Salir"
    read -p "Opción: " opt
    case $opt in
        1) mostrar_interfaces ;;
        2) cambiar_estado ;;
        3) conectar ;;
        4) exit 0 ;;
    esac
done

