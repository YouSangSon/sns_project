# 비디오 녹화 및 편집 가이드

SNS 앱에서 Reels(릴스) 기능을 위한 비디오 녹화 및 편집 설정입니다.

## 📹 패키지 설치

### Mobile (React Native / Expo)

```bash
cd mobile
npx expo install expo-camera expo-av expo-media-library expo-video-thumbnails
```

## 🎥 기본 비디오 녹화 구현

### 1. VideoRecordingScreen.tsx

```typescript
import React, { useState, useRef } from 'react';
import { View, TouchableOpacity, Text } from 'react-native';
import { Camera, CameraType } from 'expo-camera';
import { Video } from 'expo-av';

export default function VideoRecordingScreen() {
  const cameraRef = useRef<Camera>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [videoUri, setVideoUri] = useState<string | null>(null);
  const [cameraType, setCameraType] = useState(CameraType.back);
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);

  // 권한 요청
  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      const audioStatus = await Camera.requestMicrophonePermissionsAsync();
      setHasPermission(status === 'granted' && audioStatus.status === 'granted');
    })();
  }, []);

  // 녹화 시작
  const startRecording = async () => {
    if (cameraRef.current) {
      setIsRecording(true);
      const video = await cameraRef.current.recordAsync({
        maxDuration: 60, // 최대 60초
        quality: Camera.Constants.VideoQuality['720p'],
      });
      setVideoUri(video.uri);
      setIsRecording(false);
    }
  };

  // 녹화 중지
  const stopRecording = () => {
    if (cameraRef.current && isRecording) {
      cameraRef.current.stopRecording();
    }
  };

  // 카메라 전환
  const toggleCameraType = () => {
    setCameraType(current =>
      current === CameraType.back ? CameraType.front : CameraType.back
    );
  };

  if (hasPermission === null) {
    return <View />;
  }

  if (hasPermission === false) {
    return <Text>카메라 및 마이크 권한이 필요합니다.</Text>;
  }

  return (
    <View style={{ flex: 1 }}>
      {!videoUri ? (
        <>
          <Camera
            ref={cameraRef}
            style={{ flex: 1 }}
            type={cameraType}
          >
            {/* 카메라 UI */}
          </Camera>

          {/* 녹화 버튼 */}
          <TouchableOpacity
            onPress={isRecording ? stopRecording : startRecording}
          >
            <Text>{isRecording ? '중지' : '녹화'}</Text>
          </TouchableOpacity>

          {/* 카메라 전환 버튼 */}
          <TouchableOpacity onPress={toggleCameraType}>
            <Text>카메라 전환</Text>
          </TouchableOpacity>
        </>
      ) : (
        <>
          {/* 비디오 미리보기 */}
          <Video
            source={{ uri: videoUri }}
            style={{ flex: 1 }}
            useNativeControls
            resizeMode="contain"
          />

          {/* 재촬영 버튼 */}
          <TouchableOpacity onPress={() => setVideoUri(null)}>
            <Text>재촬영</Text>
          </TouchableOpacity>

          {/* 업로드 버튼 */}
          <TouchableOpacity onPress={() => {/* 업로드 로직 */}}>
            <Text>업로드</Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}
```

## ✂️ 비디오 편집 기능

### 1. 기본 편집 기능

```typescript
import * as VideoThumbnails from 'expo-video-thumbnails';
import { manipulateAsync, SaveFormat } from 'expo-image-manipulator';

// 썸네일 생성
export async function generateThumbnail(videoUri: string) {
  try {
    const { uri } = await VideoThumbnails.getThumbnailAsync(videoUri, {
      time: 1000, // 1초 지점
    });
    return uri;
  } catch (e) {
    console.warn(e);
  }
}

// 비디오 트리밍 (expo-av 사용)
export async function trimVideo(
  videoUri: string,
  start: number,
  end: number
) {
  // FFmpeg 또는 네이티브 모듈 필요
  // react-native-video-processing 사용 권장
}
```

### 2. 고급 편집 (추천 라이브러리)

#### FFmpeg 사용

```bash
npm install react-native-ffmpeg
```

```typescript
import { RNFFmpeg } from 'react-native-ffmpeg';

// 비디오 트리밍
await RNFFmpeg.execute(
  `-i ${inputPath} -ss ${startTime} -to ${endTime} -c copy ${outputPath}`
);

// 필터 적용 (밝기, 대비 등)
await RNFFmpeg.execute(
  `-i ${inputPath} -vf "eq=brightness=0.06:saturation=2" ${outputPath}`
);

// 오디오 추가
await RNFFmpeg.execute(
  `-i ${videoPath} -i ${audioPath} -c:v copy -c:a aac ${outputPath}`
);
```

