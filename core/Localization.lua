-- LOCALE FILE
-- ADD A NEW TABLE PER LOCALE AND THE ADDON WILL HANDLE THE REST

 

-- L["LOCALE"]["STRING_KEY"] = "TRANSLATION"

local L = {}

-- ENGLISH / DEFAULT
-- enUS changed to koKR (Korean)

L["koKR"] = {}
-- Chat Commands
L["koKR"]["Shows this list"] = "리스트 보여주기"
L["koKR"]["Toggles the minimap button"] = "미니맵 버튼 활성화"
L["koKR"]["Short for /BST ToggleMinimapButton"] = "짧게 /BST 미니맵 설정 열기"
L["koKR"]["Opens the BiSTracker Options window"] = "BiSTracker 설정창 열기"
L["koKR"]["|c00ffff00Version "] = "|c00ffff00Version "
L["koKR"][" commands:"] = " 명령어:"
L["koKR"]["|cffffff00/BiSTracker: |cffffffffToggles the BiSTracker window"] = "|cffffff00/BiSTracker: |cffffffffBiSTracker창 열기/닫기"
L["koKR"]["|cffffff00/BST: |cffffffffShort for /BiSTracker"] = "|cffffff00/BST: |cffffffff/BiSTracker를 짧게"
-- Error
L["koKR"]["|cffff0000An error has occured: |cffffffff"] = "|cffff0000An 에러 발생함: |cffffffff"
-- GUI
L["koKR"]["Are you sure you want to delete the set |cffff0000"] = "정말로 세트를 삭제합니까 |cffff0000"
L["koKR"]["Item ID:"] = "아이템 ID:"
L["koKR"]["Kill npc:"] = "NPC 처치:"
L["koKR"]["Located in:"] = "위치:"
L["koKR"]["Drop chance:"] = "나올 확률:"
L["koKR"][" |cffffffff(ID: "] = " |cffffffff(ID: "
L["koKR"]["Sold by:"] = "판매:"
L["koKR"]["Quest Not Found"] = "퀘스트 없음"
L["koKR"]["Quest:"] = "퀘스트:"
L["koKR"]["Contained in:"] = "보관함:"
L["koKR"]["No source information found."] = "자료가 없습니다."
L["koKR"]["|cff00ff00You have this item."] = "|cff00ff00소지하고 있음"
L["koKR"]["|cffff0000You do not have this item."] = "|cffff0000소지 안하고 있음"
L["koKR"]["|cffff0000An error occured while loading this item.\nPlease try reloading the set."] = "|cffff0000이 아이템을 로딩 중 에러 발생.\n리로딩을 해주세요."
L["koKR"]["|cffff0000Error loading item, please try reloading."] = "|cffff0000로딩 중 에러, 다시 리로딩 해주세요."
L["koKR"]["An item in the |cffffff00"] = "아이템이 |cffffff00"
L["koKR"]["|r set |cffffff00"] = "|r 세트 |cffffff00"
L["koKR"]["|r didn't load correctly. Please try reloading the set."] = "|r 로딩이 잘못됨. 세트를 리로딩해주세요."
L["koKR"]["Npc ID"] = "NPC ID"
L["koKR"]["Npc Name"] = "NPC 이름"
L["koKR"]["Container ID"] = "보관함 ID"
L["koKR"]["Container Name"] = "보관함 이름"
L["koKR"]["Quest ID"] = "퀘스트 ID"
L["koKR"]["Recipe ID"] = "도안 ID"
L["koKR"]["Edit Slot"] = "수정 부위"
L["koKR"]["Confirm Deletion"] = "삭제 확인"
L["koKR"]["Edit "] = "수정 "
L["koKR"][" Class"] = " 직업"
L["koKR"][" Set"] = " 세트"
L["koKR"]["Toggle BiSTracker window"] = "BiSTracker창 열기/닫기"
L["koKR"]["Are you sure you want to delete this set?"] = "이 세트를 삭제하시겠습니까?"
L["koKR"]["Zone"] = "지역"
L["koKR"]["Drop Chance"] = "나올 확률"
L["koKR"]["Cancel"] = "취소"
L["koKR"]["Save"] = "저장"
L["koKR"]["Obtain Method"] = "획득방법"
L["koKR"]["Item ID"] = "아이템 ID"
L["koKR"]["Reload"] = "리로드"
L["koKR"]["Open Import/Export window"] = "가져오기/내보내기 창 열기"
L["koKR"]["New Set"] = "새 세트"
L["koKR"]["Create Custom Set"] = "사용자 세트 생성"
L["koKR"]["Delete Custom Set"] = "사용자 세트 삭제"
L["koKR"]["Set Name"] = "세트 이름"
L["koKR"]["Set name cannot be shorter than 1 character."] = "세트 이름은 2글자 이상 되어야함"
L["koKR"]["A set with the name |cffffff00"] = "같은 이름의 세트 |cffffff00"
L["koKR"][" |cffffffffalready exists."] = " |cffffffff가 이미 존재합니다."
-- Import Export
L["koKR"]["The data to be imported did not match a BiSTracker set."] = "가져온 자료가 BisTracker 세트와 동일하지 않습니다."
L["koKR"]["The string supplied was an incorrect format."] = "가져온 문자열이 잘못된 형식입니다."
L["koKR"]["Import String"] = "문자열 가져오기"
L["koKR"]["Import"] = "가져오기"
L["koKR"]["Export"] = "내보내기"
L["koKR"]["New Set Name (Leave empty to inherit name)"] = "새 세트 이름 (미입력시 가져온 이름 유지)"
L["koKR"]["A set already exists with the name |cffffff00"] = "같은 이름의 세트 |cffffff00 가 존재"
L["koKR"]["Successfully imported the set |cffffff00"] = "가져오기 성공 |cffffff00"
L["koKR"]["|cffffffff as |cffffff00"] = "|cffffffff 이걸로 |cffffff00"
L["koKR"]["No custom sets to export."] = "내보낼 사용자 세트 없음"
L["koKR"]["Export String (This is the string you use to import a set)"] = "내보내기 문자열 (이것이 가져오기 문자열)"
L["koKR"]["The selected set to export could not be found."] = "내보내기할 세트를 찾지 못함"
L["koKR"]["Import / Export"] = "가져오기 / 내보내기"
L["koKR"]["Set"] = "세트"
L["koKR"]["Class"] = "직업"
-- Init
L["koKR"]["|cffffff00Left click:|r Toggle BiSTrackers main window"] = "|cffffff00좌클릭:|r BiSTrackers 메인창 열기/닫기"
L["koKR"]["|cffffff00Right click:|r Toggle BiSTrackers options window"] = "|cffffff00우클릭:|r BiSTrackers 설정창 열기/닫기"
-- Options
L["koKR"]["General"] = "일반"
L["koKR"]["Main Window"] = "메인창"
L["koKR"]["Disable Minimap Button"] = "미니맵 버튼 비활성화"
L["koKR"]["Use Compact View"] = "목록 나열로 보기"
L["koKR"]["Connect to CharacterFrame"] = "케릭터창 옆에 붙이기"
L["koKR"]["*Requires reload"] = "*리로딩해야함"
L["koKR"]["CharacterFrame toggle button X Pos"] = "케릭터창 움직이기 X 좌표"
L["koKR"]["CharacterFrame toggle button Y Pos"] = "케릭터창 움직이기 Y 좌표"
L["koKR"]["Reload UI"] = "리로드 UI"
L["koKR"]["BiSTracker Options"] = "BiSTracker 옵션"



function BiSTracker:InitLocale()
    print("Init Locale")
    if (L[GetLocale()] ~= nil) then
        BiSTracker.Locale = GetLocale()
    end
    BiSTracker.L = L
end
