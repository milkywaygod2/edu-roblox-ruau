# Roblox 아바타 에셋, 액세서리, 신체 부위 가이드

이 문서는 수업 프로젝트에서 "룩을 입히는" 컨텐츠를 설계하기 전에 필요한 Roblox 3D 에셋 용어와 임포트 흐름을 정리한다. 결론부터 말하면, 수업용 첫 구현은 **외부 Asset ID를 학생이 직접 쓰는 방식이 아니라, 선생님이 미리 Studio에 넣어 둔 로컬 액세서리/메시를 학생이 이름으로 조합하는 방식**이 가장 안정적이다.

## 1. 용어 정리

| 용어 | 의미 | 수업 프로젝트에서의 사용 |
| --- | --- | --- |
| `Mesh` | 3D 모양 데이터 자체. Blender, Maya 같은 외부 툴에서 만든 정점/면 기반 형상 | 의자, 헬멧, 날개, 결정 장식 같은 외형 원본 |
| `MeshPart` | Roblox Studio 안에서 메시를 담는 물리 오브젝트 | 던지는 돌멩이 `LookShape`, 월드 소품, 액세서리 `Handle` |
| `Model` | 여러 `Part`, `MeshPart`, `Attachment`, `Script` 등을 묶는 Roblox 컨테이너 | 여러 파트로 된 룩 묶음, 에셋 팩, 장식 모델 |
| `Accessory` | 캐릭터가 착용하는 아바타 장식. 보통 내부에 `Handle`이라는 `MeshPart`가 있음 | 헬멧, 머리, 날개, 등 장식, 어깨 장식 |
| `Attachment` | 액세서리를 캐릭터 몸의 어느 지점에 붙일지 정하는 기준점 | `HatAttachment`, `BodyBackAttachment`, `RightShoulderAttachment` 등 |
| `HumanoidDescription` | 캐릭터의 신체 파츠, 액세서리, 옷, 비율 등을 설명하는 Roblox 객체 | 머리/팔/다리 자체 교체, 기존 유저 아바타 복제, 바디 파츠 적용 |
| `Body Parts` | 아바타 신체 자체를 이루는 머리, 몸통, 팔, 다리, 얼굴 파츠 | 고급 단계. 처음부터 쓰기보다 나중에 제한적으로 적용 |
| `Layered Clothing` | 캐릭터 몸 위에 감기는 3D 의류 계열 | 가장 복잡한 쪽. 수업 초기 구현 대상에서 제외 |

한국어로는 `액세서리`가 표준 표기지만, Roblox 커뮤니티에서는 `악세사리`라고도 자주 말한다. 이 문서에서는 `액세서리`로 통일한다.

## 2. 파일 확장자

### 외부 3D 제작 파일

| 확장자 | 용도 | 권장도 |
| --- | --- | --- |
| `.fbx` | 3D 모델, 텍스처 참조, 리깅, 애니메이션 데이터를 함께 다루기 좋음 | 가장 추천 |
| `.gltf` | glTF 계열 3D 파일. 웹/실시간 렌더링 친화적 | 가능 |
| `.obj` | 단순 메시 임포트에 흔히 쓰이는 오래된 형식 | 단순 소품용 |
| `.glb` | binary glTF. AI 3D 사이트가 자주 내보내는 형식 | Roblox에 바로 넣기보다 Blender에서 `.fbx`로 변환 권장 |

Roblox 공식 Importer 문서 기준으로 핵심 3D 임포트 대상은 `.fbx`, `.gltf`, `.obj`이다. AI 생성 사이트가 `.glb`만 제공하면 Blender에서 열고 `.fbx`로 다시 내보내는 흐름이 안전하다.

### 텍스처 이미지 파일

| 확장자 | 용도 |
| --- | --- |
| `.png` | 투명도 포함 텍스처, UI 이미지, 일반 텍스처 |
| `.jpg` | 불투명 컬러 텍스처 |
| `.tga`, `.bmp`, `.gif` | Roblox Importer가 지원하는 이미지 형식 |

텍스처가 자동으로 안 붙으면 Roblox Studio에서 이미지 에셋으로 따로 업로드한 뒤 `MeshPart.TextureID` 또는 `SurfaceAppearance`에 연결한다.

### Roblox 내부 저장 파일

