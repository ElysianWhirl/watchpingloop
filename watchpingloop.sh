#!/bin/bash

# Fungsi untuk mengaktifkan mode pesawat
enable_airplane_mode() {
    echo "Mengaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode enable
}

# Fungsi untuk menonaktifkan mode pesawat
disable_airplane_mode() {
    echo "Menonaktifkan mode pesawat..."
    adb shell cmd connectivity airplane-mode disable
}

# Loop untuk melakukan ping dan mengaktifkan/menonaktifkan mode pesawat
while true; do
    if ping -c 1 162.159.138.78 &> /dev/null; then
        echo "Host dapat dijangkau."
        sleep 10  # Tunggu sebelum melakukan ping lagi
    else
        echo "Host tidak dapat dijangkau. Mengaktifkan mode pesawat..."
        enable_airplane_mode
        sleep 10  # Tunggu sebelum memeriksa koneksi lagi
        echo "Host dijangkau. Menonaktifkan mode pesawat kembali..."
        disable_airplane_mode
        sleep 10  # Tunggu sebelum memeriksa koneksi lagi
    fi
done