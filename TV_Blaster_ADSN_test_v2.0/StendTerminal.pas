unit StendTerminal;

interface

uses
 { Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Registry, ComCtrls, ExtCtrls;   }

  Windows, SysUtils, Forms, {RusErrorStr,} Controls, StdCtrls, ExtCtrls, Classes,
  Dialogs, Registry, About, Messages, ComCtrls, Buttons, Grids, XPMan,
  Gauges, Graphics ;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Button6: TButton;
    Memo2: TMemo;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label1: TLabel;
    XPManifest1: TXPManifest;
    GroupBox5: TGroupBox;
    Connect: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    GroupBox9: TGroupBox;
    ComboBox2: TComboBox;
    ComboBox1: TComboBox;
    XPManifest2: TXPManifest;
    ComboBox3: TComboBox;
    ComboBox5: TComboBox;
    Button9: TButton;
    ComboBox4: TComboBox;
    Timer2: TTimer;
    Timer1: TTimer;
    CheckBox7: TCheckBox;
    GroupBox2: TGroupBox;
    Shape3: TShape;
    PaintBox1: TPaintBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Bright: TTrackBar;
    ScaleBar: TTrackBar;
    Display: TButton;
    RandomBtn: TButton;
    Label4: TLabel;
    procedure ConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure ComboBox2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DisplayClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure ScaleBarChange(Sender: TObject);
    procedure BrightChange(Sender: TObject);
    procedure RandomBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CommProp : TCommProp;
  CommTimeouts : TCommTimeouts;
  DCB : TDCB;
  hComm : Cardinal;             //Хэндл открытого СОМ порта
  ResBool : Boolean;
  hReadCom : Cardinal;
  inChar :array[0..MAXWORD] of Char;
  ThreadID : Cardinal = 0;
  ReadenBytes : Cardinal;

  i : Integer;
  Ch : Char;
  OS : Integer;      // Счетчик простоя перед ошибкой связи

  VC : Integer;
  VKO : Integer;
  VKZ : Integer;
  VO : Integer;

  str : string;
  priem : bool;
  data:array[1..250] of Integer;
  clib:array[1..4] of Integer;
  n : Integer;
  x : Integer;

  p : Integer;


implementation

{$R *.dfm}
///////////////////////////////////////////////////////  КНОПУКА Connect //////
procedure TForm1.ConnectClick(Sender: TObject);
begin

  Memo2.Clear;
  
//Открываем порт
  hComm:=CreateFile(PChar(ComboBox1.Items[ComboBox1.ItemIndex]),
                    GENERIC_READ or GENERIC_WRITE,
                    0,
                    Nil,
                    OPEN_EXISTING,
                    0,
                    0);
