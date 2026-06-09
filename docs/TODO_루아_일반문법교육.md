# TODO_루아_일반문법교육

이 문서는 Lua를 일반적인 프로그래밍 기초 문법 교육용으로 활용하기 위해 정리한 10단계 핵심 커리큘럼 가이드라인입니다. 타 언어(Python, JS 등)로의 확장을 고려하여 Lua 특유의 `:` 메서드 문법(메서드 체이닝 및 self 암시적 전달) 등은 제외하고, 범용적인 제어 흐름과 데이터 구조 중심의 10가지 주제로 설계되었습니다.

---

## 1. 값과 타입
* **학습 목표**: 프로그래밍의 기본 데이터 단위를 이해하고, 변수를 선언하여 데이터를 저장하는 방법을 배웁니다.
* **주요 내용**:
  - 기본 타입: `number` (숫자), `string` (문자열), `boolean` (참/거짓), `nil` (빈 값)
  - 변수 선언과 값의 대입 (`local` 키워드 권장)
  - `type()` 함수를 이용한 데이터 타입 확인
* **코드 예시**:
  ```lua
  local score = 100               -- number
  local player_name = "철수"       -- string
  local is_active = true          -- boolean
  local next_target = nil         -- nil (값 없음)

  print(type(score))              -- 출력: number
  print(type(player_name))        -- 출력: string
  ```

---

## 2. 연산자와 표현식
* **학습 목표**: 변수에 저장된 값을 계산하고, 비교하며, 논리적으로 조합하여 새로운 값을 만들어내는 방법을 배웁니다.
* **주요 내용**:
  - 산술 연산자: `+`, `-`, `*`, `/`, `%` (나머지), `^` (제곱)
  - 비교 연산자: `==`, `~=` (같지 않음), `<`, `>`, `<=`, `>=`
  - 논리 연산자: `and`, `or`, `not`
* **코드 예시**:
  ```lua
  local a = 15
  local b = 4
  print(a % b)                    -- 출력: 3 (나머지 연산)

  local has_key = true
  local has_energy = false
  print(has_key and not has_energy) -- 출력: true
  print(a > 10 or b > 10)         -- 출력: true
  ```

---

## 3. 조건문
* **학습 목표**: 주어진 조건에 따라 프로그램의 실행 흐름을 분기하는 방법을 이해합니다.
* **주요 내용**:
  - `if`, `elseif`, `else`, `end` 구조의 제어 흐름 작성
  - 참/거짓 판정 기준: Lua에서는 `false`와 `nil`만 거짓(False)으로 판정하며, 숫자 `0`이나 빈 문자열 `""`은 참(True)으로 판정함을 주의
  - 복합 조건식 구성
* **코드 예시**:
  ```lua
  local score = 85

  if score >= 90 then
      print("A 등급")
  elseif score >= 80 then
      print("B 등급")
  else
      print("C 등급")
  end
  ```

---

## 4. 반복문 (조건 기반 반복)
* **학습 목표**: 특정 조건이 만족되는 동안 코드를 반복 실행하고, 반복을 종료하는 안전한 조건을 설계하는 방법을 배웁니다.
* **주요 내용**:
  - `while` 반복문 구조
  - `repeat until` 반복문 구조 (최소 1회 실행 후 조건 판정)
  - 무한 루프의 위험성과 탈출 조건 설계
* **코드 예시**:
  ```lua
  local hp = 3
  while hp > 0 do
      print("아직 살아있습니다. 현재 체력: " .. hp)
      hp = hp - 1
  end

  local count = 1
  repeat
      print("카운트: " .. count)
      count = count + 1
  until count > 3
  ```

---

## 5. 횟수 기반 반복
* **학습 목표**: 정해진 횟수만큼 동작을 수행하는 반복문을 설계하고, 증가값을 조절하는 방법을 배웁니다.
* **주요 내용**:
  - `for` 루프 구조: `for 변수 = 시작값, 끝값, [증가값] do ... end`
  - 증가값(Step)을 이용한 역순 순회 및 간격 순회
  - 반복문 내부에서의 누적 계산 (합계, 카운트 등)