## 🎨 비디오 필터 및 효과

### 1. 기본 필터

```typescript
export const VIDEO_FILTERS = {
  none: 'eq=brightness=0:saturation=1',
  vivid: 'eq=saturation=2',
  warm: 'eq=contrast=1.2:saturation=1.5',
  cool: 'colorbalance=rs=-0.3:gs=0:bs=0.3',
  vintage: 'curves=vintage',
  blackAndWhite: 'hue=s=0',
};

export async function applyFilter(videoUri: string, filter: string) {
  const command = `-i ${videoUri} -vf "${filter}" ${outputPath}`;
  await RNFFmpeg.execute(command);
}
```

### 2. 텍스트 오버레이

```typescript
export async function addTextOverlay(
  videoUri: string,
  text: string,
  position: { x: number; y: number }
) {
  const filter = `drawtext=text='${text}':x=${position.x}:y=${position.y}:fontsize=24:fontcolor=white`;
  const command = `-i ${videoUri} -vf "${filter}" ${outputPath}`;
  await RNFFmpeg.execute(command);
}
```

## 📦 압축 및 최적화

```typescript
export async function compressVideo(videoUri: string, quality: 'low' | 'medium' | 'high') {
  const bitrateMap = {
    low: '500k',
    medium: '1500k',
    high: '3000k',
  };

  const command = `-i ${videoUri} -b:v ${bitrateMap[quality]} -c:a copy ${outputPath}`;
  await RNFFmpeg.execute(command);
}
```

## 🎵 오디오 관리

### 1. 배경 음악 추가

```typescript
export async function addBackgroundMusic(
  videoUri: string,
  audioUri: string,
  volume: number = 0.5
) {
  const command = `-i ${videoUri} -i ${audioUri} -filter_complex "[1:a]volume=${volume}[a1];[0:a][a1]amix=inputs=2:duration=first" -c:v copy ${outputPath}`;
  await RNFFmpeg.execute(command);
}
```

### 2. 음소거

```typescript
export async function muteVideo(videoUri: string) {
  const command = `-i ${videoUri} -c:v copy -an ${outputPath}`;
  await RNFFmpeg.execute(command);
}
```

## 💾 저장 및 공유

### 1. 미디어 라이브러리에 저장

```typescript
import * as MediaLibrary from 'expo-media-library';

export async function saveToLibrary(videoUri: string) {
  const { status } = await MediaLibrary.requestPermissionsAsync();
  if (status === 'granted') {
    await MediaLibrary.createAssetAsync(videoUri);
  }
}
```

### 2. 서버 업로드

```typescript
export async function uploadVideo(videoUri: string) {
  const formData = new FormData();
  formData.append('video', {
    uri: videoUri,
    type: 'video/mp4',
    name: 'reel.mp4',
  } as any);

  const response = await fetch('https://api.example.com/upload', {
    method: 'POST',
    body: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });

  return response.json();
}
```

## 🛠️ 권장 패키지

- **expo-camera**: 카메라 접근 및 녹화
- **expo-av**: 비디오 재생 및 기본 조작
- **expo-media-library**: 미디어 저장
- **expo-video-thumbnails**: 썸네일 생성
- **react-native-ffmpeg**: 고급 편집 (트리밍, 필터, 합성)
- **react-native-video-processing**: 비디오 편집
- **react-native-compressor**: 비디오 압축

## 📱 app.json 설정

```json
{
  "expo": {
    "plugins": [
      [
        "expo-camera",
        {
          "cameraPermission": "앱에서 카메라를 사용하여 비디오를 촬영합니다."
        }
      ],
      [
        "expo-media-library",
        {
          "photosPermission": "앱에서 비디오를 저장합니다.",
          "savePhotosPermission": "앱에서 비디오를 저장합니다."
        }
      ]
    ]
  }
}
```

## 🎬 Reels 화면 예시

```typescript
// ReelsCreatorScreen.tsx
export default function ReelsCreatorScreen() {
  return (
    <View>
      {/* 1. 비디오 녹화/선택 */}
      {/* 2. 편집 (트리밍, 필터, 텍스트) */}
      {/* 3. 음악 추가 */}
      {/* 4. 미리보기 */}
      {/* 5. 업로드 */}
    </View>
  );
}
```

## 📚 참고 자료

- [Expo Camera Documentation](https://docs.expo.dev/versions/latest/sdk/camera/)
- [Expo AV Documentation](https://docs.expo.dev/versions/latest/sdk/av/)
- [FFmpeg Filters](https://ffmpeg.org/ffmpeg-filters.html)
- [React Native Video Processing](https://github.com/shahen94/react-native-video-processing)

---

Made with ❤️ for SNS App
