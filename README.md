# JIZJAZ-RECON 🚀
**Automated Reconnaissance Framework for Ethical Hacking**

JIZJAZ-RECON adalah alat otomasi *information gathering* yang dirancang untuk mempercepat fase *Reconnaissance* pada target tunggal. Tool ini mengintegrasikan pemindaian jaringan, fuzzing direktori web, dan crawling endpoint modern dalam satu alur kerja yang efisien.

---

## 🛠️ Fitur Utama
- **Network Enumeration:** Menggunakan Nmap untuk pemindaian port, deteksi layanan, dan OS fingerprinting.
- **Web Directory Fuzzing:** Menggunakan FFUF untuk menemukan file atau direktori tersembunyi/sensitif.
- **Modern Endpoint Spidering:** Menggunakan Katana (ProjectDiscovery) untuk memetakan URL dan analisis file JavaScript.
- **SSL/TLS Auditing:** Pemeriksaan otomatis terhadap konfigurasi SSL dan kerentanan umum (Heartbleed, dll).
- **Auto-Workspace:** Hasil scan disimpan secara rapi di folder `output/<target-ip>` dengan format timestamp.

## 📋 Prasyarat (Dependencies)
Pastikan alat-alat berikut sudah terinstal di sistem Kali Linux Anda:
- **Nmap** 
- **FFUF** 
- **Katana** 
- **JQ & Column** 

## 🚀 Cara Penggunaan
Clone repositori ini:

git clone [https://github.com/alif-cybersec/jizjaz-recon.git](https://github.com/alif-cybersec/jizjaz-recon.git)
cd jizjaz-recon

Berikan izin eksekusi:

chmod +x jizjaz-recon.sh

Jalankan tool terhadap target:
Bash

./jizjaz-recon.sh <target-ip-atau-domain>

📂 Struktur Output

Setiap kali Anda menjalankan scan, tool ini akan membuat folder:
output/target/nmap_results.txt
output/target/ffuf_summary.txt
output/target/katana_endpoints.txt

Developed by alif-cybersec for Educational & Ethical Hacking purposes only.
