import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Hidden for SCRUM-5. Restore these imports with the Dark Mode option below.
// import 'package:provider/provider.dart';
import 'package:muslimate/core/app_colors.dart';
// import 'package:muslimate/core/logic/settings_provider.dart';
import 'package:muslimate/shared/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Hidden for SCRUM-5. Restore when the Dark Mode option returns to scope.
    // final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Pengaturan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Hidden for SCRUM-5.
                  // _buildProfileCard(context, c),
                  _buildSection(context, c, 'TAMPILAN', [
                    // Hidden for SCRUM-5. Restore these display settings when
                    // they return to the release scope.
                    // _buildDarkToggle(context, c, settings),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.language_rounded,
                      'Bahasa',
                      'Bahasa Indonesia',
                      true,
                    ),
                    // _buildSettingsRow(
                    //   context,
                    //   c,
                    //   Icons.text_fields_rounded,
                    //   'Tipografi Arab',
                    //   'Naskh',
                    //   true,
                    // ),
                  ]),
                  _buildSection(context, c, 'IBADAH', [
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.location_on_outlined,
                      'Lokasi',
                      'Bandung, ID',
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.notifications_outlined,
                      'Pengingat shalat',
                      'Aktif',
                      true,
                    ),
                    // Hidden for SCRUM-5. Restore when Calculation Method
                    // returns to the Settings menu.
                    // _buildSettingsRow(
                    //   context,
                    //   c,
                    //   Icons.info_outline_rounded,
                    //   'Metode kalkulasi',
                    //   'Kemenag',
                    //   true,
                    // ),
                  ]),
                  _buildSection(context, c, 'LAINNYA', [
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.message_outlined,
                      'Kirim masukan',
                      null,
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.favorite_outline_rounded,
                      'Beri rating',
                      null,
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.share_outlined,
                      'Bagikan aplikasi',
                      null,
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.star_outline_rounded,
                      'Ikuti media sosial',
                      null,
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.help_outline_rounded,
                      'Bantuan',
                      null,
                      false,
                    ),
                    _buildSettingsRow(
                      context,
                      c,
                      Icons.lock_outline_rounded,
                      'Privasi',
                      null,
                      true,
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Text(
                      'Muslimate v1.0.0 • dibangun dengan ♥',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: c.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.goldSoft,
              ),
              child: Center(child: AppBrandMark(size: 32, color: c.goldDeep)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sahabat Muslimate',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.light.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mode tamu • Belum masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: c.gold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Masuk',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hidden for SCRUM-5. Restore this method with the Dark Mode setting.
  // Widget _buildDarkToggle(
  //   BuildContext context,
  //   AppColors c,
  //   SettingsProvider settings,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //     decoration: BoxDecoration(
  //       border: Border(bottom: BorderSide(color: c.hairline)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 32,
  //           height: 32,
  //           decoration: BoxDecoration(
  //             color: c.surfaceAlt,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(
  //             settings.isDark
  //                 ? Icons.nights_stay_rounded
  //                 : Icons.wb_sunny_rounded,
  //             color: c.gold,
  //             size: 17,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             'Tema gelap',
  //             style: GoogleFonts.plusJakartaSans(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: c.ink,
  //             ),
  //           ),
  //         ),
  //         AppToggle(
  //           value: settings.isDark,
  //           onChanged: (_) => settings.toggleDark(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSection(
    BuildContext context,
    AppColors c,
    String title,
    List<Widget> rows,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: c.inkMuted,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.hairline),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    AppColors c,
    IconData icon,
    String label,
    String? value,
    bool isLast,
  ) {
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: c.hairline)),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: c.gold, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: c.ink,
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: c.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(Icons.chevron_right_rounded, size: 16, color: c.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
