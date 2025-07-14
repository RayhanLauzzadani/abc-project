import 'dart:io';
import 'package:flutter/foundation.dart';

class SellerRegistrationProvider with ChangeNotifier {
  File? ktpFile;
  String nik = '';
  String nama = '';
  String bank = '';
  String rek = '';

  File? logoFile;
  String shopName = '';
  String shopDesc = '';
  String shopAddress = '';
  String shopPhone = '';

  bool agreeTerms = false;

  // ---- Individual Setters ----
  void setKtpFile(File? file) {
    ktpFile = file;
    notifyListeners();
  }

  void setNik(String nik) {
    this.nik = nik;
    notifyListeners();
  }

  void setNama(String nama) {
    this.nama = nama;
    notifyListeners();
  }

  void setBank(String bank) {
    this.bank = bank;
    notifyListeners();
  }

  void setRek(String rek) {
    this.rek = rek;
    notifyListeners();
  }

  void setLogoFile(File? file) {
    logoFile = file;
    notifyListeners();
  }

  void setShopName(String name) {
    shopName = name;
    notifyListeners();
  }

  void setShopDesc(String desc) {
    shopDesc = desc;
    notifyListeners();
  }

  void setShopAddress(String address) {
    shopAddress = address;
    notifyListeners();
  }

  void setShopPhone(String phone) {
    shopPhone = phone;
    notifyListeners();
  }

  void setAgreeTerms(bool value) {
    agreeTerms = value;
    notifyListeners();
  }

  void resetAll() {
    ktpFile = null;
    nik = '';
    nama = '';
    bank = '';
    rek = '';
    logoFile = null;
    shopName = '';
    shopDesc = '';
    shopAddress = '';
    shopPhone = '';
    agreeTerms = false;
    notifyListeners();
  }
}