| 확장자 | 의미 |
| --- | --- |
| `.rbxm` | Roblox 모델 파일 |
| `.rbxmx` | Roblox 모델 XML 파일 |
| `.rbxl` | Roblox place 파일 |
| `.rbxlx` | Roblox place XML 파일 |

Blender 원본은 보통 `.blend`, Roblox에 가져올 파일은 보통 `.fbx`, Studio 안에서 저장/공유할 모델은 `.rbxm`으로 이해하면 된다.

## 3. 제작 및 임포트 기본 흐름

### 일반 소품 또는 돌멩이 룩

```text
Blender 또는 AI 3D 생성 사이트
  -> FBX/OBJ/GLTF 준비
  -> Roblox Studio File > Import 또는 Asset Manager > Import
  -> Workspace에 Model/MeshPart 생성
  -> 크기, 중심점, 텍스처 확인
  -> ReplicatedStorage > OutpostAssets > RockLooks 또는 AvatarLooks에 보관
  -> 학생 코드는 Asset ID가 아니라 이름으로 참조
```

현재 돌멩이 `LookShape`는 이미 이 방향을 쓴다.

```lua
appearance.LookShape = "Meteor"
```

이때 `Meteor`는 `ReplicatedStorage > OutpostAssets > RockLooks > Meteor`에 있는 로컬 모델/메시 이름이다.

### 캐릭터 액세서리 룩

액세서리 룩은 `Accessory` 인스턴스로 준비하는 것이 가장 좋다.

```text
Blender에서 헬멧/날개/등 장식 제작
  -> FBX export
  -> Roblox Studio Importer
  -> Accessory Fitting Tool로 Accessory 변환
  -> Handle과 Attachment 확인
  -> ReplicatedStorage > OutpostAssets > AvatarLooks에 저장
  -> 서버 코드가 Humanoid:AddAccessory()로 장착
```

수업 프로젝트에서 추천하는 폴더 구조는 다음과 같다.

```text
ReplicatedStorage
  OutpostAssets
    AvatarLooks
      CrystalHelmet
      SaltBackpack
      IronShoulder
      WingCape
      FlameCrown
```

학생 스크립트는 이름만 조합한다.

```lua
local avatar = {}

avatar.OwnerUserId = 123456789
avatar.LookParts = {
	"CrystalHelmet",
	"SaltBackpack",
	"WingCape",
}

return avatar
```

서버 공통 코드는 `LookParts`를 반복문으로 순회하고, `AvatarLooks` 폴더에서 같은 이름의 로컬 액세서리를 찾아 캐릭터에 붙인다.

```lua
for _, strLookName in ipairs(tblProfile.LookParts) do
	local accessoryTemplate = fldAvatarLooks:FindFirstChild(strLookName)
	if accessoryTemplate and accessoryTemplate:IsA("Accessory") then
		humanoid:AddAccessory(accessoryTemplate:Clone())
	end
end
```

## 4. 액세서리 종류와 Attachment

Rigid Accessory는 Roblox에서 가장 기본적인 착용형 3D 아이템이다. 몸에 감겨 변형되는 옷이 아니라, 특정 Attachment 위치에 고정된다.

| 액세서리 위치 | 흔한 예시 | 대표 Attachment 이름 |
| --- | --- | --- |
| Hat | 투구, 왕관 | `HatAttachment` |
| Hair | 머리카락 | `HairAttachment` |
| Face | 안경, 가면 | `FaceFrontAttachment`, `FaceCenterAttachment` |
| Neck | 목걸이, 목 보호대 | `NeckAttachment` |
| Back | 가방, 날개, 망토 등판 | `BodyBackAttachment` |
| Front | 가슴 장식 | `BodyFrontAttachment` |
| Waist | 허리띠, 허리 장식 | `WaistFrontAttachment`, `WaistCenterAttachment`, `WaistBackAttachment` |
| Shoulder | 어깨 장식 | `RightShoulderAttachment`, `LeftShoulderAttachment`, `RightCollarAttachment`, `LeftCollarAttachment`, `NeckAttachment` |

실제 캐릭터 장착용 액세서리는 대체로 다음 조건을 만족해야 한다.

- `Accessory` 아래에 `Handle`이라는 `BasePart` 또는 `MeshPart`가 있다.
- `Handle` 안에 Attachment가 있다.
- 그 Attachment 이름이 캐릭터 몸의 Attachment 이름과 맞는다.
- `Accessory.AccessoryType`이 위치와 맞게 설정되어 있다.

