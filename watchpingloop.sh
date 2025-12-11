#!/bin/ash

# Fungsi untuk mengaktifkan mode pesawat
enable_airplane_mode() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Mengaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode enable
    adb shell settings put global airplane_mode_on 1
    adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Fungsi untuk menonaktifkan mode pesawat
disable_airplane_mode() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode disable
    adb shell settings put global airplane_mode_on 0
    adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
}

# Alamat host yang ingin Anda ping
HOST1="alamat_host_anda_1"
HOST2="alamat_host_anda_2"
HOST3="alamat_host_anda_3"

# Interface yang ingin digunakan untuk ping (bisa diubah manual)
INTERFACE="usb0"

# Variabel untuk menghitung berapa kali ping gagal
failed_count=0

# Jumlah kegagalan ping berturut-turut yang memicu mode pesawat
pingfail=3

# Waktu tunggu (detik) sebelum menonaktifkan mode pesawat
WAIT_TIME=3

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    # Ping ketiga host
    PING_RESULT1=$(ping -I "$INTERFACE" -c 1 "$HOST1" 2>&1)
    PING_RESULT2=$(ping -I "$INTERFACE" -c 1 "$HOST2" 2>&1)
    PING_RESULT3=$(ping -I "$INTERFACE" -c 1 "$HOST3" 2>&1)

    # Cek apakah minimal satu host berhasil dijangkau
    if echo "$PING_RESULT1" | grep "time=" > /dev/null; then
        PING_TIME=$(echo "$PING_RESULT1" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host1 ($HOST1) dapat dijangkau melalui $INTERFACE. Waktu ping: ${PING_TIME} ms"
        failed_count=0
    elif echo "$PING_RESULT2" | grep "time=" > /dev/null; then
        PING_TIME=$(echo "$PING_RESULT2" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host2 ($HOST2) dapat dijangkau melalui $INTERFACE. Waktu ping: ${PING_TIME} ms"
        failed_count=0
    elif echo "$PING_RESULT3" | grep "time=" > /dev/null; then
        PING_TIME=$(echo "$PING_RESULT3" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host3 ($HOST3) dapat dijangkau melalui $INTERFACE. Waktu ping: ${PING_TIME} ms"
        failed_count=0
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Semua host (Host1, Host2, Host3) tidak dapat dijangkau melalui $INTERFACE."
        failed_count=$((failed_count + 1))
        if [ $failed_count -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Gagal ping ke semua host sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode
            sleep $WAIT_TIME
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat kembali..."
            disable_airplane_mode
            failed_count=0
        fi
    fi

    sleep 1
done
