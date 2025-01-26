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
HOST1="104.18.214.235"
HOST2="104.17.3.81"

# Variabel untuk menghitung berapa kali ping gagal
failed_count=0

# ping_fail_for_modpes
pingfail=3

# Waktu tunggu (detik) sebelum mengaktifkan mode pesawat setelah ping gagal
WAIT_TIME=3
INTERVAL=1

# Fungsi untuk memeriksa konektivitas ke host tertentu melalui antarmuka tertentu
check_host() {
    local host=$1
    local interface=$2
    PING_RESULT=$(ping -I $interface -c 1 $host 2>&1)
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
    check_host $HOST1 usb0
    HOST1_USB0=$?
    check_host $HOST2 usb0
    HOST2_USB0=$?
    check_host $HOST1 usb1
    HOST1_USB1=$?
    check_host $HOST2 usb1
    HOST2_USB1=$?

    if [ $HOST1_USB0 -eq 1 ] && [ $HOST2_USB1 -eq 1 ]; then
        failed_count=$((failed_count + 1))
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Kedua host tidak dapat dijangkau."
        if [ $failed_count -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Gagal ping sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode  # Jika kedua host tidak dapat dijangkau dan sudah ada $pingfail kegagalan berturut-turut, aktifkan mode pesawat
            sleep $WAIT_TIME  # Tunggu beberapa waktu sebelum menonaktifkan mode pesawat
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat kembali..."
            disable_airplane_mode  # Nonaktifkan mode pesawat kembali
            failed_count=0  # Reset hitungan kegagalan setelah mengaktifkan mode pesawat
        fi
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Salah satu host dapat dijangkau. Tidak perlu mengaktifkan mode pesawat."
        failed_count=0  # Reset hitungan kegagalan jika salah satu host dapat dijangkau
    fi

    sleep $INTERVAL  # Tunggu sebelum memeriksa koneksi lagi
done