처음 구현할 때는 Attachment를 직접 수동 제작하기보다 Studio의 **Accessory Fitting Tool**을 쓰는 것이 안정적이다.

## 5. 신체 부위 Body Parts

아바타 프로필에서 보이는 팔 두 개, 다리 두 개, 머리, 몸통 같은 항목은 단순 `MeshPart` 장식이 아니라 `HumanoidDescription`으로 적용하는 신체 파츠에 가깝다.

대표 필드는 다음과 같다.

```lua
local description = humanoid:GetAppliedDescription()

description.Head = 0
description.Torso = 0
description.LeftArm = 0
description.RightArm = 0
description.LeftLeg = 0
description.RightLeg = 0
description.Face = 0

humanoid:ApplyDescription(description)
```

`0`은 기본값을 의미하고, 실제 교체하려면 Roblox가 허용하는 body part asset id가 필요하다.

신체 부위 교체는 액세서리보다 어렵다.

- R15/R6 리그 차이를 고려해야 한다.
- 애니메이션, 비율, 충돌감이 달라질 수 있다.
- 일부 asset은 권한, 판매 상태, 모더레이션, 아바타 규칙 때문에 적용 실패할 수 있다.
- 학생이 외부 asset id를 직접 입력하면 `User is not authorized to access Asset` 문제가 다시 생길 수 있다.

따라서 수업 초기 컨텐츠는 `Body Parts`보다 `Accessory` 조합을 먼저 한다. Body Parts는 나중에 교사가 검증한 preset만 선택하게 만드는 것이 좋다.

```lua
avatar.BodyPreset = "ClassicBlocky"
```

서버 공통 코드가 `ClassicBlocky`, `Robot`, `CrystalBody` 같은 이름을 실제 `HumanoidDescription` 값으로 바꿔 적용하는 식이다.

## 6. Classic Clothing과 Layered Clothing

Roblox 의류는 크게 두 계열이다.

| 계열 | 설명 | 수업 적합도 |
| --- | --- | --- |
| Classic Shirt/Pants/TShirt | 2D 템플릿 이미지를 캐릭터 표면에 입히는 전통 의류 | 중간 |
| Layered Clothing | 3D 옷이 캐릭터 몸 위에 감기는 방식. WrapLayer, cage 등이 필요 | 낮음 |

Layered Clothing은 결과물이 좋을 수 있지만 제작 난이도가 높다. 처음부터 수업 코드 컨텐츠로 쓰기에는 검증 포인트가 많다. 우선은 rigid accessory 위주로 룩을 입히고, 의류는 나중에 preset으로만 다루는 편이 낫다.

## 7. Blender 고퀄 에셋과 Roblox 최적화

Blender에서는 곡선이 많고 디테일한 AAA 느낌 모델을 만들 수 있다. Roblox에도 가져올 수 있지만, 고폴리곤 원본을 그대로 넣는 방식은 권장하지 않는다.

Roblox용 제작 흐름은 다음이 일반적이다.

```text
고퀄 원본 제작
  -> 저폴리/중폴리 버전으로 리토폴로지
  -> 디테일을 Normal/Roughness/Metalness/Color 텍스처로 베이크
  -> FBX export
  -> Studio Importer
  -> MeshPart + SurfaceAppearance 적용
```

Roblox 공식 스펙 기준으로 일반 메시에는 개별 메시 triangle 제한이 있고, rigid accessory는 더 낮은 triangle 예산을 가진다. 문서 기준으로 일반 메시 쪽은 개별 메시 20,000 triangles, rigid accessory는 4,000 triangles 예산이 언급된다. 실제 수업 에셋은 이보다 더 가볍게 잡는 편이 좋다.

권장 감각:

| 대상 | 권장 방향 |
| --- | --- |
| 작은 헬멧/가면 | 낮은 triangle, 텍스처로 디테일 보정 |
| 등 장식/날개 | 시야를 가리지 않게 크기 제한 |
| 어깨 장식 | 팔 애니메이션을 방해하지 않는 Attachment 선택 |
| 무기/소품 | 충돌 판정은 단순 Part, 외형은 MeshPart |
| 학생 10명 이상 동시 착용 | 에셋 개수와 파티클 수를 제한 |

AAA 느낌은 폴리곤을 많이 쓰는 것이 아니라 PBR 텍스처, Normal Map, 실루엣, 색상 설계로 만든다.

