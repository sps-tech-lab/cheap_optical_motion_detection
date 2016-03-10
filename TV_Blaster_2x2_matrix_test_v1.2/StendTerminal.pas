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
    Timer1: TTimer;
    Timer2: TTimer;
    GroupBox1: TGroupBox;
    Button6: TButton;
    Memo3: TMemo;
    Memo2: TMemo;
    Memo1: TMemo;
    Button5: TButton;
    GroupBox2: TGroupBox;
    ComboBox5: TComboBox;
    ComboBox4: TComboBox;
    ComboBox3: TComboBox;
    Button9: TButton;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox4: TGroupBox;
    ConStat: TBitBtn;
    Timer3: TTimer;
    Label1: TLabel;
    Button2: TBitBtn;
    XPManifest1: TXPManifest;
    Label_OS: TLabel;
    Button7: TButton;
    GroupBox5: TGroupBox;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Timer4: TTimer;
    Edit3: TEdit;
    GroupBox8: TGroupBox;
    Shape5: TShape;
    Pixel_1: TShape;
    Pixel_2: TShape;
    Pixel_4: TShape;
    Pixel_3: TShape;
    GroupBox9: TGroupBox;
    ComboBox2: TComboBox;
    ComboBox1: TComboBox;
    XPManifest2: TXPManifest;
    Label_px1: TLabel;
    Label_px2: TLabel;
    Label_px3: TLabel;
    Label_px4: TLabel;
    Display: TButton;
    TrackBar1: TTrackBar;
    Edit2: TEdit;
    Button8: TButton;
    Shape1: TShape;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure ComboBox2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DisplayClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
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
  data:array[1..64] of Integer;
  n : Integer;
  x : Integer;


implementation

{$R *.dfm}
///////////////////////////////////////////////////////  КНОПУКА Connect //////
procedure TForm1.Button1Click(Sender: TObject);
begin
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

  Timer1.Enabled:=true;
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
    Button1.Enabled:=false;
    Button3.Enabled:=true;
    ComboBox1.Enabled:=false;
    ComboBox2.Enabled:=false;
    ComboBox3.Enabled:=false;
    ComboBox4.Enabled:=false;
    ComboBox5.Enabled:=false;
    Memo1.ReadOnly := false;
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

  ConStat.Kind:=bkAbort;
  ConStat.Caption:='';

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
Timer1.Enabled:=false;
  if hComm <> 0 then
    CloseHandle(hComm);
  hComm:=0;
  CloseHandle(hReadCom);
  hReadCom:=0;
  //Panel1.Enabled:=true;
  Button1.Enabled:=true;
  Button3.Enabled:=false;
  ComboBox1.Enabled:=true;
  ComboBox2.Enabled:=true;
  ComboBox3.Enabled:=true;
  ComboBox4.Enabled:=true;
  ComboBox5.Enabled:=true;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  Memo1.ReadOnly := true;
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
 ///////////////////////////////////////////////////////  ЖМЕМ В ОБЛАСТИ ВВОДА
procedure TForm1.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
TransmitCommChar(hComm,Key);   // ШЛЁМ  
end;
///////////////////////////////////////////////////////  ЧИСТИМ ОБЛАСТЬ ВВОДА
procedure TForm1.Button5Click(Sender: TObject);
begin
 Memo1.Clear;
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
  Memo3.Clear;
end;
///////////////////////////////////////////////////////  НАХЕР ВСЕ ЭТО ////////
procedure TForm1.Button7Click(Sender: TObject);
begin
Close;
end;
///////////////////////////////////////////////////////  ОТКРЫВАЕМ ОКОШКО ОТПРАВКИ В НЕХ
procedure TForm1.Button9Click(Sender: TObject);
var
  Ch : Char;
begin
  if hComm = 0 then Exit;

  Ch := Chr(StrToInt('$'+InputBox('Отправка одного байта в HEX формате','Введите число от 00 до FF','00')));
  Memo1KeyPress(Sender,Ch);
  Memo1.Text:=Memo1.Text+Ch;
