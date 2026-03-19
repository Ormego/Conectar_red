Manejador de red (Bash)

Script interactivo para la gestión de redes en sistemas Linux mediante NetworkManager.
Requisitos

NetworkManager instalado y activo.

Privilegios de sudo.

Funcionalidades

Diagnóstico: Muestra el estado actual de los dispositivos.

Control de Enlace: Cambia el estado (UP/DOWN) de las interfaces.

Conexión WiFi: Escaneo en tiempo real y soporte para múltiples cifrados.

Configuración Dual: Soporta direccionamiento IPv4 estático y dinámico (DHCP).

Persistencia: Las configuraciones se guardan como perfiles de nmcli.

Uso
Bash

chmod +x manejador_de_red.sh
sudo ./manejador_de_red.sh
