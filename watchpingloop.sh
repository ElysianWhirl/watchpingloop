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
HOST="alamat_host_anda_1"

# Interface yang ingin digunakan untuk ping (bisa diubah manual)
INTERFACE="usb0"

# Variabel untuk menghitung berapa kali ping gagal
failed_count=0

# Ping gagal untuk mengaktifkan mode pesawat
pingfail=3

# Waktu tunggu (detik) sebelum mengaktifkan mode pesawat setelah ping gagal
WAIT_TIME=3

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    PING_RESULT=$(ping -I $INTERFACE -c 1 $HOST 2>&1)
    if echo "$PING_RESULT" | grep "time=" > /dev/null; then
        # Ekstrak waktu ping dari output
        PING_TIME=$(echo "$PING_RESULT" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host dapat dijangkau melalui $INTERFACE. Waktu ping: ${PING_TIME} ms"
        failed_count=0  # Reset hitungan kegagalan jika host berhasil dijangkau
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host tidak dapat dijangkau melalui $INTERFACE."
        failed_count=$((failed_count + 1))  # Tingkatkan hitungan kegagalan
        if [ $failed_count -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Gagal ping sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode  # Jika sudah ada $pingfail kegagalan berturut-turut, aktifkan mode pesawat
            sleep $WAIT_TIME  # Tunggu beberapa waktu sebelum menonaktifkan mode pesawat
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat kembali..."
            disable_airplane_mode  # Nonaktifkan mode pesawat kembali
            failed_count=0  # Reset hitungan kegagalan setelah mengaktifkan mode pesawat
        fi
    fi
    sleep 1  # Tunggu sebelum memeriksa koneksi lagi 
done
