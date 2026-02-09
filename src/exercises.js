export const exercises = [
  {
    id: 1,
    name: "Cat-Cow Stretch",
    nameId: "Peregangan Kucing-Sapi",
    duration: 30,
    reps: "5-8 kali",
    icon: "solar:cat-bold-duotone",
    steps: [
      "Posisi merangkak, tangan di bawah bahu, lutut di bawah pinggul",
      "Tarik napas: lengkungkan punggung ke bawah, angkat kepala (Cow)",
      "Buang napas: bulatkan punggung ke atas, tundukkan kepala (Cat)",
      "Lakukan perlahan dengan irama napas",
    ],
    targetMuscle: "Erector spinae, multifidus",
    benefit:
      "Meningkatkan fleksibilitas tulang belakang dan mengurangi kekakuan",
  },
  {
    id: 2,
    name: "Knee-to-Chest Stretch",
    nameId: "Lutut ke Dada",
    duration: 30,
    reps: "Tahan 15-30 detik per sisi",
    icon: "solar:body-bold-duotone",
    steps: [
      "Berbaring telentang di lantai",
      "Tekuk satu lutut, tarik perlahan ke arah dada",
      "Tahan 15-30 detik, rasakan peregangan di punggung bawah",
      "Ganti kaki, lalu coba kedua lutut bersamaan",
    ],
    targetMuscle: "Lower back, glutes",
    benefit: "Melepaskan tekanan pada saraf tulang belakang bagian bawah",
  },
  {
    id: 3,
    name: "Seated Spinal Twist",
    nameId: "Rotasi Tulang Belakang Duduk",
    duration: 30,
    reps: "Tahan 15-20 detik per sisi",
    icon: "solar:refresh-circle-bold-duotone",
    steps: [
      "Duduk di kursi, kaki rata di lantai",
      "Letakkan tangan kanan di lutut kiri",
      "Putar badan perlahan ke kiri, lihat ke belakang",
      "Tahan, rasakan peregangan di punggung",
      "Kembali ke tengah, ulangi sisi lainnya",
    ],
    targetMuscle: "Obliques, erector spinae, multifidus",
    benefit: "Bisa dilakukan di kursi kerja, meningkatkan mobilitas rotasi",
  },
  {
    id: 4,
    name: "Standing Back Extension",
    nameId: "Ekstensi Punggung Berdiri",
    duration: 20,
    reps: "5-8 kali",
    icon: "solar:user-bold-duotone",
    steps: [
      "Berdiri tegak, letakkan kedua tangan di punggung bawah",
      "Perlahan lengkungkan punggung ke belakang",
      "Tahan 2-3 detik di posisi akhir",
      "Kembali ke posisi tegak",
    ],
    targetMuscle: "Erector spinae, lumbar extensors",
    benefit:
      "Counterbalance posisi duduk membungkuk, mudah dilakukan di mana saja",
  },
  {
    id: 5,
    name: "Child's Pose",
    nameId: "Pose Anak",
    duration: 45,
    reps: "Tahan 30-45 detik",
    icon: "solar:meditation-round-bold-duotone",
    steps: [
      "Berlutut, duduk di atas tumit",
      "Rentangkan tangan ke depan, dahi ke lantai",
      "Tarik napas dalam, rasakan punggung memanjang",
      "Rileks dan tahan posisi",
    ],
    targetMuscle: "Lower back, lats, hips",
    benefit: "Peregangan pasif yang sangat relaksasi untuk seluruh punggung",
  },
  {
    id: 6,
    name: "Piriformis Stretch",
    nameId: "Peregangan Piriformis",
    duration: 30,
    reps: "Tahan 20-30 detik per sisi",
    icon: "solar:armchair-bold-duotone",
    steps: [
      "Duduk di kursi, angkat kaki kanan, taruh ankle di lutut kiri (figure-4)",
      "Tegakkan punggung, perlahan condongkan badan ke depan",
      "Rasakan peregangan di bokong dan pinggul kanan",
      "Tahan, lalu ganti sisi",
    ],
    targetMuscle: "Piriformis, deep hip rotators, glutes",
    benefit: "Sering terkait sciatica, bisa dilakukan di kursi kerja",
  },
  {
    id: 7,
    name: "Pelvic Tilt",
    nameId: "Tilt Pelvis",
    duration: 25,
    reps: "10-15 kali",
    icon: "solar:round-transfer-vertical-bold-duotone",
    steps: [
      "Berbaring telentang, tekuk lutut, kaki rata di lantai",
      "Kencangkan otot perut, ratakan punggung ke lantai",
      "Tahan 5 detik, lalu rileks",
      "Ulangi dengan ritme yang stabil",
    ],
    targetMuscle: "Transverse abdominis, multifidus",
    benefit: "Memperkuat core stabilizer, dasar rehabilitasi LBP",
  },
  {
    id: 8,
    name: "Hip Flexor Stretch",
    nameId: "Peregangan Fleksor Pinggul",
    duration: 30,
    reps: "Tahan 20-30 detik per sisi",
    icon: "solar:running-round-bold-duotone",
    steps: [
      "Posisi berlutut satu kaki (half-kneeling lunge)",
      "Kaki depan ditekuk 90°, lutut belakang di lantai",
      "Dorong pinggul ke depan perlahan",
      "Rasakan peregangan di depan paha kaki belakang",
      "Jaga punggung tetap tegak",
    ],
    targetMuscle: "Iliopsoas, rectus femoris",
    benefit:
      "Duduk lama membuat hip flexor pendek, ini menyebabkan anterior pelvic tilt dan LBP",
  },
];

// Quick desk exercises (can be done at desk without floor)
export const quickDeskExercises = exercises.filter((e) =>
  [3, 4, 6].includes(e.id),
);

// Get random exercises for a session
export function getSessionExercises(count = 3) {
  const shuffled = [...exercises].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
}

// Get a random quick desk exercise
export function getQuickExercise() {
  return quickDeskExercises[
    Math.floor(Math.random() * quickDeskExercises.length)
  ];
}