//Проверяем, нормально создан порт?
  if hComm = INVALID_HANDLE_VALUE then
  begin
    SysErrorMessage(GetLastError);
    CloseHandle(hComm);
    hComm:=0;
    exit;
  end
  else
  begin
    ResBool:=GetCommState(hComm,DCB);
    if ResBool = false then
    begin
      SysErrorMessage(GetLastError);
      CloseHandle(hComm);
      hComm:=0;
      exit;
    end;
  end;

  case ComboBox2.ItemIndex of
    0 : DCB.BaudRate:= CBR_110;
    1 : DCB.BaudRate:= CBR_300;
    2 : DCB.BaudRate:= CBR_600;
    3 : DCB.BaudRate:= CBR_1200;
    4 : DCB.BaudRate:= CBR_2400;
    5 : DCB.BaudRate:= CBR_4800;
    6 : DCB.BaudRate:= CBR_9600;
    7 : DCB.BaudRate:= CBR_14400;
    8 : DCB.BaudRate:= CBR_19200;
    9 : DCB.BaudRate:= CBR_38400;
    10 : DCB.BaudRate:= CBR_56000;
    11 : DCB.BaudRate:= CBR_57600;
    12 : DCB.BaudRate:= CBR_115200;
    13 : DCB.BaudRate:= CBR_128000;
    14 : DCB.BaudRate:= CBR_256000
    else
      DCB.BaudRate:= CBR_9600;
  end;

  case ComboBox3.ItemIndex of
    0 : DCB.ByteSize:= DATABITS_5;
    1 : DCB.ByteSize:= DATABITS_6;
    2 : DCB.ByteSize:= DATABITS_7;
    3 : DCB.ByteSize:= DATABITS_8;
  else DCB.ByteSize:= DATABITS_8;
  end;

  case ComboBox4.ItemIndex of
    0 : DCB.Parity:= NOPARITY;
    1 : DCB.Parity:= ODDPARITY;
    2 : DCB.Parity:= EVENPARITY;
    3 : DCB.Parity:= MARKPARITY;
    4 : DCB.Parity:= SPACEPARITY;
  else DCB.Parity:= NOPARITY;
  end;

  case ComboBox5.ItemIndex of
    0 : DCB.Stopbits:= ONESTOPBIT;
    1 : DCB.Stopbits:= ONE5STOPBITS;
    2 : DCB.Stopbits:= TWOSTOPBITS;
  else DCB.Stopbits:= ONESTOPBIT;
  end;

  ResBool:=SetCommState(hComm,DCB);
  if not ResBool then
  begin
    SysErrorMessage(GetLastError);
    CloseHandle(hComm);
    hComm:=0;
    exit;
  end;

  CommTimeouts.ReadIntervalTimeout:=MAXDWORD;
  CommTimeouts.ReadTotalTimeoutMultiplier:=0;
  CommTimeouts.ReadTotalTimeoutConstant:=0;
  CommTimeouts.WriteTotalTimeoutMultiplier:=0;
  CommTimeouts.WriteTotalTimeoutConstant:=0;

  ResBool:=SetCommTimeouts(hComm,CommTimeouts);
  if ResBool = false then
  begin
    //SysErrorMessageC;
    CloseHandle(hComm);
    hComm:=0;
    exit;
  end;

  //Проверям на ошибки
  if hReadCom = INVALID_HANDLE_VALUE then
  begin
  //Произошла ошибка рубим всё
    CloseHandle(hReadCom);
    //SysErrorMessageC;
    CloseHandle(hComm);
    hComm:=0;
    exit;
  end
  else
  //Ошибок нет. Запускаем поток
  Begin
    ResumeThread(ThreadID);
    Connect.Enabled:=false;
    Button3.Enabled:=true;
    ComboBox1.Enabled:=false;
    ComboBox2.Enabled:=false;
    ComboBox3.Enabled:=false;
    ComboBox4.Enabled:=false;
    ComboBox5.Enabled:=false;
    CheckBox1.Enabled:=true;
    CheckBox2.Enabled:=true;
  end;
end;
///////////////////////////////////////////////////////  СОЗДАЕМ ФОРМУ  ///////
procedure TForm1.FormCreate(Sender: TObject);
var
  Reg : TRegistry;
  TS : TStrings;
  i : integer;
begin
 ComboBox1.Items.Clear;
//Определение количества СОМ портов
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey('hardware\devicemap\serialcomm', false);
    TS := TStringList.Create;
    try
      Reg.GetValueNames(TS);
      for i := 0 to TS.Count -1 do
        ComboBox1.Items.Add(Reg.ReadString(TS.Strings[i]));
    finally
      TS.Free;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

//Устанавливаем указатель ComboBox1 на начало списка
  ComboBox1.ItemIndex:=9;  //COM1
  ComboBox2.ItemIndex:=6;  //9600

//Остальные настройки
  //Application.Title:=ProgrammVersion;
 // Caption:=ProgrammVersion;
  //Button3.Enabled:=false;
  //Button3Click(Sender);

  priem:=False;
  n :=1;

  //Button1.Click //Подрубаемся с разбегу к порту.
end;
///////////////////////////////////////////////////////  FINISHER  ///////////
procedure Finisher;
begin
  if hComm <> 0 then
    CloseHandle(hComm);
  if hReadCom <> 0 then
    CloseHandle(hReadCom);
end;


