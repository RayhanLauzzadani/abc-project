import 'package:abc_e_mart/buyer/features/profile/privacy_policy_page.dart';
import 'package:abc_e_mart/buyer/features/profile/terms_page.dart';
import 'package:abc_e_mart/buyer/widgets/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/user_service.dart';
import '../../data/models/user.dart';
import 'package:abc_e_mart/seller/features/registration/registration_welcome_page.dart';
import 'package:abc_e_mart/buyer/features/profile/address_list_page.dart';
import 'package:abc_e_mart/buyer/features/profile/appearance_setting_page.dart';
import 'package:abc_e_mart/buyer/features/profile/password_change_page.dart';
import 'package:abc_e_mart/buyer/features/profile/profile_edit_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc_e_mart/seller/features/home/home_page_seller.dart';
import 'package:abc_e_mart/seller/widgets/shop_verification_status_page.dart';
import 'package:abc_e_mart/buyer/features/auth/login_page.dart';
import 'package:abc_e_mart/seller/widgets/shop_rejected_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Lepas token saat logout untuk cegah notif nyasar
import 'package:abc_e_mart/data/services/fcm_token_registrar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  UserModel? _userModel;
  bool _isLoading = true;

  Future<void> setUserOfflineWithLastLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isOnline': false,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Untuk flag akses penolakan (hanya sekali)
  static const String shopRejectedFlag = 'has_seen_shop_rejected';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final user = await _userService.getUserById(currentUser.uid);
      if (!mounted) return;
      setState(() {
        _userModel = user;
        _isLoading = false;
      });
    }
  }

  // RESET FLAG saat logout!
  Future<void> resetShopRejectedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(shopRejectedFlag);
  }

  // SET FLAG saat page ShopRejectedPage diakses
  Future<void> setShopRejectedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(shopRejectedFlag, true);
  }

  // GET FLAG
  Future<bool> getShopRejectedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(shopRejectedFlag) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profil Saya",
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF373E3C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          (_userModel?.photoUrl != null &&
                                  _userModel!.photoUrl!.isNotEmpty)
                              ? CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  backgroundImage: NetworkImage(
                                    _userModel!.photoUrl!,
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userModel?.name ?? "-",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF373E3C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FirebaseAuth.instance.currentUser?.email ??
                                      "-",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: const Color(0xFF6D6D6D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileEditPage(),
                                ),
                              );
                              if (result == true) {
                                _fetchUserData();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF9A9A9A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Umum"),
                    _buildOptionCard([
                      _buildListTile(
                        'location.svg',
                        "Detail Alamat",
                        size: 22,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressListPage(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        'tampilan.svg',
                        "Tampilan",
                        size: 18,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppearanceSettingPage(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        'lock.svg',
                        "Ganti Password",
                        size: 20,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PasswordChangePage(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        'store.svg',
                        "Toko Saya",
                        size: 21,
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final query = await FirebaseFirestore.instance
                                .collection('shopApplications')
                                .where('owner.uid', isEqualTo: user.uid)
                                .limit(1)
                                .get();

                            Navigator.of(context).pop();

                            if (query.docs.isEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationWelcomePage(),
                                ),
                              );
                              return;
                            }

                            final shopData = query.docs.first.data();
                            final status = shopData['status'] ?? '';
                            final rejectionReason = shopData['rejectionReason'] ?? '-';

                            if (status == 'approved') {
                              await setUserOfflineWithLastLogin();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePageSeller(),
                                ),
                              );
                            } else if (status == 'pending') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShopVerificationStatusPage(),
                                ),
                              );
                            } else if (status == 'rejected') {
                              final seenRejected = await getShopRejectedFlag();
                              if (!seenRejected) {
                                await setShopRejectedFlag();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ShopRejectedPage(reason: rejectionReason),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistrationWelcomePage(),
                                  ),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationWelcomePage(),
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal cek status toko: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Bantuan"),
                    _buildOptionCard([
                      _buildListTile(
                        'policy.svg',
                        "Kebijakan Privasi",
                        size: 20,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        'syarat.svg',
                        "Syarat Penggunaan",
                        size: 20,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsPage(),
                            ),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildOptionCard([
                      ListTile(
                        onTap: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (_) => const LogoutConfirmationDialog(),
                          );
                          if (result == true) {
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .set({
                                  'isOnline': false,
                                  'lastLogin': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));
                              }

                              // ✅ Lepas token dari akun ini sebelum signOut
                              await FcmTokenRegistrar.unregister();

                              await FirebaseAuth.instance.signOut();
                              await resetShopRejectedFlag(); // Reset flag
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal logout: $e')),
                                );
                              }
                            }
                          }
                        },
                        leading: SvgPicture.asset(
                          'assets/icons/logout.svg',
                          width: 21,
                          height: 21,
                          color: const Color(0xFFFF3B30),
                        ),
                        title: Text(
                          "Keluar",
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        dense: true,
                        horizontalTitleGap: 12,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF373E3C),
        ),
      ),
    );
  }

  Widget _buildOptionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 20,
      thickness: 1,
      color: Color(0xFFE0E0E0),
      indent: 12,
      endIndent: 12,
    );
  }

  Widget _buildListTile(
    String iconAsset,
    String text, {
    double size = 22,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/$iconAsset',
            width: size,
            height: size,
            color: const Color(0xFF9A9A9A),
          ),
        ),
      ),
      title: Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF373E3C)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6D6D6D)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      dense: true,
      horizontalTitleGap: 10,
    );
  }
}
