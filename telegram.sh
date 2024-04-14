#!/bin/bash

# Directorio para guardar los archivos de notas
notes_dir="$HOME/.notes"

# Crea el directorio si no existe
mkdir -p "$notes_dir"

# Comprobando si se pasa el argumento para abrir la configuración web
if [[ "$1" == "-f" ]]; then
    # Abre la URL de configuración en el navegador predeterminado
    xdg-open "https://notes.guzman-lopez.com/setting"
    exit 0
fi

# Comprobando si se pasa un mensaje directamente
if [[ "$1" == "-m" ]] && [[ "$2" != "" ]]; then
    mensaje="$2"
    filename="$(date +'%Y-%m-%d_%H-%M-%S').txt"
    tempfile="$notes_dir/$filename"
    echo "$mensaje" > "$tempfile"
else
    # Nombre de archivo con fecha y hora
    filename="$(date +'%Y-%m-%d_%H-%M-%S').txt"
    tempfile="$notes_dir/$filename"
    # Abre nvim para que el usuario escriba el mensaje
    nvim "$tempfile"
    # Lee el mensaje guardado en el archivo
    mensaje=$(cat "$tempfile")
fi

# Si el archivo está vacío, no hacer nada
if [[ ! -s "$tempfile" ]]; then
    echo "No se escribió ningún mensaje. No se enviará nada."
    exit 0
fi

# Función para verificar la conexión a internet y enviar el mensaje
function check_and_send {
    # Ping a google.com para verificar la conexión a internet
    until ping -c 1 google.com > /dev/null 2>&1; do
        echo "No hay conexión a Internet. Reintentando en 2 minutos..."
        sleep 120  # Espera 2 minutos
    done

    # Envía el mensaje una vez que hay conexión
    curl -s -X POST "https://api.telegram.org/bot$TOKEN_telegram/sendMessage" -d chat_id="$TOKEN_USER_telegram" -d text="$mensaje"
    echo "Mensaje enviado exitosamente."
}
# Llama a la función en segundo plano
check_and_send &