///////////////////////////////////////////////////////  КНОПКА Disconnect ////
procedure TForm1.Button3Click(Sender: TObject);
begin
  if hComm <> 0 then
    CloseHandle(hComm);
  hComm:=0;
  CloseHandle(hReadCom);
  hReadCom:=0;
  //Panel1.Enabled:=true;
  Connect.Enabled:=true;
  Button3.Enabled:=false;
  ComboBox1.Enabled:=true;
  ComboBox2.Enabled:=true;
  ComboBox3.Enabled:=true;
  ComboBox4.Enabled:=true;
  ComboBox5.Enabled:=true;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  //Caption := ProgrammVersion;
end;
///////////////////////////////////////////////////////  ТЫКАЕМ порты /////////
procedure TForm1.ComboBox1Click(Sender: TObject);
begin
if CheckBox1.Checked<>false then
    ResBool:=EscapeCommFunction(hComm,SETDTR)
  else
    ResBool:=EscapeCommFunction(hComm,CLRDTR);
  if ResBool = false then
    SysErrorMessage(GetLastError);
end;
///////////////////////////////////////////////////////  ТЫКАЕМ скарость //////
procedure TForm1.ComboBox2Click(Sender: TObject);
begin
  if CheckBox1.Checked<>false then
    ResBool:=EscapeCommFunction(hComm,SETRTS)
  else
    ResBool:=EscapeCommFunction(hComm,CLRRTS);
  if ResBool = false then
    SysErrorMessage(GetLastError);
end;
///////////////////////////////////////////////////////  ТАЙМЕР 2 /////////////
///////////////////////////////////////////////////////
procedure TForm1.Timer2Timer(Sender: TObject);
var
  Result: Cardinal;
begin
  GetCommModemStatus(hComm,Result);

  if (Result and MS_CTS_ON)<>0 then
    CheckBox3.Checked:=true
  else
    CheckBox3.Checked:=false;

  if (Result and MS_DSR_ON)<>0 then
    CheckBox4.Checked:=true
  else
    CheckBox4.Checked:=false;

  if (Result and MS_RING_ON)<>0 then
    CheckBox5.Checked:=true
  else
    CheckBox5.Checked:=false;

  if (Result and MS_RLSD_ON)<>0 then
    CheckBox6.Checked:=true
  else
    CheckBox6.Checked:=false;

  GetCommProperties(hComm,CommProp);
  case CommProp.dwProvSubType of
    PST_FAX: Edit1.Text:='FAX device';
    PST_LAT: Edit1.Text:='LAT protocol';
    PST_MODEM: Edit1.Text:='Modem device';
    PST_NETWORK_BRIDGE:	Edit1.Text:='Unspecified network bridge';
    PST_PARALLELPORT:	Edit1.Text:='Parallel port';
    PST_RS232: Edit1.Text:=' RS-232 S.P.S. Control';  // RS-232 serial port
    PST_RS422: Edit1.Text:='RS-422 port';
    PST_RS423: Edit1.Text:='RS-423 port';
    PST_RS449: Edit1.Text:='RS-449 port';
    PST_SCANNER: Edit1.Text:='Scanner device';
    PST_TCPIP_TELNET:	Edit1.Text:='TCP/IP Telnet® protocol';
    PST_UNSPECIFIED: Edit1.Text:='Unspecified';
    PST_X25: Edit1.Text:='X.25 standards'
    else
      Edit1.Text:='Unspecified';
  end;
end;


///////////////////////////////////////////////////////  ТИПА ОБО МНЕ /////////
procedure TForm1.Button4Click(Sender: TObject);
begin
  with TAboutForm.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;
///////////////////////////////////////////////////////  ЧИСТИМ ОБЛАСТЬ ПРИХОДА
procedure TForm1.Button6Click(Sender: TObject);
begin
  Memo2.Clear;
end;

///////////////////////////////////////////////////////  ОТКРЫВАЕМ ОКОШКО ОТПРАВКИ В НЕХ
procedure TForm1.Button9Click(Sender: TObject);
var
  Ch : Char;
