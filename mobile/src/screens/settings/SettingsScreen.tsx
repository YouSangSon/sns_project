import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../../contexts/ThemeContext';
import { useAuthStore } from '../../stores/authStore';
import type { ThemeMode } from '@shared/types/theme';

export default function SettingsScreen() {
  const { mode, setThemeMode, colors, isDark } = useTheme();
  const { user, logout } = useAuthStore();

  const handleLogout = () => {
    Alert.alert('로그아웃', '정말 로그아웃 하시겠습니까?', [
      { text: '취소', style: 'cancel' },
      {
        text: '로그아웃',
        style: 'destructive',
        onPress: logout,
      },
    ]);
  };

  const themeOptions: { value: ThemeMode; label: string; icon: string }[] = [
    { value: 'light', label: '라이트 모드', icon: 'sunny' },
    { value: 'dark', label: '다크 모드', icon: 'moon' },
    { value: 'auto', label: '시스템 설정', icon: 'phone-portrait' },
  ];

  return (
    <ScrollView style={[styles.container, { backgroundColor: colors.surface }]}>
      {/* User Info */}
      <View style={[styles.section, { backgroundColor: colors.card }]}>
        <View style={styles.userInfo}>
          <View style={[styles.avatar, { backgroundColor: colors.primary }]}>
            <Text style={[styles.avatarText, { color: colors.text.inverse }]}>
              {user?.username?.[0]?.toUpperCase() || 'U'}
            </Text>
          </View>
          <View style={styles.userDetails}>
            <Text style={[styles.userName, { color: colors.text.primary }]}>
              {user?.fullName || '사용자'}
            </Text>
            <Text style={[styles.userEmail, { color: colors.text.secondary }]}>
              {user?.email || ''}
            </Text>
          </View>
        </View>
      </View>

      {/* Appearance */}
      <View style={[styles.section, { backgroundColor: colors.card }]}>
        <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>
          화면 설정
        </Text>

        {themeOptions.map((option) => (
          <TouchableOpacity
            key={option.value}
            style={[
              styles.themeOption,
              mode === option.value && {
                backgroundColor: isDark ? colors.surface : colors.surface,
                borderColor: colors.primary,
                borderWidth: 2,
              },
            ]}
            onPress={() => setThemeMode(option.value)}
          >
            <View style={styles.themeOptionContent}>
              <Ionicons
                name={option.icon as any}
                size={24}
                color={mode === option.value ? colors.primary : colors.text.secondary}
              />
              <Text
                style={[
                  styles.themeOptionLabel,
                  {
                    color:
                      mode === option.value ? colors.primary : colors.text.primary,
                  },
                ]}
              >
                {option.label}
              </Text>
            </View>
            {mode === option.value && (
              <Ionicons name="checkmark-circle" size={24} color={colors.primary} />
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* General Settings */}
      <View style={[styles.section, { backgroundColor: colors.card }]}>
        <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>
          일반
        </Text>

        <TouchableOpacity
          style={[styles.settingItem, { borderBottomColor: colors.border }]}
        >
          <View style={styles.settingItemContent}>
            <Ionicons name="notifications-outline" size={24} color={colors.text.primary} />
            <Text style={[styles.settingItemLabel, { color: colors.text.primary }]}>
              알림 설정
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text.secondary} />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.settingItem, { borderBottomColor: colors.border }]}
        >
          <View style={styles.settingItemContent}>
            <Ionicons name="lock-closed-outline" size={24} color={colors.text.primary} />
            <Text style={[styles.settingItemLabel, { color: colors.text.primary }]}>
              개인정보 및 보안
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text.secondary} />
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.settingItem, { borderBottomWidth: 0 }]}
        >
          <View style={styles.settingItemContent}>
            <Ionicons name="language-outline" size={24} color={colors.text.primary} />
            <Text style={[styles.settingItemLabel, { color: colors.text.primary }]}>
              언어
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text.secondary} />
        </TouchableOpacity>
      </View>

      {/* About */}
      <View style={[styles.section, { backgroundColor: colors.card }]}>
        <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>
          정보
        </Text>

        <TouchableOpacity
          style={[styles.settingItem, { borderBottomColor: colors.border }]}
        >
          <View style={styles.settingItemContent}>
            <Ionicons name="information-circle-outline" size={24} color={colors.text.primary} />
            <Text style={[styles.settingItemLabel, { color: colors.text.primary }]}>
              앱 정보
            </Text>
          </View>
          <Text style={[styles.versionText, { color: colors.text.secondary }]}>
            v1.0.0
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.settingItem, { borderBottomWidth: 0 }]}
        >
          <View style={styles.settingItemContent}>
            <Ionicons name="document-text-outline" size={24} color={colors.text.primary} />
            <Text style={[styles.settingItemLabel, { color: colors.text.primary }]}>
              이용약관
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={colors.text.secondary} />
        </TouchableOpacity>
      </View>

      {/* Logout */}
      <TouchableOpacity
        style={[styles.logoutButton, { backgroundColor: colors.card }]}
        onPress={handleLogout}
      >
        <Ionicons name="log-out-outline" size={24} color={colors.error} />
        <Text style={[styles.logoutText, { color: colors.error }]}>로그아웃</Text>
      </TouchableOpacity>

      <View style={styles.footer}>
        <Text style={[styles.footerText, { color: colors.text.tertiary }]}>
          SNS App v1.0.0
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  section: {
    marginBottom: 12,
    padding: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 16,
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  avatarText: {
    fontSize: 28,
    fontWeight: '700',
  },
  userDetails: {
    flex: 1,
  },
  userName: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 14,
  },
  themeOption: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  themeOptionContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  themeOptionLabel: {
    fontSize: 16,
    fontWeight: '600',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 16,
    borderBottomWidth: 1,
  },
  settingItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  settingItemLabel: {
    fontSize: 16,
  },
  versionText: {
    fontSize: 14,
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    gap: 8,
    marginBottom: 12,
  },
  logoutText: {
    fontSize: 16,
    fontWeight: '600',
  },
  footer: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  footerText: {
    fontSize: 12,
  },
});
