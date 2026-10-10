# Mulai Pakai Antigravity Research Kit

**Untuk teman-teman yang mau ngerjain skripsi, tesis, atau disertasi tanpa ribet.**

## Alternatif: cukup satu perintah (setelah fitur ini masuk release resmi)

Buka **CMD** atau **PowerShell** di Windows, paste satu baris ini, lalu Enter. Tidak perlu menjalankan sebagai Administrator kecuali instalasi paket resmi memintanya.

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:TEMP 'EXXRAWRRR-GET.ps1'; iwr -UseBasicParsing 'https://raw.githubusercontent.com/exxrawrrr/antigravity-research-kit/main/GET-EXXRAWRRR.ps1' -OutFile $p -ErrorAction Stop; & $p"
```

Perintah ini mengunduh **script bootstrap dari repository milik pembuat kit** ke TEMP, lalu menjalankannya. Bootstrap mengunduh *GitHub Release* terbaru, mencocokkan SHA256 ZIP dan setiap file melalui manifest internal, dan membuka START.cmd. Perintah ini **bukan jaminan script bootstrap tersertifikasi**; pakai hanya bila kamu percaya repo dan alamatnya. Jangan menjalankan script dari salinan situs yang tidak dikenal. Jika CMD memunculkan peringatan Windows Security, periksa publisher/sumber daripada menonaktifkan proteksi.

**Catatan rilis:** One-line setup baru tersedia setelah PR fitur ini masuk `main`; versi ZIP lama tetap menggunakan cara klik `START.cmd` di bawah ini.

## Cukup 3 langkah

1. Download ZIP dari [Releases](https://github.com/exxrawrrr/antigravity-research-kit/releases/latest). Extract ZIP **semuanya** ke folder biasa.
2. Klik dua kali **START.cmd**. Tunggu indikator EXXRAWRRR selesai. Kalau perlu login, login sendiri lewat layar resmi Antigravity/Google. Jangan berikan password atau token kepada siapa pun.
3. Pilih **[A] Open Antigravity** atau buka Antigravity sendiri. Untuk cek kesiapan, jalankan **VERIFY.bat**; status sehat menampilkan **READY FOR LOCAL ACADEMIC WORK**.

> Research Kit menyiapkan aplikasinya dan mengaktifkan panduan kerja AI, **bukan** mesin yang otomatis menyelesaikan karya ilmiah tanpa riset atau pemeriksaan manusia.

## Pilih satu tujuan saja

**A. Cari referensi dan susun kerangka (Research)**

Ketik di Antigravity:

> Bantu saya riset topik [TOPIK] untuk [skripsi/tesis/disertasi] program studi [PRODI]. Mulai dengan rumusan masalah, kata kunci, sumber primer/ilmiah yang bisa diverifikasi, matriks literatur, dan kemungkinan research gap. Jangan mengarang jurnal, DOI, kutipan, halaman, atau hasil penelitian. Pisahkan fakta sumber dari analisis AI. Jika belum bisa mengakses referensi, jelaskan dengan jujur.

**B. Rapikan format Word (Document)**

> Saya punya draft [DOCX] dan panduan penulisan kampus [FILE]. Baca panduan dulu, cocokkan margin, heading, spasi, tabel, footnote, halaman, dan daftar pustaka. Buat salinan file sebelum mengedit. Kerjakan bertahap, pertahankan isi dan sitasi, lalu periksa file hasilnya. Jangan mengubah isi penelitian tanpa izin.

**C. Cek revisi sebelum dikirim (Reviewer)**

> Review draft [FILE] dengan pedoman kampus [FILE] dan catatan dosen [FILE]. Tunjukkan temuan dalam tabel: tingkat masalah, lokasi, bukti, saran, dan status. Cek konsistensi judul, rumusan masalah, metode, pembahasan, kesimpulan, sitasi, dan referensi. Jangan tandai revisi selesai kalau belum dicek langsung.

Ganti [KATA DALAM KURUNG] dan lampirkan file kalau ada. Perintah ini memakai tiga skill utama yang sudah dipasang, sehingga **tidak perlu mengaktifkan semua skill sekaligus**.

## Kalau ada kendala

| Situasi | Yang dilakukan |
| --- | --- |
| Windows Terminal tidak muncul | Klik **INSTALL.bat** sebagai jalur alternatif |
| Diminta login Google | Login sendiri di alur resmi; akun dan kuota tetap milik masing-masing |
| Belum tahu instalasi berhasil atau tidak | Jalankan **VERIFY.bat** (atau STATUS.cmd pada paket yang sudah menyediakannya) |
| Komponen kit hilang | Jalankan **REPAIR.bat** lalu VERIFY |
| Ingin menghapus pengaturan kit | Pakai **ROLLBACK-MANAGED-SETUP.bat** dan baca konfirmasinya |
| Antivirus/Windows memblokir script | Periksa sumber ZIP dan checksum; jangan asal mematikan proteksi |
| Sumber ilmiah tidak ditemukan | Jangan memakai referensi fiktif; cari melalui perpustakaan, repository kampus, atau portal jurnal |

**Penting:** Antigravity dapat memakai layanan dan kuota pihak ketiga. Paket ini tidak menyediakan langganan premium, akses jurnal berbayar, atau jaminan hasil akademik. Cek ulang sitasi dan tata tulis sesuai aturan kampus masing-masing.

Made by Rafdi D. Ulhaq · EXXRAWRRR