begin
  if hComm = 0 then Exit;

  Ch := Chr(StrToInt('$'+InputBox('Отправка одного байта в HEX формате','Введите число от 00 до FF','00')));
end;
///////////////////////////////////////////////////////  ТАЙМЕР 1 //////////////
///////////////////////////////////////////////////////  ПРИНИМАЕТ БАЙТЫ
procedure TForm1.Timer1Timer(Sender: TObject);
var
  i : Integer;
  inbox : byte;
begin
//  ReadFile(hComm,inChar,High(inChar),ReadenBytes,Nil); //!!!
  ReadFile(hComm,inChar,1,ReadenBytes,Nil); //!!!
  if inChar <> '' then  //Проверяем на пустоту...

  begin
  //Входящая информация в String формате...
    if CheckBox7.Checked then Memo2.Text := Memo2.Text + inChar;
  //Входящая информация в HEX формате...
    for i:=0 to ReadenBytes do
      if inChar[i] <> '' then

      Label4.Caption := inttostr(Ord(inChar[i])) ;
   //   str:=inChar;

      inbox:=Ord(inChar[i]);


////////////////////////////////////////////////// Приход пакета
      // if str = '#' then
      if strtoint(Label4.Caption) = 255 then
    // if inbox = 255 then
      begin
        priem:=True;
        n:=0;
      end;
////////////////////////////////////////////////// Забиваем данные
      if priem=True  then
      begin
        data[n]:= strtoint(Label4.Caption);
        inc(n);
      end;
////////////////////////////////////////////////// Конец пакета
      if n > 225 then
      begin
        priem:=False;
        n:=1;
        Display.Click;
      end;
//////////////////////////////////////////////////

   Memo2.Perform(WM_VScroll, SB_BOTTOM,0);

  end;

  inChar:='';

end;

///////////////////////////////////////////////////////  ТАЙМЕР 3 /////////////
//////////////////////////////////////////////  ПРОВЕРЯЕТ СВЯЗЬ С КОНТРОЛЛЕРОМ
procedure TForm1.Button8Click(Sender: TObject);
var
  j : Integer;
begin
  for j:=1 to 4 do
  begin
    data[j] := 100;
  end;
  Display.Click;
end;

procedure TForm1.FormHide(Sender: TObject);
begin
Form1.Caption:='rrrr';
end;

procedure TForm1.DisplayClick(Sender: TObject);
var
px,py,xg,yg,color,scale,brg : Integer;
begin
scale:=ScaleBar.Position;
brg:=Bright.Position;

for xg:=1 to 15 do
begin
  for yg:=1 to 15 do
  begin
    for px:=1 to scale do
    begin
      for py:=1 to scale do
      begin
        PaintBox1.Canvas.Pixels[px+xg*scale,py+yg*scale]:=RGB(data[xg*yg]*brg,data[xg*yg]*brg,data[xg*yg]*brg);
      end;
    end;
  end;
end;

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
//Pixel_1.Brush.Color :=  RGB(TrackBar1.Position, TrackBar1.Position, TrackBar1.Position);
end;

procedure TForm1.Timer3Timer(Sender: TObject);
var
 u : Integer;
begin
  for u := 245 to 255 do
  begin
    PaintBox1.Canvas.Pixels[p,u]:=RGB(255,255,255);
  end
end;

procedure TForm1.ScaleBarChange(Sender: TObject);
begin
  PaintBox1.Refresh;
  if Connect.Enabled=true then Display.Click;
end;

procedure TForm1.BrightChange(Sender: TObject);
begin
  PaintBox1.Refresh;
  if Connect.Enabled=true then Display.Click;
end;

procedure TForm1.RandomBtnClick(Sender: TObject);
var
  xg,yg : Integer;
begin
for xg:=1 to 15 do
begin
  for yg:=1 to 15 do
  begin
    data[xg*yg] :=Random(64);  // Имитация камры
  end;
end;
Display.Click;
end;

initialization
finalization
  Finisher;
///////////////////////////////////////////////////////  ФИГНЯ КАКАЯ-ТО ///////
end.
