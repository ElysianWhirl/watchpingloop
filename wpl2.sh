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

# Variabel untuk menghitung berapa kali ping gagal
failed_count1=0
failed_count2=0

# ping_fail_for_modpes
pingfail=3

# Waktu tunggu (detik) sebelum mengaktifkan mode pesawat setelah ping gagal
WAIT_TIME=3

# Fungsi untuk memeriksa konektivitas ke host tertentu
check_host() {
    local host=$1
    local failed_count_var=$2
    local failed_count=$(eval echo \$$failed_count_var)
    PING_RESULT=$(ping -c 1 $host 2>&1)
    if echo "$PING_RESULT" | grep "time=" > /dev/null; then
        PING_TIME=$(echo "$PING_RESULT" | grep "time=" | sed -e 's/.*time=\([0-9\.]*\) ms.*/\1/')
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host dapat dijangkau. Waktu ping: ${PING_TIME} ms"
        eval $failed_count_var=0  # Reset hitungan kegagalan jika host berhasil dijangkau
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host $host tidak dapat dijangkau."
        failed_count=$((failed_count + 1))  # Tingkatkan hitungan kegagalan
        eval $failed_count_var=$failed_count
        if [ $failed_count -ge $pingfail ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Gagal ping ke $host sebanyak $pingfail kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode  # Jika sudah ada $pingfail kegagalan berturut-turut, aktifkan mode pesawat
            sleep $WAIT_TIME  # Tunggu beberapa waktu sebelum menonaktifkan mode pesawat
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat kembali..."
            disable_airplane_mode  # Nonaktifkan mode pesawat kembali
            eval $failed_count_var=0  # Reset hitungan kegagalan setelah mengaktifkan mode pesawat
        fi
    fi
}

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    check_host $HOST1 failed_count1
    check_host $HOST2 failed_count2
    sleep 5  # Tunggu sebelum memeriksa koneksi lagi 
done
