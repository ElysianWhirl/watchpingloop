#!/bin/ash

# ADB device ID untuk masing-masing antarmuka
ADB_ID_USB0="DEVICE_ID_USB0"  # Ganti dengan ID ADB dari perangkat usb0
ADB_ID_USB1="DEVICE_ID_USB1"  # Ganti dengan ID ADB dari perangkat usb1

# Fungsi untuk mengaktifkan mode pesawat pada perangkat dengan ID ADB tertentu
enable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Mengaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s $adb_id shell cmd connectivity airplane-mode enable
    adb -s $adb_id shell settings put global airplane_mode_on 1
    adb -s $adb_id shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk menonaktifkan mode pesawat pada perangkat dengan ID ADB tertentu
disable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s $adb_id shell cmd connectivity airplane-mode disable
    adb -s $adb_id shell settings put global airplane_mode_on 0
    adb -s $adb_id shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Alamat host yang ingin Anda ping
HOST1="YOUR_HOST1"
HOST2="YOUR_HOST2"

# Variabel untuk menghitung berapa kali ping gagal
failed_count_usb0=0
failed_count_usb1=0

# Jumlah kegagalan ping berturut-turut sebelum mengaktifkan mode pesawat
pingfail=3

# Waktu tunggu (detik) sebelum menonaktifkan mode pesawat setelah mengaktifkannya
WAIT_TIME=5
INTERVAL=3
PING_TIMEOUT=2  # Timeout dalam detik untuk setiap ping

# Fungsi untuk memeriksa konektivitas ke host tertentu melalui antarmuka tertentu
check_host() {
    local host=$1
    local interface=$2
    PING_RESULT=$(ping -I $interface -c 1 -W $PING_TIMEOUT $host 2>&1)
    if echo "$PING_RESULT" | grep "time=" > /dev/null; then
        PING_TIME=$(echo "$PING_RESULT" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host dapat dijangkau melalui $interface. Waktu ping: ${PING_TIME} ms"
        return 0  # Host dapat dijangkau
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host tidak dapat dijangkau melalui $interface."
        return 1  # Host tidak dapat dijangkau
    fi
}

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    # Cek konektivitas untuk usb0
    check_host $HOST1 usb0
    HOST1_USB0=$?
    check_host $HOST2 usb0
    HOST2_USB0=$?

    if [ $HOST1_USB0 -eq 1 ] && [ $HOST2_USB0 -eq 1 ]; then
        failed_count_usb0=$((failed_count_usb0 + 1))
        echo "$(date +"%Y-%m-%d %H:%M:%S") - usb0: Kedua host tidak dapat dijangkau."
        if [ $failed_count_usb0 -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - usb0: Gagal ping sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode $ADB_ID_USB0
            sleep $WAIT_TIME
            disable_airplane_mode $ADB_ID_USB0
            failed_count_usb0=0
        fi
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - usb0: Salah satu host dapat dijangkau. Tidak perlu mengaktifkan mode pesawat."
        failed_count_usb0=0
    fi

    # Cek konektivitas untuk usb1
    check_host $HOST1 usb1
    HOST1_USB1=$?
    check_host $HOST2 usb1
    HOST2_USB1=$?

    if [ $HOST1_USB1 -eq 1 ] && [ $HOST2_USB1 -eq 1 ]; then
        failed_count_usb1=$((failed_count_usb1 + 1))
        echo "$(date +"%Y-%m-%d %H:%M:%S") - usb1: Kedua host tidak dapat dijangkau."
        if [ $failed_count_usb1 -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - usb1: Gagal ping sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode $ADB_ID_USB1
            sleep $WAIT_TIME
            disable_airplane_mode $ADB_ID_USB1
            failed_count_usb1=0
        fi
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - usb1: Salah satu host dapat dijangkau. Tidak perlu mengaktifkan mode pesawat."
        failed_count_usb1=0
    fi

    sleep $INTERVAL
done
