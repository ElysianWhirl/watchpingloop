#!/bin/sh

# Daftar interface dan ADB ID yang akan dipantau
INTERFACES="usb0 usb1 usb2"
ADB_IDS="DEVICE_ID_USB0 DEVICE_ID_USB1 DEVICE_ID_USB2"

# Alamat host yang ingin Anda ping
HOST1="host_1"
HOST2="host_2"

# Jumlah kegagalan ping berturut-turut sebelum mengaktifkan mode pesawat
PINGFAIL=5
WAIT_TIME=5
INTERVAL=3
PING_TIMEOUT=5

# Inisialisasi variabel counter dalam memori (array-like using eval)
for iface in $INTERFACES; do
    eval "failed_$iface=0"
done

# Fungsi untuk mengaktifkan mode pesawat
enable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Mengaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s "$adb_id" shell cmd connectivity airplane-mode enable
    adb -s "$adb_id" shell settings put global airplane_mode_on 1
    adb -s "$adb_id" shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk menonaktifkan mode pesawat
disable_airplane_mode() {
    local adb_id=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat untuk perangkat $adb_id..."
    adb -s "$adb_id" shell cmd connectivity airplane-mode disable
    adb -s "$adb_id" shell settings put global airplane_mode_on 0
    adb -s "$adb_id" shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk memeriksa konektivitas
check_host_from_interface() {
    local host=$1
    local interface=$2

    if ip link show "$interface" > /dev/null 2>&1; then
        PING_RESULT=$(ping -I "$interface" -c 1 -W "$PING_TIMEOUT" "$host" 2>&1)
        if echo "$PING_RESULT" | grep -q "time="; then
            PING_TIME=$(echo "$PING_RESULT" | sed -n 's/.*time=\([0-9.]*\) ms.*/\1/p')
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
        adb_id=$(echo "$ADB_IDS" | awk -v i="$index" '{print $i}')
        index=$((index + 1))

        check_host_from_interface "$HOST1" "$interface"
        HOST1_RESULT=$?
        check_host_from_interface "$HOST2" "$interface"
        HOST2_RESULT=$?

        # Ambil nilai failed count dari variabel dinamis
        eval "current_fail=\$failed_$interface"

        if [ "$HOST1_RESULT" -eq 2 ] || [ "$HOST2_RESULT" -eq 2 ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Melewatkan karena interface tidak tersedia."
            # Reset counter jika interface mati? Opsional. Di sini kita reset.
            current_fail=0
        elif [ "$HOST1_RESULT" -eq 1 ] && [ "$HOST2_RESULT" -eq 1 ]; then
            current_fail=$((current_fail + 1))
            echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Kedua host gagal dijangkau. Gagal ke-$current_fail."
            if [ "$current_fail" -ge "$PINGFAIL" ]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S") - $interface: Mencapai $PINGFAIL kegagalan. Toggle airplane mode..."
                enable_airplane_mode "$adb_id"
                sleep "$WAIT_TIME"
                disable_airplane_mode "$adb_id"
                current_fail=0
            fi
        else
            current_fail=0
        fi

        # Simpan kembali ke variabel dinamis
        eval "failed_$interface=$current_fail"
    done
    sleep "$INTERVAL"
done
