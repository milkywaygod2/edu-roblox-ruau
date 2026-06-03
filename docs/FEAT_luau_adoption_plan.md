# FEAT: Luau (.luau) 확장자 및 런타임 도입 계획

이 문서는 수업용 공통 모듈 및 프로젝트 코드베이스에 로블록스 공식 확장자 규격인 Luau(`.luau`)를 도입할 때의 기술적 이점과 실행 계획을 정리한 문서입니다.

---

## 1. 도입 배경

현재 프로젝트의 파일들은 전통적인 `.lua` 확장자를 사용하고 있습니다. 그러나 로블록스 엔진은 내부적으로 표준 Lua 5.1이 아닌 자체 파생 언어인 **Luau**를 사용하므로, 에디터 및 빌드 도구가 로컬 소스를 정확히 인지할 수 있도록 점진적인 확장자 마이그레이션이 필요합니다.

---

## 2. Luau 도입의 기술적 이점

### 1) 완벽한 Roblox API 자동완성 (Luau LSP)
*   일반 `.lua` 확장자는 VS Code 등의 에디터에서 표준 Lua(Lua 5.1/5.3) 린터 및 LSP로 인식되어 `game`, `workspace`, `Enum` 등 로블록스 전용 전역 객체에 경고(빨간 줄)가 발생합니다.
*   `.luau` 확장자로 지정할 경우, 에디터가 이를 **로블록스 Luau 코드**로 정확히 판정하여 완벽한 오토컴플리트(Autocomplete) 및 호버 힌트를 지원합니다.

### 2) Roblox Studio Script Sync 공식 호환
*   로블록스 스튜디오의 내장 `Script Sync` 베타 기능은 파일명을 기준으로 인스턴스 타입을 매핑합니다.
    *   `Filename.luau` ➔ **ModuleScript**
    *   `Filename.server.luau` ➔ **Script**
    *   `Filename.client.luau` ➔ **LocalScript (Client RunContext)**
*   확장자를 Luau 규격에 일치시켜야 동기화 도구 오작동 및 타입 미매칭 오류를 미연에 방지할 수 있습니다.

### 3) 정적 타입 시스템 사용 가능
*   Luau 고유의 강력한 정적 타입 시스템(`local speed: number = 10`)을 에러 경고 없이 로컬 파일 시스템에서 온전히 사용할 수 있어 오타 및 타입 불일치 버그를 정적으로 사전에 방지합니다.

---

## 4. 파일 구조 및 확장자 마이그레이션 예시

전환 시 프로젝트의 `lessons/` 내부 구조는 다음과 같이 변경됩니다.

```text
lessons/
  Common.lua                ➔   Common.luau
  Common/
    EngineNames.lua         ➔   EngineNames.luau
    EngineEnsure.lua        ➔   EngineEnsure.luau
    StudentConfig.lua       ➔   StudentConfig.luau
    ... (하위 15개 모듈)
  teacher_setup.server.lua  ➔   teacher_setup.server.luau
```

*   **호환성 보장**: 하위 모듈 내에서 타 모듈을 호출하는 `require(script.Parent:WaitForChild("EngineNames"))` 등은 스튜디오 인스턴스 이름 기준(확장자 미포함)이므로, 파일 확장자만 `.luau`로 일제히 수정해도 내부 의존성 링크는 전혀 깨지지 않습니다.

---

## 5. 실행 로드맵 및 주의사항

1.  **사전 준비**:
    *   수업 참가자 및 에디터(VS Code 등)에 `Luau LSP` 또는 `Roblox LSP` 확장이 정상 활성화되었는지 확인합니다.
2.  **도구 검토**:
    *   Rojo 또는 Script Sync 등 사용할 동기화 도구의 버전이 `.luau` 확장자를 온전히 파싱할 수 있는지 베타 상태를 체크합니다.
3.  **일괄 전환**:
    *   전환 도구(스크립트)를 활용하여 `lessons/` 하위 파일의 확장자를 일시에 변경하고, `README.md` 가이드 문서도 동시에 현행화합니다.
4.  **하위 호환 테스트**:
    *   로블록스 플레이스에 연동 후, 기존의 학생/교사 스크립트가 모듈을 끊김 없이 정상 require하는지 Studio Play로 최종 서명 검증합니다.