## 8. AI 3D 생성 에셋 사용

무료 AI 3D 생성 사이트는 수업 프로토타입과 재미용 실험에 쓸 수 있다. 다만 바로 Roblox에 넣기보다 Blender에서 한 번 정리하는 흐름이 안전하다.

```text
AI 3D 사이트에서 Text/Image to 3D 생성
  -> GLB/FBX/OBJ 다운로드
  -> Blender에서 크기, 중심점, 폴리곤, 텍스처 정리
  -> FBX export
  -> Roblox Studio Importer
  -> Accessory 또는 MeshPart로 정리
  -> AvatarLooks/RockLooks에 보관
```

검토할 항목:

- 무료 플랜 결과물의 상업 사용 가능 여부
- attribution 필요 여부
- 저작권 있는 캐릭터/브랜드/로고를 프롬프트로 만들지 않았는지
- Roblox 모더레이션 통과 가능성
- triangle 수와 텍스처 크기
- 텍스처가 정상적으로 붙는지
- 캐릭터 착용용이면 Attachment가 맞는지

AI 에셋은 학생이 직접 외부 파일을 올리는 방식보다, 선생님이 미리 검수한 뒤 `AvatarLooks`에 넣어두는 방식으로 사용한다.

## 9. 수업 컨텐츠 설계안

추천 미션명은 **나만의 전투 아바타 만들기**이다.

학생이 작성하는 데이터 예시는 다음과 같다.

```lua
local avatar = {}

avatar.OwnerUserId = 123456789
avatar.Title = "소금 결정술사"

avatar.CombatStyle = "Guardian"
avatar.LookParts = {
	"CrystalHelmet",
	"SaltBackpack",
	"IronShoulder",
}

avatar.CrystalCount = 8
avatar.CapeEnabled = true

return avatar
```

이 컨텐츠로 다룰 수 있는 코드 개념:

| 코드 개념 | 룩 컨텐츠에서의 표현 |
| --- | --- |
| 변수 | `Title`, `CombatStyle`, `CrystalCount` |
| table | `LookParts = {...}` |
| 반복문 | `LookParts`를 하나씩 장착, `CrystalCount`만큼 장식 생성 |
| 조건문 | `CombatStyle`에 따라 추천 룩/효과 변경 |
| 함수 | `applyAccessory`, `applyCrystalRing` 같은 적용 로직 분리 |
| 검증 | 허용되지 않은 룩 이름, 너무 많은 파츠, 너무 큰 수치 제한 |

학생은 "무엇을 입을지"와 "몇 개를 반복할지"만 고르고, 실제 캐릭터 조작과 제한은 서버 공통 코드가 담당한다.

## 10. 프로젝트 적용 원칙

이 프로젝트에서는 다음 원칙을 기본값으로 둔다.

1. 학생 스크립트는 외부 Asset ID를 직접 다운로드하지 않는다.
2. 학생 스크립트는 `AvatarLooks` 또는 `RockLooks` 안의 로컬 이름만 참조한다.
3. 선생님 또는 개발자가 Studio에서 에셋을 미리 import하고, 경로와 이름을 검증한다.
4. 서버 공통 코드는 허용 목록, 개수 제한, 타입 검사를 수행한다.
5. `Script`, `LocalScript`, `ModuleScript`가 들어 있는 외형 모델은 장착 전에 제거한다.
6. 액세서리는 가능하면 `Accessory`로 보관하고 `Humanoid:AddAccessory()`로 붙인다.
7. `MeshPart`/`Model`만 있는 장식은 우선 실험용으로 두고, 정식 캐릭터 룩은 Attachment를 갖춘 `Accessory`로 전환한다.
8. Body Parts는 학생이 asset id를 직접 입력하지 않고, 검증된 preset 이름만 고르게 한다.
9. 시야를 가리는 대형 등 장식, 과도한 파티클, 지나치게 큰 MeshPart는 제한한다.
10. 실제 게임 플레이 성능을 위해 한 캐릭터당 장착 파츠 수와 반복 장식 수를 제한한다.

추천 폴더 구조:

```text
ReplicatedStorage
  OutpostAssets
    RockLooks
      Meteor
      Skull
      ShoeMesh
    AvatarLooks
      CrystalHelmet
      SaltBackpack
      IronShoulder
      WingCape
```

추천 학생 파일 구조:

