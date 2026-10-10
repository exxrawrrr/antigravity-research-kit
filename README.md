# Antigravity Research Kit

Setup Windows yang gue bikin buat nyiapin Antigravity + beberapa helper untuk kerja skripsi, tesis, disertasi, dan riset akademik.

Fokusnya sederhana: install yang perlu, jangan ngerusak setup yang sudah ada, dan kasih jalur verify / repair kalau ada yang miss.

## Preview

<p align="center">
  <img src="assets/terminal-preview-final.webp" alt="Antigravity Research Kit terminal" width="100%">
</p>

## Cara pakai

Versi packaged terbaru saat ini: **v0.1.2**

Untuk pemakaian biasa:

1. buka halaman [Releases](https://github.com/exxrawrrr/antigravity-research-kit/releases/latest)
2. download ZIP terbaru
3. extract
4. jalankan `START.cmd`
5. login Antigravity / Google sendiri kalau diminta
6. jalankan `VERIFY.bat` kalau mau cek hasil setup

Kalau butuh petunjuk pendek, lihat [QUICKSTART.md](QUICKSTART.md).

Buat pertama kali pakai untuk skripsi/tesis/disertasi, mulai dari **[Panduan 3 langkah + prompt siap pakai](FRIENDS-START.md)**. Tidak perlu paham terminal atau coding.

## Yang dipasang

Installer saat ini menyiapkan:

- Antigravity 2.x
- Antigravity IDE
- Antigravity CLI (`agy`)
- Tokyo Night extension
- Material Icon Theme
- terminal sandbox / safer execution defaults jika didukung
- request-review / permission-first defaults jika didukung
- Rafdi Research role-skill
- Rafdi Document role-skill
- Rafdi Reviewer role-skill
- helper skills untuk research, document, dan evidence tracing

## File yang biasa dipakai

- `START.cmd` — jalur utama
- `INSTALL.bat` — langsung ke installer
- `STATUS.cmd` — cek status pada current main
- `VERIFY.bat` — read-only verification
- `REPAIR.bat` — pasang ulang bagian managed yang hilang lalu verify
- `ROLLBACK-MANAGED-SETUP.bat` — rollback bagian yang dikelola installer tanpa uninstall Antigravity

## Research pack

Pack-nya sengaja dibagi beberapa peran biar instruksi yang aktif nggak numpuk semua sekaligus.

### Research

Buat cari, ngerangkum, dan menelusuri sumber penelitian.

### Document

Buat kerja ke draft / dokumen lokal, termasuk formatting kalau ada contoh atau guideline.

### Reviewer

Buat QA: nyari bagian lemah, inkonsisten, klaim yang kurang bukti, atau struktur yang perlu dibenerin.

Ada juga helper tambahan untuk:

- belajar style dokumen dari contoh
- tracing klaim ke sumber
- kerja dengan file lokal
- review hasil sebelum dipakai

## Soal safety

Installer dibuat agak konservatif.

- cek dulu sebelum install
- compatible install yang sudah ada tidak ditimpa asal
- managed settings dibackup sebelum diubah
- permission prompt normal tetap dipakai
- tidak mengaktifkan auto-approval berbahaya
- credential, cookie, token OAuth, dan API key tidak dicopy dari mesin lain
- verify bersifat read-only
- ada repair dan rollback untuk bagian yang dikelola installer

## Release

Stable packaged line saat ini: **v0.1.2**.

`main` bisa saja punya perubahan yang belum masuk tag release berikutnya. Jadi angka versi di README ini mengikuti archive yang memang sudah dipublish, bukan sekadar isi branch terbaru.

Release ZIP menyertakan checksum SHA256 supaya file hasil download bisa diverifikasi.

## Attribution

Skill yang gue tulis sendiri menyertakan:

`Made by Rafdi D. Ulhaq`

Software pihak ketiga tetap punya lisensi dan attribution masing-masing. Project ini sebisa mungkin memakai source/package resmi dan tidak membundel binary proprietary kalau izin redistribusinya nggak jelas.

---

Made by Rafdi D. Ulhaq / [@exxrawrrr](https://github.com/exxrawrrr)
