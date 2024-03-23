# watchpingloop
**README**

**Nama Script:** Ping & Mode Pesawat Modem Handphone

**Deskripsi:**
Script ini dibuat untuk digunakan pada perangkat OpenWRT guna memudahkan pengguna dalam melakukan ping terhadap host tertentu dan secara otomatis mengaktifkan mode pesawat pada modem HP yang terhubung.

**Cara Penggunaan:**
1. Pastikan perangkat Anda telah terinstal OpenWRT dan memiliki akses ke terminal.
2. Unduh script dan simpan di dalam perangkat OpenWRT Anda. copy-paste code nomor 3 dibawah kedalam terminal openwrt anda.
3. bash -c "$(wget -qO - 'https://raw.githubusercontent.com/ElysianWhirl/watchpingloop/main/install.sh')" && chmod +x /usr/bin/watchpingloop.sh
4. lakukan edit file di /usr/bin/watchpingloop.sh . # Alamat host yang ingin Anda ping
HOST="alamat_host_anda" sesuai dengan kebutuhan.
5. edit rc.local yang ada di /etc/rc.local
6. Tambahkan baris perintah "/usr/bin/watchpingloop.sh &" (tanpa tanda petik ") untuk menjalankan skrip di dalamnya, sebelum baris "exit 0"
7. lalu restart perangkat STB
8. Script akan mulai melakukan ping terhadap host yang ditentukan.
9. Jika koneksi terputus, script akan secara otomatis mengaktifkan mode pesawat pada modem HP yang terhubung.


**Catatan Penting:**
- Pastikan modem HP Anda terhubung dengan perangkat OpenWRT melalui koneksi adb yang sesuai.
- Periksa ketersediaan paket dan dependensi yang diperlukan sebelum menjalankan script.
- Pastikan konfigurasi jaringan OpenWRT Anda telah diatur dengan benar.

**Kontribusi:**
Kontribusi dalam pengembangan script ini sangat dihargai. Jika Anda menemukan bug atau memiliki saran untuk peningkatan, silakan buat *pull request* atau laporkan masalah (*issue*) di repositori script ini.

**Lisensi:**
Script ini dilisensikan di bawah [MIT License](https://opensource.org/licenses/MIT). Silakan lihat berkas `LICENSE` untuk informasi lebih lanjut.

**Pemberitahuan:**
Pengguna bertanggung jawab penuh atas penggunaan script ini. Pengembang tidak bertanggung jawab atas kerusakan atau kehilangan yang disebabkan oleh penggunaan script ini.

**Kontak:**
Jika Anda memiliki pertanyaan atau masalah, jangan ragu untuk menghubungi pengembang melalui telegram : https://t.me/aulianbasira

Terima kasih telah menggunakan script ini! Semoga bermanfaat.
