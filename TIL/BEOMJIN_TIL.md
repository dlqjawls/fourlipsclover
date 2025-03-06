개인별 TIL.md 를 만들어서 기록(6주)

# 1주차 flutter 환경 세팅

## Flutter 개발 환경 세팅 (VSCode & Android Studio)

### 1. Flutter SDK 설치

- [Flutter SDK 다운로드](https://flutter.dev/docs/get-started/install)
- 설치된 SDK를 원하는 디렉터리에 압축 해제

> **중요**: `C:\Program Files` 경로에 설치하면 권한 문제로 프로젝트 생성 및 관리 시 오류가 발생할 수 있으므로 다른 경로 (예: `C:\dev\flutter`)에 설치하는 것을 권장합니다.

### 2. 환경 변수 설정

- Windows 환경변수 편집에서 시스템 환경 변수의 `Path`에 Flutter의 bin 경로를 추가합니다.

예시 경로:

```
C:\dev\flutter\bin
```

### 3. VSCode 설정

- VSCode의 확장 프로그램 탭에서 다음 플러그인을 설치합니다:

```
Flutter
Dart
```

- 설치 후 VSCode를 재시작합니다.

### 4. Android Studio 설정

- Android Studio를 설치한 후 실행

- SDK Manager로 이동 (`Settings` > `Appearance & Behavior` > `System Settings` > `Android SDK`)

- 다음 SDK 구성 요소를 설치합니다:

  - Android SDK Platform 최신 버전
  - Android SDK Command-line Tools
  - Android SDK Build-Tools 최신 버전

- 설치가 끝나면 하단의 `Apply`를 클릭하여 적용합니다.

### 5. Android 기기 연결 및 설정

- Android Studio의 가상 디바이스 관리자(AVD Manager)를 사용하여 가상 디바이스 생성하거나 실제 안드로이드 기기를 USB 연결로 준비합니다.
- USB 디버깅 활성화 (`개발자 옵션`에서 `USB 디버깅` 활성화)

### 6. 환경 확인

터미널 또는 명령 프롬프트에서 다음 명령으로 환경 설정 상태 확인

```bash
flutter doctor
```

안드로이드 라이선스에 대한 동의 진행:

```bash
flutter doctor --android-licenses
```

모든 질문에 대해 `y`로 답변하여 동의 완료

### 7. 프로젝트 생성 및 실행

VSCode에서 다음 명령으로 Flutter 프로젝트 생성

```bash
flutter create 프로젝트명
```

생성된 프로젝트 폴더로 이동 후 앱 실행

```bash
cd 프로젝트명
flutter run
```

이제 Flutter 환경 세팅이 완료

