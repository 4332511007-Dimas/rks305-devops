# Blameless Postmortem - Insiden Kegagalan Deployment Manual

## Ringkasan Insiden
Pada simulasi serah-terima manual aplikasi Flask "sentra-digital-batam", peran Operations tidak dapat langsung menjalankan aplikasi dari artefak yang diterima. Aplikasi baru berjalan setelah 2 kali kegagalan dan penyelesaian melalui tebakan, dengan total waktu 6 menit 39 detik. Aplikasi yang sama berjalan normal di lingkungan Developer. Insiden ini adalah simulasi terkontrol untuk memperlihatkan Wall of Confusion.

## Kronologi (timeline)
Tanggal 20 September 2026 (WIB):
- 15:25 - Developer menulis kode aplikasi, berkas dependensi, dan dokumen serah-terima (HANDOVER.md).
- 15:26 - Uji lokal di lingkungan Developer berhasil.
- 15:28 - Artefak dikemas untuk diserahkan. Berkas dependensi (requirements.txt) tidak ikut terkemas.
- 15:34 - Operations menerima artefak dan hanya berpegang pada HANDOVER.md.
- Kegagalan 1: `pip3 install -r requirements.txt` gagal karena berkas tidak ada.
- Kegagalan 2: `python3 src/app.py` gagal dengan ModuleNotFoundError untuk modul flask.
- Operations menebak dan menjalankan `pip3 install flask`. Terpasang versi 3.1.3, sedangkan Developer memakai 3.0.3.
- 15:41 - Aplikasi merespons health check dan insiden dinyatakan selesai.

## Dampak (waktu terbuang, jumlah kegagalan)
- Lead Time manual: 6 menit 39 detik.
- Jumlah kegagalan: 2.
- Pertanyaan yang seharusnya diajukan ke Developer tetapi tidak dapat dijawab: 5 (berkas dependensi, versi Flask, venv atau global, versi Python, alamat dan port).
- Lingkungan tidak identik: Flask 3.1.3 (global pengguna) di Operations dan 3.0.3 (virtual environment) di Developer.
- Flow Efficiency proses serah-terima 58,8%, dengan 5 dari 10 menit kerja aktif dipakai untuk memperbaiki galat.

## Akar Masalah pada SISTEM (bukan pada orang)
1. Serah-terima bergantung pada dokumen manual yang tidak memiliki standar isi maupun daftar periksa (checklist).
2. Tidak ada verifikasi bahwa artefak dapat dijalankan di lingkungan bersih sebelum diserahkan.
3. Dependensi tidak dikemas dan dikunci bersama kode secara otomatis, sehingga satu berkas yang tertinggal tidak terdeteksi.
4. Pengetahuan tentang cara menjalankan aplikasi tidak tertulis dalam bentuk yang dapat dieksekusi.
5. Jalur klarifikasi antar peran tidak tersedia saat serah-terima, sehingga kekurangan informasi tidak dapat segera ditutup.

## Tindakan Perbaikan (action items) + penanggung jawab peran
| Tindakan | Penanggung jawab | Status |
|---|---|---|
| Menyertakan dan mengunci dependensi (flask==3.0.3) dalam requirements.txt di repository | Developer | Selesai |
| Mengganti dokumen manual dengan skrip setup.sh (cek prasyarat, venv, instalasi, health check) | Developer | Selesai |
| Menyimpan artefak di Git dengan .gitignore agar venv dan berkas rahasia tidak ikut | Developer | Selesai |
| Menjalankan setup.sh di lingkungan bersih sebelum setiap serah-terima | Operations | Diusulkan sebagai standar |
| Menambahkan pemeriksaan otomatis pada pipeline CI/CD | Developer dan Operations | Diusulkan (materi minggu berikutnya) |

## Pelajaran yang Diambil
- Kegagalan berasal dari desain proses serah-terima, bukan dari kelalaian peran tertentu. Mengganti personel tidak akan mencegah kejadian serupa.
- Pengetahuan sebaiknya dituangkan menjadi kode yang dijalankan, bukan dokumen yang dibaca.
- Setelah otomasi, Lead Time turun dari 6 menit 39 detik menjadi 9 detik (dengan cache pip), kegagalan dari 2 menjadi 0, dan pertanyaan tak terjawab dari 5 menjadi 0.
- Perilaku berhenti saat gagal (set -euo pipefail) membuat masalah terdeteksi tepat di sumbernya.
- Angka 9 detik dibantu cache pip. Pada mesin yang benar-benar baru, waktunya akan lebih lama.
