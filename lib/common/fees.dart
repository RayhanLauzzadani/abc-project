class Fees {
  static const int serviceFee = 2000;        // biaya layanan flat
  static const double taxRate = 0.01;        // 1%
  static int taxOn(int base) => (base * taxRate).round();
}
