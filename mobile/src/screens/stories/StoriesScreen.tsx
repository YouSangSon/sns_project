import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
  Dimensions,
  ActivityIndicator,
  Pressable,
  Animated,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import type { RouteProp } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { useUserStories, useViewStory } from '../../hooks/useStories';
import type { Story } from '@shared/types';
import type { RootStackParamList } from '../../navigation/types';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

const COLORS = {
  background: '#000',
  text: '#fff',
  textSecondary: '#bbb',
  overlay: 'rgba(0, 0, 0, 0.3)',
};

const STORY_DURATION = 5000; // 5 seconds

type StoriesScreenRouteProp = RouteProp<RootStackParamList, 'Stories'>;
type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const StoriesScreen = () => {
  const route = useRoute<StoriesScreenRouteProp>();
  const navigation = useNavigation<NavigationProp>();
  const { userId } = route.params;

  const { data: stories, isLoading } = useUserStories(userId);
  const viewStoryMutation = useViewStory();

  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const progressAnims = useRef<Animated.Value[]>([]).current;
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  const currentStory = stories?.[currentIndex];

  // Initialize progress animations
  useEffect(() => {
    if (stories) {
      progressAnims.splice(0, progressAnims.length);
      stories.forEach(() => {
        progressAnims.push(new Animated.Value(0));
      });
    }
  }, [stories]);

  // Mark story as viewed when displayed
  useEffect(() => {
    if (currentStory) {
      viewStoryMutation.mutate(currentStory.storyId);
    }
  }, [currentStory?.storyId]);

  // Auto-advance timer
  useEffect(() => {
    if (!currentStory || isPaused) return;

    const duration = currentStory.duration || STORY_DURATION;

    // Start progress animation
    Animated.timing(progressAnims[currentIndex], {
      toValue: 1,
      duration,
      useNativeDriver: false,
    }).start();

    // Set timer to advance
    timerRef.current = setTimeout(() => {
      handleNext();
    }, duration);

    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }
      Animated.timing(progressAnims[currentIndex]).stop();
    };
  }, [currentIndex, isPaused, currentStory]);

  const handleNext = () => {
    if (!stories) return;

    if (currentIndex < stories.length - 1) {
      progressAnims[currentIndex].setValue(1);
      setCurrentIndex(currentIndex + 1);
    } else {
      navigation.goBack();
    }
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      progressAnims[currentIndex].setValue(0);
      setCurrentIndex(currentIndex - 1);
    } else {
      navigation.goBack();
    }
  };

  const handlePressIn = () => {
    setIsPaused(true);
  };

  const handlePressOut = () => {
    setIsPaused(false);
  };

  const handleLeftPress = () => {
    handlePrevious();
  };

  const handleRightPress = () => {
    handleNext();
  };

  if (isLoading || !stories || stories.length === 0) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={COLORS.text} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Story Image/Video */}
      {currentStory && (
        <Image
          source={{ uri: currentStory.mediaUrl }}
          style={styles.media}
          resizeMode="contain"
        />
      )}

      {/* Dark overlay for better text visibility */}
      <View style={styles.overlay} />

      {/* Progress bars */}
      <View style={styles.progressContainer}>
        {stories.map((_, index) => (
          <View key={index} style={styles.progressBar}>
            <Animated.View
              style={[
                styles.progressFill,
                {
                  width: progressAnims[index]?.interpolate({
                    inputRange: [0, 1],
                    outputRange: ['0%', '100%'],
                  }) || '0%',
                },
                index < currentIndex && styles.progressComplete,
              ]}
            />
          </View>
        ))}
      </View>

      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          {currentStory?.userPhotoUrl ? (
            <Image
              source={{ uri: currentStory.userPhotoUrl }}
              style={styles.avatar}
            />
          ) : (
            <View style={[styles.avatar, styles.avatarPlaceholder]}>
              <Ionicons name="person" size={16} color={COLORS.textSecondary} />
            </View>
          )}
          <View style={styles.headerTextContainer}>
            <Text style={styles.username}>{currentStory?.username}</Text>
            <Text style={styles.timestamp}>
              {currentStory && new Date(currentStory.createdAt).toLocaleTimeString()}
            </Text>
          </View>
        </View>

        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.closeButton}
        >
          <Ionicons name="close" size={28} color={COLORS.text} />
        </TouchableOpacity>
      </View>

      {/* Touch areas for navigation */}
      <View style={styles.touchContainer}>
        <Pressable
          style={styles.touchLeft}
          onPress={handleLeftPress}
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
        />
        <Pressable
          style={styles.touchRight}
          onPress={handleRightPress}
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
        />
      </View>

      {/* Story info */}
      {currentStory && (
        <View style={styles.footer}>
          <View style={styles.viewsContainer}>
            <Ionicons name="eye" size={16} color={COLORS.text} />
            <Text style={styles.viewsText}>{currentStory.views} views</Text>
          </View>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  media: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: COLORS.overlay,
  },
  progressContainer: {
    position: 'absolute',
    top: 50,
    left: 8,
    right: 8,
    flexDirection: 'row',
    gap: 4,
    zIndex: 10,
  },
  progressBar: {
    flex: 1,
    height: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 1,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: COLORS.text,
  },
  progressComplete: {
    width: '100%',
  },
  header: {
    position: 'absolute',
    top: 60,
    left: 16,
    right: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    zIndex: 10,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    marginRight: 12,
  },
  avatarPlaceholder: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTextContainer: {
    justifyContent: 'center',
  },
  username: {
    fontSize: 15,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  timestamp: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  closeButton: {
    padding: 4,
  },
  touchContainer: {
    ...StyleSheet.absoluteFillObject,
    flexDirection: 'row',
    zIndex: 5,
  },
  touchLeft: {
    flex: 1,
  },
  touchRight: {
    flex: 1,
  },
  footer: {
    position: 'absolute',
    bottom: 40,
    left: 16,
    right: 16,
    zIndex: 10,
  },
  viewsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  viewsText: {
    fontSize: 14,
    color: COLORS.text,
    marginLeft: 6,
  },
});

export default StoriesScreen;
