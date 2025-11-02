import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold가 화면의 기본 구조를 잡아줍니다.
    return Scaffold(
      backgroundColor: Colors.grey[100], // 홈 화면과 동일한 배경색

      // 1. 앱바 (AppBar)
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: false,
      ),

      // 2. 메인 컨텐츠
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2-1. 프로필 헤더 (아바타, 이름, 이메일)
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // 2-2. 첫 번째 설정 카드 (정보 수정, 알림, 언어)
            _buildSettingsCard(
              children: [
                _buildSettingsRow(Icons.account_circle, '정보 수정'),
                _buildSettingsRow(Icons.notifications_none, '알림',
                    trailing: Switch(
                      value: true, // (임시) 실제로는 상태 변수 필요
                      onChanged: (value) {},
                      activeColor: Colors.blueAccent,
                    )),
                _buildSettingsRow(Icons.language, '언어',
                    trailing: const Text(
                      '한국어',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // 2-3. 두 번째 설정 카드 (연동 기기, 모드 전환)
            _buildSettingsCard(
              children: [
                _buildSettingsRow(Icons.devices_other, '연동 기기'),
                _buildSettingsRow(Icons.light_mode, '모드 전환',
                    trailing: const Text(
                      'Light mode',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // 2-4. 세 번째 설정 카드 (지원, 신고, 개인정보)
            _buildSettingsCard(
              children: [
                _buildSettingsRow(Icons.support_agent, '지원 요청'),
                _buildSettingsRow(Icons.chat_bubble_outline, '문제 신고'),
                _buildSettingsRow(Icons.privacy_tip_outlined, '개인정보 보호'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 위젯 분리: 프로필 헤더 ----------
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 60, // ★ radius(반지름) 60 = 지름(가로세로) 120
              backgroundImage: const AssetImage(
                  'assets/images/my_profile_avatar.png'
              ),
              // 이미지가 로드되기 전이나 없을 때 배경색
              backgroundColor: Colors.grey[200],
            ),
            // 수정 아이콘 버튼
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.edit, color: Colors.black, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '김미리',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'youremail@domain.com | +01 234 567 89',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ---------- 위젯 분리: 재사용 가능한 설정 카드 ----------
  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0, // 그림자 없음
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // ---------- 위젯 분리: 재사용 가능한 설정 행(Row) ----------
  Widget _buildSettingsRow(IconData icon, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (trailing != null) trailing, // Switch나 Text 같은 오른쪽 위젯
          if (trailing == null) // 기본값은 > 아이콘
            Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}