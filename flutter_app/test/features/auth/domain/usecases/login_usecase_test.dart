import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sns_app/core/errors/failures.dart';
import 'package:sns_app/features/auth/domain/entities/user_entity.dart';
import 'package:sns_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sns_app/features/auth/domain/usecases/login_usecase.dart';

import '../../../../helpers/test_data.dart';
import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const String testEmail = TestData.testEmail;
    const String testPassword = TestData.testPassword;

    final UserEntity testUser = UserEntity(
      id: TestData.testUserId,
      email: TestData.testEmail,
      username: TestData.testUsername,
      displayName: TestData.testDisplayName,
      bio: TestData.testBio,
      profileImageUrl: TestData.testProfileImage,
      followersCount: 100,
      followingCount: 50,
      postsCount: 25,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    test('로그인 성공 시 UserEntity를 반환해야 한다', () async {
      // Arrange
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.login(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('로그인 실패 시 ServerFailure를 반환해야 한다', () async {
      // Arrange
      final failure = Failure.server(message: 'Invalid credentials');
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.login(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('네트워크 오류 시 NetworkFailure를 반환해야 한다', () async {
      // Arrange
      const failure = Failure.network();
      when(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.login(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });
  });
}
