#!/bin/ash

# Daftar interface dan ADB ID yang akan dipantau
INTERFACES="usb0 usb1"  # Tambahkan interface lain jika diperlukan
ADB_IDS="S5PRO20200023315 DEVICE_ID_USB1"  # Sesuaikan dengan ID ADB masing-masing

# Alamat host yang ingin Anda ping
HOST1="104.18.214.235"
HOST2="104.17.3.81"

# Variabel untuk menghitung jumlah kegagalan ping per interface
touch /tmp/failed_count

# Jumlah kegagalan ping berturut-turut sebelum mengaktifkan mode pesawat
PINGFAIL=3

# Waktu tunggu (detik) sebelum menonaktifkan mode pesawat setelah mengaktifkannya
WAIT_TIME=5
INTERVAL=1
PING_TIMEOUT=1  # Timeout dalam detik untuk setiap ping

# Fungsi untuk mengaktifkan mode pesawat
enable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Mengaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s $adb_id shell cmd connectivity airplane-mode enable
    adb -s $adb_id shell settings put global airplane_mode_on 1
    adb -s $adb_id shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk menonaktifkan mode pesawat
disable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s $adb_id shell cmd connectivity airplane-mode disable
    adb -s $adb_id shell settings put global airplane_mode_on 0
    adb -s $adb_id shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk memeriksa konektivitas
check_host_from_interface() {
    local host=$1
    local interface=$2

    if ip link show $interface > /dev/null 2>&1; then
        PING_RESULT=$(ping -I $interface -c 1 -W $PING_TIMEOUT $host 2>&1)
        if echo "$PING_RESULT" | grep "time=" > /dev/null; then
            PING_TIME=$(echo "$PING_RESULT" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host dapat dijangkau melalui $interface. Waktu ping: ${PING_TIME} ms"
            return 0
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host tidak dapat dijangkau melalui $interface."
            return 1
        fi
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Interface $interface tidak tersedia."
        return 2
    fi
}

# Loop utama
while true; do
    index=1
    for interface in $INTERFACES; do
        adb_id=$(echo $ADB_IDS | awk -v i=$index '{print $i}')
        index=$((index + 1))

        check_host_from_interface $HOST1 $interface
        HOST1_RESULT=$?
        check_host_from_interface $HOST2 $interface
        HOST2_RESULT=$?

        FAILED_COUNT=$(grep "^$interface " /tmp/failed_count | awk '{print $2}')
        [ -z "$FAILED_COUNT" ] && FAILED_COUNT=0

        if [ $HOST1_RESULT -eq 2 ] || [ $HOST2_RESULT -eq 2 ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Melewatkan pengecekan karena interface tidak tersedia."
        elif [ $HOST1_RESULT -eq 1 ] && [ $HOST2_RESULT -eq 1 ]; then
            FAILED_COUNT=$((FAILED_COUNT + 1))
            echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Kedua host tidak dapat dijangkau."
            if [ $FAILED_COUNT -ge $PINGFAIL ]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Gagal ping sebanyak $PINGFAIL kali. Mengaktifkan mode pesawat..."
                enable_airplane_mode $adb_id
                sleep $WAIT_TIME
                disable_airplane_mode $adb_id
                FAILED_COUNT=0
            fi
        else
            FAILED_COUNT=0
        fi

        sed -i "/^$interface /d" /tmp/failed_count
        echo "$interface $FAILED_COUNT" >> /tmp/failed_count
    done
    sleep $INTERVAL
done