end;
///////////////////////////////////////////////////////  ТАЙМЕР 1 //////////////
///////////////////////////////////////////////////////  ПРИНИМАЕТ БАЙТЫ
procedure TForm1.Timer1Timer(Sender: TObject);
var
  i : Integer;
begin
//  ReadFile(hComm,inChar,High(inChar),ReadenBytes,Nil); //!!!
  ReadFile(hComm,inChar,1,ReadenBytes,Nil); //!!!
  if inChar <> '' then  //Проверяем на пустоту...
  begin
  //Входящая информация в String формате...
//    Memo2.Text := Memo2.Text + inChar;

  //Входящая информация в HEX формате...
    for i:=0 to ReadenBytes do
      if inChar[i] <> '' then

x:=Ord(inChar[i]);
str:=inChar;
Label2.Caption:=inChar;


if str = '+' then beep;


if str = '#' then
begin
priem:=True;
n:=1;
end;

if priem=True  then
begin
data[n]:= x;
inc(n);
//if n>4 then n:= 1;
Display.Click;
end;

{if n = 8 then
begin
priem:=False;
n:=0;
end; }

   Memo2.Perform(WM_VScroll, SB_BOTTOM,0);
   Memo3.Perform(WM_VScroll, SB_BOTTOM,0);

  end;
  inChar:='';
//  Caption:= TimeToStr(Time);
//Caption:= 'D1 = '+inttostr(data[1])+' °C';
end;
procedure TForm1.Button2Click(Sender: TObject);
begin
 Timer3.Interval:=100;
end;
///////////////////////////////////////////////////////  ТАЙМЕР 3 /////////////
//////////////////////////////////////////////  ПРОВЕРЯЕТ СВЯЗЬ С КОНТРОЛЛЕРОМ
procedure TForm1.Timer3Timer(Sender: TObject);
begin
if Edit2.Text = '---' then
  Begin
  TransmitCommChar(hComm,'A');   // Шлем в порт
  Memo1.Text := Memo1.Text + 'A';
  end;

  if Edit2.Text = 'B' then
  Begin
  TransmitCommChar(hComm,'C');   // Шлем в порт
  Memo1.Text := Memo1.Text + 'C';
  Edit2.Text := '---';

  ConStat.Kind:=bkOK;
  ConStat.Caption:='';
//  StatusBar1.Panels[3].Text:='Подключен';

  Timer3.Interval:=0;
  end
    else      // если не пришел ответ ожидаем его 5 сек.
      begin
      OS:=OS+1;
      Label_OS.Caption:=inttostr(OS);
        if OS>49 then                    // не пришел за 5 сек. -> Ошибка !!!
        begin
        Beep;
        Timer3.Interval:=0;           //Стопаем и выводим м-бокс

        { объект не готов -- покажем код ошибки }
        Application.MessageBox(PChar('Контроллер не ответил вовремя. Проверьте кабель и питание контроллера.'),'ОШИБКА СВЯЗИ',MB_OK+MB_ICONWARNING);     //MB_ICONERROR

        OS:=0;                            // нулим и приводим все в порядок
        Edit2.Text := '---';             // для следующего рефреша
        end;
        end;
end;


procedure TForm1.Timer4Timer(Sender: TObject);
begin
   TransmitCommChar(hComm,'T');   // Шлем в порт
end;

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
begin
 Pixel_1.Brush.Color :=  RGB(data[1], data[1], data[1]);
 Pixel_2.Brush.Color :=  RGB(data[2], data[2], data[2]);
 Pixel_3.Brush.Color :=  RGB(data[3], data[3], data[3]);
 Pixel_4.Brush.Color :=  RGB(data[4], data[4], data[4]);

 Label_px1.Caption :=  inttostr(data[1]);
 Label_px2.Caption :=  inttostr(data[2]);
 Label_px3.Caption :=  inttostr(data[3]);
 Label_px4.Caption :=  inttostr(data[4]);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
//Pixel_1.Brush.Color :=  RGB(TrackBar1.Position, TrackBar1.Position, TrackBar1.Position);
end;

initialization
finalization
  Finisher;
///////////////////////////////////////////////////////  ФИГНЯ КАКАЯ-ТО ///////
end.
