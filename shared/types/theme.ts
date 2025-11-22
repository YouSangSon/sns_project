export type ThemeMode = 'light' | 'dark' | 'auto';

export interface Theme {
  mode: ThemeMode;
  colors: ThemeColors;
}

export interface ThemeColors {
  // Background colors
  background: string;
  surface: string;
  card: string;

  // Text colors
  text: {
    primary: string;
    secondary: string;
    tertiary: string;
    inverse: string;
  };

  // Brand colors
  primary: string;
  secondary: string;
  accent: string;

  // Semantic colors
  success: string;
  warning: string;
  error: string;
  info: string;

  // Interactive colors
  link: string;
  like: string;

  // Border colors
  border: string;
  divider: string;

  // Shadow
  shadow: string;
}

export const lightTheme: ThemeColors = {
  background: '#FFFFFF',
  surface: '#F2F2F7',
  card: '#FFFFFF',

  text: {
    primary: '#000000',
    secondary: '#8E8E93',
    tertiary: '#C7C7CC',
    inverse: '#FFFFFF',
  },

  primary: '#007AFF',
  secondary: '#5856D6',
  accent: '#FF3B30',

  success: '#34C759',
  warning: '#FF9500',
  error: '#FF3B30',
  info: '#007AFF',

  link: '#007AFF',
  like: '#FF3B5C',

  border: '#E5E5EA',
  divider: '#C6C6C8',

  shadow: 'rgba(0, 0, 0, 0.1)',
};

export const darkTheme: ThemeColors = {
  background: '#000000',
  surface: '#1C1C1E',
  card: '#2C2C2E',

  text: {
    primary: '#FFFFFF',
    secondary: '#98989D',
    tertiary: '#636366',
    inverse: '#000000',
  },

  primary: '#0A84FF',
  secondary: '#5E5CE6',
  accent: '#FF453A',

  success: '#32D74B',
  warning: '#FF9F0A',
  error: '#FF453A',
  info: '#0A84FF',

  link: '#0A84FF',
  like: '#FF375F',

  border: '#38383A',
  divider: '#545456',

  shadow: 'rgba(0, 0, 0, 0.5)',
};
