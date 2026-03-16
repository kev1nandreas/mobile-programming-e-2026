# 📱 Penjelasan Kode Tugas Pertemuan 3

## 📁 Struktur Aplikasi

```
main()
└── MyApp (StatelessWidget)
    └── RowColumnPage (StatelessWidget)
        ├── Container + AspectRatio + Image.network
        ├── Container + Text
        ├── Container + Row + Column + Icon
        └── CounterCard (StatefulWidget)
```

---

## Fungsi dan Widget yang Digunakan

### `main()` dan `MyApp`

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `main()` | Fungsi | Titik masuk aplikasi Flutter. |
| `runApp()` | Fungsi | Menyisipkan widget root ke dalam widget tree Flutter. |
| `MaterialApp` | Widget | Wrapper utama yang menyediakan tema Material Design dan navigasi. |
| `ThemeData` | Konfigurasi | Mengatur skema warna dan style global aplikasi. |
| `ColorScheme.fromSeed()` | Fungsi | Membuat skema warna dari satu warna dasar (seed color). |

---

### `RowColumnPage` — StatelessWidget

Widget halaman utama yang bersifat statis (tidak menyimpan state).

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `StatelessWidget` | Kelas | Widget yang tidak memiliki state. Hanya di-render sekali. |
| `build()` | Method | Method wajib yang mengembalikan widget tree yang akan ditampilkan. |
| `MediaQuery.of()` | Fungsi | Mengambil informasi layar seperti lebar dan tinggi perangkat. |
| `Scaffold` | Widget | Menyediakan struktur halaman dasar: AppBar, body, floating button, dll. |
| `AppBar` | Widget | Bar navigasi di bagian atas layar. Mendukung title, warna, dan aksi. |
| `Column` | Widget | Menyusun widget secara vertikal (dari atas ke bawah). |
| `crossAxisAlignment` | Property | Mengatur posisi anak Column secara horizontal (kiri/kanan/tengah). |
| `mainAxisAlignment` | Property | Mengatur posisi anak Column secara vertikal (atas/bawah/tengah/spasi). |

---

### `Container`

Widget serbaguna untuk menambahkan padding, margin, warna, dan ukuran pada widget anak.

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `Container` | Widget | Widget kotak yang dapat dikustomisasi dengan warna, padding, margin, dan ukuran. |
| `margin` | Property | Jarak di luar Container terhadap widget lain di sekitarnya. |
| `padding` | Property | Jarak di dalam Container antara border dan widget anak. |
| `color` | Property | Warna latar belakang Container. |
| `width` | Property | Lebar Container. Dapat menggunakan `MediaQuery` untuk lebar penuh layar. |
| `EdgeInsets.fromLTRB()` | Fungsi | Membuat padding/margin dengan nilai berbeda untuk tiap sisi (left, top, right, bottom). |
| `EdgeInsets.all()` | Fungsi | Membuat padding/margin yang sama untuk semua sisi. |

---

### `AspectRatio` dan `Image`

Digunakan untuk menampilkan gambar dari internet dengan rasio aspek tertentu.

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `AspectRatio` | Widget | Memaksa widget anak memiliki rasio lebar:tinggi tertentu (1.0 = persegi). |
| `aspectRatio` | Property | Nilai rasio lebar dibagi tinggi. Contoh: `1.0` = kotak, `16/9` = widescreen. |
| `Image.network()` | Widget | Menampilkan gambar dari URL internet. |
| `fit: BoxFit.cover` | Property | Mengatur gambar agar memenuhi ruang tanpa distorsi (dipotong jika perlu). |
| `Center` | Widget | Memusatkan widget anak secara horizontal dan vertikal. |

---

### `Row` dan `Icon`

Digunakan untuk menyusun beberapa ikon dan label secara horizontal.

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `Row` | Widget | Menyusun widget secara horizontal (dari kiri ke kanan). |
| `MainAxisAlignment.spaceEvenly` | Property | Membagi ruang kosong secara merata di antara semua anak widget. |
| `CrossAxisAlignment.start` | Property | Menjajarkan anak widget ke tepi atas pada Row. |
| `Icon` | Widget | Menampilkan ikon dari Material Icons bawaan Flutter. |
| `Icons.food_bank` | Konstanta | Ikon bank makanan dari library Material Icons. |
| `Icons.landscape` | Konstanta | Ikon pemandangan alam dari library Material Icons. |
| `Icons.people` | Konstanta | Ikon orang/kelompok dari library Material Icons. |
| `Text` | Widget | Menampilkan teks di layar. Dapat dikustomisasi dengan `TextStyle`. |
| `TextStyle` | Kelas | Mengatur gaya teks: ukuran (`fontSize`), tebal (`bold`), warna, dll. |

---

## Counter Card — StatefulWidget

Komponen interaktif yang menampilkan counter dan tombol untuk menambah nilainya.

### Struktur StatefulWidget

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `StatefulWidget` | Kelas | Widget yang memiliki state (data) yang dapat berubah seiring waktu. |
| `State<T>` | Kelas | Kelas yang menyimpan state dari StatefulWidget dan mengelola siklus hidupnya. |
| `createState()` | Method | Method wajib StatefulWidget untuk membuat objek State yang terkait. |
| `_CounterCardState` | Kelas | Implementasi State untuk CounterCard. Konvensi nama diawali underscore (`_`). |

### State dan `setState`

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `_counter` | Variable | Variabel integer yang menyimpan nilai counter saat ini. Diinisialisasi dengan `0`. |
| `setState()` | Fungsi | Memberitahu Flutter bahwa state telah berubah sehingga widget di-render ulang. |
| `_incrementCounter()` | Method | Fungsi yang dipanggil saat tombol ditekan untuk menaikkan nilai `_counter`. |

### Widget pada CounterCard

| Widget / Fungsi | Tipe | Penjelasan |
|---|---|---|
| `IconButton` | Widget | Tombol berbentuk ikon yang dapat ditekan. Memiliki callback `onPressed`. |
| `onPressed` | Property | Callback function yang dipanggil saat tombol ditekan. |
| `Icons.add` | Konstanta | Ikon tanda tambah (`+`) dari Material Icons. |
| `MainAxisAlignment.spaceBetween` | Property | Menempatkan anak widget di ujung kiri dan kanan Row dengan ruang di tengah. |
| `"Counter here: $_counter"` | String Interpolation | Menyisipkan nilai variabel `_counter` langsung ke dalam string teks. |