import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Image,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  SafeAreaView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { useImagePicker } from '../../hooks/useImagePicker';
import { useCreatePost } from '../../hooks/usePosts';
import type { CreatePostDto } from '@shared/types';

export const CreatePostScreen = () => {
  const navigation = useNavigation();
  const { selectedImages, pickImages, removeImage, clearImages } = useImagePicker(10);
  const createPostMutation = useCreatePost();

  const [caption, setCaption] = useState('');
  const [location, setLocation] = useState('');

  const handlePost = async () => {
    if (selectedImages.length === 0) {
      Alert.alert('No Images', 'Please select at least one image.');
      return;
    }

    try {
      // Convert local URIs to base64 or upload to server
      // For now, we'll use the URIs directly (in production, you'd upload to S3/CDN)
      const postData: CreatePostDto = {
        caption: caption.trim(),
        imageUrls: selectedImages, // In production, these would be uploaded first
        location: location.trim() || undefined,
      };

      await createPostMutation.mutateAsync(postData);

      Alert.alert('Success', 'Post created successfully!', [
        {
          text: 'OK',
          onPress: () => {
            clearImages();
            setCaption('');
            setLocation('');
            navigation.goBack();
          },
        },
      ]);
    } catch (error) {
      console.error('Error creating post:', error);
      Alert.alert('Error', 'Failed to create post. Please try again.');
    }
  };

  const handleCancel = () => {
    if (selectedImages.length > 0 || caption.trim() || location.trim()) {
      Alert.alert('Discard Post?', 'Are you sure you want to discard this post?', [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Discard',
          style: 'destructive',
          onPress: () => {
            clearImages();
            setCaption('');
            setLocation('');
            navigation.goBack();
          },
        },
      ]);
    } else {
      navigation.goBack();
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={handleCancel} style={styles.headerButton}>
          <Ionicons name="close" size={28} color="#000" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>New Post</Text>
        <TouchableOpacity
          onPress={handlePost}
          disabled={createPostMutation.isPending || selectedImages.length === 0}
          style={styles.headerButton}
        >
          {createPostMutation.isPending ? (
            <ActivityIndicator color="#3897f0" />
          ) : (
            <Text
              style={[
                styles.postButton,
                (createPostMutation.isPending || selectedImages.length === 0) &&
                  styles.postButtonDisabled,
              ]}
            >
              Post
            </Text>
          )}
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content}>
        {/* Image Selection */}
        <TouchableOpacity style={styles.imagePickerButton} onPress={pickImages}>
          <Ionicons name="images-outline" size={32} color="#3897f0" />
          <Text style={styles.imagePickerText}>
            {selectedImages.length === 0
              ? 'Select Images'
              : `${selectedImages.length} image${selectedImages.length > 1 ? 's' : ''} selected`}
          </Text>
        </TouchableOpacity>

        {/* Selected Images Preview */}
        {selectedImages.length > 0 && (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            style={styles.imagePreviewContainer}
          >
            {selectedImages.map((uri, index) => (
              <View key={index} style={styles.imagePreviewWrapper}>
                <Image source={{ uri }} style={styles.imagePreview} />
                <TouchableOpacity
                  style={styles.removeImageButton}
                  onPress={() => removeImage(index)}
                >
                  <Ionicons name="close-circle" size={24} color="#fff" />
                </TouchableOpacity>
              </View>
            ))}
          </ScrollView>
        )}

        {/* Caption Input */}
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Caption</Text>
          <TextInput
            style={styles.captionInput}
            placeholder="Write a caption..."
            value={caption}
            onChangeText={setCaption}
            multiline
            maxLength={2200}
          />
          <Text style={styles.characterCount}>{caption.length}/2200</Text>
        </View>

        {/* Location Input */}
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Location</Text>
          <TextInput
            style={styles.locationInput}
            placeholder="Add location"
            value={location}
            onChangeText={setLocation}
            maxLength={100}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#dbdbdb',
  },
  headerButton: {
    width: 60,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  postButton: {
    fontSize: 16,
    fontWeight: '600',
    color: '#3897f0',
  },
  postButtonDisabled: {
    color: '#b2dffc',
  },
  content: {
    flex: 1,
  },
  imagePickerButton: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
    margin: 16,
    borderWidth: 2,
    borderColor: '#3897f0',
    borderRadius: 8,
    borderStyle: 'dashed',
  },
  imagePickerText: {
    marginTop: 8,
    fontSize: 16,
    color: '#3897f0',
    fontWeight: '500',
  },
  imagePreviewContainer: {
    paddingHorizontal: 16,
    marginBottom: 16,
  },
  imagePreviewWrapper: {
    position: 'relative',
    marginRight: 12,
  },
  imagePreview: {
    width: 100,
    height: 100,
    borderRadius: 8,
  },
  removeImageButton: {
    position: 'absolute',
    top: -8,
    right: -8,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    borderRadius: 12,
  },
  inputContainer: {
    paddingHorizontal: 16,
    marginBottom: 24,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  captionInput: {
    fontSize: 16,
    minHeight: 100,
    textAlignVertical: 'top',
    borderWidth: 1,
    borderColor: '#dbdbdb',
    borderRadius: 8,
    padding: 12,
  },
  characterCount: {
    textAlign: 'right',
    marginTop: 4,
    fontSize: 12,
    color: '#8e8e8e',
  },
  locationInput: {
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#dbdbdb',
    borderRadius: 8,
    padding: 12,
  },
});