* **코드 예시**:
  ```lua
  -- 1부터 5까지 2씩 증가하며 출력
  for i = 1, 5, 2 do
      print("홀수 출력: " .. i)
  end

  -- 1부터 10까지의 합 구하기
  local sum = 0
  for i = 1, 10 do
      sum = sum + i
  end
  print("합계: " .. sum)          -- 출력: 55
  ```

---

## 6. 함수
* **학습 목표**: 자주 사용되는 코드 블록을 하나로 묶어 재사용하고, 입력값(매개변수)과 결과값(반환값)을 다루는 법을 배웁니다.
* **주요 내용**:
  - 함수 정의 (`function`)와 호출
  - 매개변수(Parameter) 전달과 활용
  - `return`을 사용한 결과값 반환
* **코드 예시**:
  ```lua
  local function multiply(x, y)
      local result = x * y
      return result
  end

  local calculation = multiply(6, 7)
  print("곱셈 결과: " .. calculation) -- 출력: 42
  ```

---

## 7. 문자열 처리
* **학습 목표**: 텍스트 데이터를 조작하고 가공하는 방법을 이해합니다.
* **주요 내용**:
  - 문자열 연결 연산자 `..` 사용법
  - 문자열의 길이를 구하는 `#` 연산자
  - 유용한 내장 문자열 함수 기초 (`string.sub`, `string.find`, `string.format` 등)
* **코드 예시**:
  ```lua
  local first = "Hello"
  local second = "World"
  local message = first .. " " .. second
  print(message)                  -- 출력: Hello World
  print("글자수: " .. #message)    -- 출력: 11

  local sub_str = string.sub(message, 1, 5)
  print(sub_str)                  -- 출력: Hello
  ```

---

## 8. 테이블을 배열처럼 쓰기
* **학습 목표**: 여러 개의 순서가 있는 데이터를 묶어서 관리하는 방법을 배웁니다.
* **주요 내용**:
  - 중괄호 `{}`를 사용한 배열형 테이블 선언
  - 인덱스를 통한 데이터 접근 (Lua는 **1부터 시작하는 인덱스(1-based indexing)**를 사용함을 반드시 강조)
  - `ipairs`를 활용한 배열 순차 순회 및 인덱스 활용
* **코드 예시**:
  ```lua
  local fruits = {"사과", "바나나", "포도"}
  print(fruits[1])                -- 출력: 사과 (첫 번째 인덱스가 1임)

  -- ipairs를 이용한 순회
  for index, value in ipairs(fruits) do
      print(index .. "번째 과일: " .. value)
  end
  ```

---

## 9. 테이블을 딕셔너리처럼 쓰기
* **학습 목표**: 키(Key)와 값(Value)의 쌍으로 이루어진 구조화된 데이터를 선언하고 사용하는 방법을 이해합니다.
* **주요 내용**:
  - 키-값 형태의 테이블 정의
  - 특정 키를 통한 데이터 조회 및 변경
  - `pairs`를 사용한 딕셔너리 순회 (순서가 보장되지 않음을 인지)
* **코드 예시**:
  ```lua
  local character = {
      name = "전사",
      level = 10,
      hp = 150
  }

  print(character.name)           -- 출력: 전사
  character.level = character.level + 1 -- 레벨업 반영

  -- pairs를 이용한 키-값 순회
  for key, value in pairs(character) do
      print(key .. ": " .. tostring(value))
  end
  ```

---

## 10. 변수 범위와 모듈화
* **학습 목표**: 변수의 유효 범위(Scope)를 제한하는 법과 코드를 여러 파일로 구조화하여 관리하는 방법을 배웁니다.
* **주요 내용**:
  - `local` 변수의 범위(블록 스레드 범위 및 함수 범위)와 전역 변수의 차이점
  - 모듈 스크립트 작성 방식: 테이블에 값/함수를 담아 `return`하기
  - 다른 스크립트에서 `require`를 사용하여 모듈을 호출하고 사용하는 흐름 이해
* **코드 예시**:
  ```lua
  -- [모듈 예시: tools.lua]
  local tools = {}

  function tools.add(a, b)
      return a + b
  end

  return tools

  -- [사용 예시: main.lua]
  local my_tools = require("tools") -- 모듈 불러오기
  local result = my_tools.add(10, 20)
  print(result)                   -- 출력: 30
  ```
