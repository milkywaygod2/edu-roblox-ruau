# FEAT: Roblox Studio Script Sync 도입 메모

## 목적

Roblox Studio Team Create 수업에서 Explorer의 `Workspace`, `ServerScriptService`, `ReplicatedStorage` 구조와 로컬 파일 시스템의 관계를 명확히 정리한다. 이 문서는 로컬 repo의 Luau 파일을 Studio와 연결할지 판단할 때 기준으로 사용한다.

## 결론

Roblox Studio의 Explorer는 기본적으로 Windows 로컬 폴더와 자동 동기화되는 파일 시스템이 아니다. Team Create는 Studio 안의 DataModel 변경을 클라우드 협업 세션에 저장하는 기능이고, 로컬 repo 파일을 수정한다고 온라인 place가 바로 바뀌지는 않는다.

로컬 파일 편집을 Studio Script에 바로 반영하려면 Studio의 `Script Sync` 기능을 별도로 켜야 한다. 단, Script Sync는 `Script`, `LocalScript`, `ModuleScript`, `Folder` 인스턴스만 동기화한다. `Part`, `Model`, `MeshPart`, `Humanoid`, 물리 오브젝트 같은 일반 Workspace 인스턴스는 대상이 아니다.

## 구분

| 방식 | 로컬 파일 수정이 Studio에 바로 반영되는가? | 범위 |
| --- | --- | --- |
| Team Create 기본 | 아니오 | Studio DataModel 클라우드 협업 |
| Save to File / `.rbxl`, `.rbxlx` | 아니오 | 로컬 place 사본 저장 |
| Script Sync | 예 | Script, LocalScript, ModuleScript, Folder |
| Rojo 같은 외부 도구 | 예 | 프로젝트 설정에 따라 전체 DataModel 소스화 가능 |

## Studio에서 Script Sync 켜기

1. `File > Beta Features`를 연다.
2. `Script Sync`를 체크한다.
3. Studio가 재시작을 요구하면 재시작한다.
4. Explorer에서 동기화할 루트 폴더를 선택한다.
   - 예: `ReplicatedStorage`
   - 예: `ServerScriptService`
   - 예: `StarterPlayer > StarterPlayerScripts`
5. 선택한 폴더를 우클릭한다.
6. `Script Sync > Sync with Directory`를 선택한다.
7. 로컬 폴더를 지정한다.
8. 필요하면 다시 우클릭해서 `Script Sync > Reveal in Explorer`로 연결 폴더를 확인한다.

## 수업 repo 적용 판단

이 repo의 `lessons/`는 Studio Script Sync 연결을 전제로 Studio 서비스 구조를 미러링한다. Studio에서 다음 루트를 선택하고, Sync 대상 디렉터리는 repo의 `lessons` 폴더 하나로 지정한다.

- `ReplicatedStorage` -> `lessons/ReplicatedStorage`
- `ServerScriptService` -> `lessons/ServerScriptService`
- `StarterPlayer > StarterPlayerScripts` -> `lessons/StarterPlayerScripts`

루트 이름이 디스크 경로에 한 번 포함되므로 `ReplicatedStorage`를 `lessons/ReplicatedStorage`에 연결하지 않는다. 그렇게 연결하면 `lessons/ReplicatedStorage/ReplicatedStorage`처럼 중첩 폴더가 생길 수 있다.

현재 로컬 구조는 다음과 같다.

```text
lessons/
  ReplicatedStorage/
    Common/
      init.luau
      CoreEnums.luau
      ...
  ServerScriptService/
    TeacherSetup.server.luau
    StudentRockDesigns/
      01_student_answer.luau
    StudentBrickDesigns/
      02_student_answer.luau
    StudentResourceWallDesigns/
      03_student_answer.luau
    ...
    StudentFinalBattleDesigns/
      12_student_answer.luau
  StarterPlayerScripts/
    11_student_answer.local.luau
```

`Workspace/OutpostBattleWorld` 아래의 Part, Model, marker, 목표물은 현재처럼 `TeacherSetup`과 `Common`의 `ensure*` 함수가 Studio 안에서 생성/보장하게 둔다.

## 주의사항

- Script Sync는 스크립트와 폴더만 동기화하므로 Workspace 전체를 로컬 폴더처럼 다루면 안 된다.
- Team Create 협업 중 Script 편집은 Draft/Commit 흐름을 확인해야 한다.
- 파일명은 Studio Script Sync 규칙에 맞아야 한다.
  - `name.luau`: ModuleScript
  - `name.server.luau`: Script
  - `name.client.luau`: Client RunContext Script
  - `name.local.luau`: LocalScript
  - `name/`: Folder
- 전체 DataModel을 로컬 소스 기준으로 관리하려면 Script Sync보다 Rojo 도입을 별도 검토한다.

## 참고

- Roblox Collaboration / Team Create: https://create.roblox.com/docs/projects/collaboration
- Roblox Script Sync: https://create.roblox.com/docs/scripting/sync
- Roblox Place files: https://create.roblox.com/docs/projects/place-files
