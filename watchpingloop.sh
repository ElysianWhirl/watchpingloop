#!/bin/ash

# Fungsi untuk mengaktifkan mode pesawat
enable_airplane_mode() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Mengaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode enable
}

# Fungsi untuk menonaktifkan mode pesawat
disable_airplane_mode() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode disable
}

# Alamat host yang ingin Anda ping
HOST="alamat_host_anda"

# Variabel untuk menghitung berapa kali ping gagal
failed_count=0

# Waktu tunggu (detik) sebelum mengaktifkan mode pesawat setelah ping gagal
WAIT_TIME=1

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    if ping -c 1 $HOST &> /dev/null; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host dapat dijangkau. Melanjutkan ping..."
        failed_count=0  # Reset hitungan kegagalan jika host berhasil dijangkau
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Host tidak dapat dijangkau."
        failed_count=$((failed_count + 1))  # Tingkatkan hitungan kegagalan
        if [ $failed_count -ge 5 ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Gagal ping sebanyak 5 kali. Mengaktifkan mode pesawat..."
            enable_airplane_mode  # Jika sudah ada 5 kegagalan berturut-turut, aktifkan mode pesawat
            sleep $WAIT_TIME  # Tunggu beberapa waktu sebelum menonaktifkan mode pesawat
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Menonaktifkan mode pesawat kembali..."
            disable_airplane_mode  # Nonaktifkan mode pesawat kembali
            failed_count=0  # Reset hitungan kegagalan setelah mengaktifkan mode pesawat
        fi
    fi
    sleep 5  # Tunggu sebelum memeriksa koneksi lagi
done