```text
ServerScriptService
  StudentAvatarProfiles
    01_student_avatar_student01.luau
    01_student_avatar_student02.luau
```

## 11. 파츠 수집 체크리스트

처음 모을 파츠는 복잡한 신체 파츠보다 rigid accessory가 좋다.

| 우선순위 | 파츠 | 이유 |
| --- | --- | --- |
| 1 | 헬멧/왕관/가면 | 눈에 잘 띄고 Attachment가 비교적 단순 |
| 2 | 등 장식/가방/날개 | 캐릭터 정체성이 강하게 보임 |
| 3 | 어깨 장식 | 전투 아바타 느낌이 잘 남 |
| 4 | 허리 장식/벨트 | 작고 안정적인 조합 파츠 |
| 5 | 손에 들지 않는 무기 장식 | 게임 무기 시스템과 충돌이 적음 |
| 6 | Body Parts preset | 고급 단계에서 제한적으로 적용 |
| 7 | Layered Clothing | 제작 난이도가 높으므로 후순위 |

파츠 이름은 학생 코드에서 쓰기 쉬운 영어 이름으로 둔다.

```text
CrystalHelmet
IronShoulder
SaltBackpack
WingCape
FlameCrown
RobotMask
GuardianBackPlate
RunnerHood
```

## 12. 문제 해결

| 증상 | 확인할 것 |
| --- | --- |
| 아무것도 안 보임 | `ReplicatedStorage > OutpostAssets > AvatarLooks` 경로와 이름이 정확한가 |
| 액세서리가 캐릭터에 안 붙음 | `Accessory`인지, `Handle`이 있는지, `Handle` 안 Attachment 이름이 맞는지 |
| 엉뚱한 위치에 붙음 | Attachment 위치와 `AccessoryType`이 맞는지 |
| 텍스처가 회색으로 보임 | 텍스처 이미지가 업로드됐는지, `TextureID` 또는 `SurfaceAppearance`가 연결됐는지 |
| 너무 커서 시야를 가림 | Blender/Studio 크기, Attachment 기준점, 서버 scale 제한 |
| 팔 움직임과 어깨 장식이 이상함 | `RightShoulderAttachment`와 `RightCollarAttachment`의 차이를 확인 |
| 외부 asset id가 실패함 | 권한, 소유, 판매 상태, 모더레이션 문제. 로컬 import 방식으로 전환 |
| 성능이 떨어짐 | triangle 수, texture 크기, 파츠 수, 파티클 수를 줄임 |

## 13. 권장 구현 순서

1. `OutpostAssets/AvatarLooks` 폴더를 만든다.
2. `Accessory` 5~10개를 미리 import해 넣는다.
3. `StudentAvatarProfiles` 폴더와 예시 학생 파일을 만든다.
4. 서버 공통 모듈에서 프로필을 읽고 `OwnerUserId`로 플레이어를 매칭한다.
5. `CharacterAdded`마다 룩을 다시 적용한다.
6. `LookParts`는 최대 3~5개로 제한한다.
7. `CrystalCount` 같은 반복 장식 숫자는 최대값을 둔다.
8. Body Parts는 나중에 preset으로만 추가한다.

이 순서가 현재 돌멩이 `LookShape` 문제에서 얻은 교훈과 맞다. 동적 외부 다운로드보다 로컬 pre-import 이름 참조가 안정적이다.

## 14. 참고 문서

- Roblox Studio Importer: https://create.roblox.com/docs/studio/importer
- Roblox Asset Manager: https://create.roblox.com/docs/projects/assets/manager
- Custom 3D Assets / Modeling: https://create.roblox.com/docs/art/modeling
- General Mesh Specifications: https://create.roblox.com/docs/art/modeling/specifications
- Export Requirements: https://create.roblox.com/docs/art/modeling/export-requirements
- Rigid Accessories: https://create.roblox.com/docs/avatar/accessories
- Rigid Accessory Specifications: https://create.roblox.com/docs/art/accessories/specifications
- Accessory Fitting Tool: https://create.roblox.com/docs/avatar/accessories/accessory-fitting-tool
- Character Appearance / HumanoidDescription: https://create.roblox.com/docs/avatar/characters/character-customization
- Avatar Setup: https://create.roblox.com/docs/avatar-setup
- Avatar Setup Requirements: https://create.roblox.com/docs/avatar-setup/auto-setup-requirements
