Option Explicit

' ================================================================================
' Unlock Excel Book Password
' ================================================================================

' �K�� CScript �Ŏ��s������
If Instr(LCase(WScript.FullName), "wscript") > 0 Then
  WScript.CreateObject("WScript.Shell").Run("CScript //NoLogo """ & WScript.ScriptFullName & """")
  WScript.Quit
End If

WScript.Echo "����������������������������������������"
WScript.Echo "Unlock Excel Book Password"
WScript.Echo ""

' �ݒ�t�@�C���E�����p�X���[�h�o�̓t�@�C��
Const PROPERTY_FILE = "Property.txt"
Const UNLOCKED_FILE = "Unlocked.txt"

' �ݒ�t�@�C������擾���Ďg���p�����[�^
Dim fileName    : fileName    = ""
Dim min         : min         = ""
Dim max         : max         = ""
Dim strings     : strings     = "" 
Dim progressStr : progressStr = ""

' �ݒ�t�@�C����ǂݍ���ŕϐ��ɒl��ݒ肷��
Call readPropertyFile()

' ���W���[��������܂œ��B������
Dim isResumed : isResumed = False

' �T���Ɏg�p���镶�����z��ɂ���
Dim strs : strs = Split(strings, ",")

' �T���Ɏg�p���镶������J���}�����ŘA�������� (���W���[������Ɏg�p����)
Dim joinStrings : joinStrings = Join(strs, "")

' Excel �̏���
Dim excel
On Error Resume Next
Set excel = GetObject(, "Excel.Application")
If Err.Number <> 0 Then
  Set excel = CreateObject("Excel.Application")
End If
On Error GoTo 0
excel.DisplayAlerts = False
excel.Visible = False

' �u���[�g�t�H�[�X
Dim n
For n = min To max
  WScript.Echo "��Next Length : " & n
  Call unlock("", n)
Next

' ������Ȃ������c
WScript.Echo "����������������������������������������"
WScript.Echo "������܂���ł����B"
WScript.Echo "����������������������������������������"
excel.Quit
Set excel = Nothing
WScript.Quit



' ================================================================================
' �ݒ�t�@�C����ǂݍ���
' ================================================================================
Sub readPropertyFile()
  Dim fso : Set fso = WScript.CreateObject("Scripting.FileSystemObject")
  
  If fso.FileExists(PROPERTY_FILE) = False Then
    WScript.Echo PROPERTY_FILE & " �����݂��Ȃ����ߏ����ł��܂���B�I�����܂��B"
    WScript.Echo "����������������������������������������"
    Set fso = Nothing
    WScript.Quit
  End If
  
  Dim propertyFile : Set propertyFile = fso.OpenTextFile(PROPERTY_FILE)
  
  Do While propertyFile.AtEndOfStream <> True
    Dim line : line = propertyFile.ReadLine
    If fileName    = "" And regSearch(line, "fileName"   ) Then fileName    = getPropertyValue(line, "fileName")
    If min         = "" And regSearch(line, "min"        ) Then min         = getPropertyValue(line, "min")
    If max         = "" And regSearch(line, "max"        ) Then max         = getPropertyValue(line, "max")
    If strings     = "" And regSearch(line, "strings"    ) Then strings     = getPropertyValue(line, "strings")
    If progressStr = "" And regSearch(line, "progressStr") Then progressStr = getPropertyValue(line, "progressStr")
  Loop
  
  propertyFile.Close
  Set propertyFile = Nothing
  
  If fileName = "" Or min = "" Or max = "" Or strings = "" Then
    WScript.Echo "�K�{���ڂ���`����Ă��Ȃ����ߏ����ł��܂���B�I�����܂��B"
    WScript.Echo "����������������������������������������"
    Set fso = Nothing
    WScript.Quit
  ElseIf fso.FileExists(fileName) = False Then
    WScript.Echo fileName & " �����݂��Ȃ����ߏ����ł��܂���B�I�����܂��B"
    WScript.Echo "����������������������������������������"
    Set fso = Nothing
    WScript.Quit
  End If
  
  Set fso = Nothing
  
  WScript.Echo "�ȉ��̐ݒ�ŏ������J�n���܂��B"
  WScript.Echo "  �Ώۃu�b�N��         : " & fileName
  WScript.Echo "  �p�X���[�h���ŏ���   : " & min
  WScript.Echo "  �p�X���[�h���ő包   : " & max
  WScript.Echo "  �T���Ɏg�p���镶���� : " & strings
  WScript.Echo "  �Ō�ɒT������������ : " & progressStr
  
  ' �Ō�ɒT�����������񂪂���΁A���̕������� min �ɐݒ肷��
  If progressStr <> "" Then
    min = Len(progressStr)
    WScript.Echo "  �� �Ō�ɒT������������̒��� " & min & " ������ĊJ���܂��B"
  End If
  
  WScript.Echo "����������������������������������������"
  WScript.Echo ""
End Sub

' ================================================================================
' �ݒ荀�ڂ�T������
' ================================================================================
Function regSearch(testStr, propertyKey)
  Dim re : Set re = WScript.CreateObject("VBScript.RegExp")
  re.Pattern = "^" & propertyKey
  regSearch = re.test(testStr)
  Set re = Nothing
End Function

' ================================================================================
' �ݒ荀�ڂ���l�̂ݎ��o��
' ================================================================================
Function getPropertyValue(lineStr, propertyKey)
  ' "propertyName=Value" ���� "Value" �����o������ "=" �̎��̕����ȍ~���擾����
  getPropertyValue = Mid(lineStr, Len(propertyKey) + 2)
End Function

' ================================================================================
' �u���[�g�t�H�[�X
' ================================================================================
Sub unlock(pass, length)
  On Error Resume Next
  
  ' �ċA�̐[��
  Dim depth : depth = Len(pass) + 1
  
  ' �C���f���g�p�X�y�[�X
  Dim t : t = String(depth * 2, " ")
  
  ' ��ԕs��
  If Len(pass) >= length Then
    WScript.Echo t & "��Exit �c pass:[" & pass & "], length:[" & length & "], depth:[" & depth & "]"
    Exit Sub
  End If
  
  ' �T�����镶��������[�v���Ă���
  Dim i
  For i = 0 To UBound(strs)
    ' Continue �����p�� Do : Loop Until 1
    Do
      ' ���̕�����1�������o��
      Dim p : p = strs(i)
      
      ' �����̌Œ蕶����ƌ�������
      Dim passStr : passStr = pass & p
      
      ' ���W���[������
      If progressStr <> "" And n <= min And isResumed = False Then
        ' �T������ : �Ō�ɒT�����������񂩂�[���ɉ�����1���������o��
        Dim progressChar : progressChar = Mid(progressStr, depth, 1)
        
        ' �T�������� strs �̉��Ԗڂɂ��邩�T�� (�Ȃ���� -1 �ɂȂ�)
        Dim indexOf : indexOf = InStr(joinStrings, progressChar) - 1
        
        WScript.Echo t & "��Resume �c passStr:[" & passStr & "], length:[" & length & "], depth:[" & depth & "], i:[" & i & "], progressChar:[" & progressChar & "], indexOf:[" & indexOf & "]"
        
        ' �T���Ɏg�p���镶����̃��[�v���T�������̈ʒu�܂œ��B���Ă��Ȃ�������A���̕����͊��ɒT���������̂Ƃ��� Continue ����
        If i < indexOf Then
          WScript.Echo t & "��Continue"
          Exit Do
        End If
        
        ' �Ō�ɒT������������ƈ�v�����烌�W���[������
        If passStr = progressStr Then
          isResumed = True
          WScript.Echo t & "��Resumed �c passStr:[" & passStr & "]"
          Exit Do
        End If
      Else
        ' �T���ϕ����Ȃ��E�������̓��W���[����
        WScript.Echo t & "��Progress �c passStr:[" & passStr & "], length:[" & length & "], depth:[" & depth & "], i:[" & i & "]"
      End If
      
      If Len(passStr) <> length Then
        Call unlock(passStr, length)
      Else
        WScript.Echo t & "�E" & passStr
        Err.Clear
        
        ' �u�b�N���J���Ă݂� (0:�O���Q�ƃ����N�X�V�Ȃ��EFalse:�ǎ��p�łȂ��ҏW���[�h�ŊJ���E5:�t�@�C���̋�؂蕶���Ȃ�)
        excel.Workbooks.Open fileName, 0, False, 5, passStr
        
        If Err.Number = 0 Then
          ' �p�X���[�h���
          unlocked(passStr)
        ElseIf Err.Number <> 1004 Then
          WScript.Echo "����������������������������������������"
          WScript.Echo "���\�����Ȃ��G���[�̂��ߏI�����܂� : " & Err.Description
          WScript.Echo "����������������������������������������"
          excel.Quit
          Set excel = Nothing
          WScript.Quit
        End If
      End If
    Loop Until 1
  Next
End Sub

' ================================================================================
' �p�X���[�h��ǎ��̏���
' ================================================================================
Sub unlocked(passStr)
  WScript.Echo "����������������������������������������"
  WScript.Echo "���p�X���[�h���� : [" & passStr & "]"
  WScript.Echo "����������������������������������������"
  
  ' Excel ��\������
  excel.Visible = True
  
  Dim fso : Set fso = WScript.CreateObject("Scripting.FileSystemObject")
  
  ' �p�X���[�h�������̃e�L�X�g�t�@�C�� (2:������p�ETrue:�V�K�t�@�C���쐬)
  Dim unlockedFile
  Set unlockedFile = fso.OpenTextFile(UNLOCKED_FILE, 2, True)
  
  ' �t�@�C�����ƃp�X���[�h����������
  unlockedFile.WriteLine(fileName)
  unlockedFile.WriteLine(passStr)
  
  unlockedFile.Close
  Set unlockedFile = Nothing
  Set fso = Nothing
  WScript.Quit
End Sub