unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmLFSR = class(TForm)
    labelRegistr: TLabel;
    editRegisterWrite: TEdit;
    bitbtnRegister: TBitBtn;
    labelKey: TLabel;
    labelPolynom: TLabel;
    bitbtnKey: TBitBtn;
    editPolynom: TEdit;
    labelPower: TLabel;
    editPower: TEdit;
    OpenDialog: TOpenDialog;
    bitbtnOpen: TBitBtn;
    memoPlainText: TMemo;
    labelPlainText: TLabel;
    bitbtnCipher: TBitBtn;
    memoCipherText: TMemo;
    memoDecipherText: TMemo;
    bitbtnDecipher: TBitBtn;
    labelCipher: TLabel;
    labelDecipher: TLabel;
    bitbtnReset: TBitBtn;
    memoKey: TMemo;
    procedure bitbtnResetClick(Sender: TObject);
    procedure bitbtnDecipherClick(Sender: TObject);
    procedure bitbtnCipherClick(Sender: TObject);
    procedure bitbtnKeyClick(Sender: TObject);
    procedure bitbtnOpenClick(Sender: TObject);
    procedure bitbtnRegisterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLFSR: TfrmLFSR;
  RegStr,Key,PlainText,CipherText,DecipherText: string;
  RegInt,Power: integer;

implementation

{$R *.dfm}

function Bin2Str(aStr: string): string;
var s: string;
    i,j,k : longint;
    ich : integer;
begin
  s := '';
  k := 1;
  for i := 1 to length(aStr) div 8 do
  begin
    ich := 0;
    for j := 0 to 7 do
    begin
      ich := ich*2 + byte(aStr[k]) - byte('0');
      inc(k);
    end;
    s := s + char(ich);
  end;
  Bin2Str := s;
end;

procedure SaveToFile1(fName,text:string);
var f:textfile;
begin
  assignfile(f,fName);
  rewrite(f);
  write(f,text);
  closefile(f);
end;

procedure SaveToFile(fName,text:string);
var f:textfile;
begin
  assignfile(f,fName+'2');
  rewrite(f);
  write(f,text);
  closefile(f);
end;

function RegisterCorrect(reg:string):string;
var i:integer;
begin
  for i:= 1 to length(reg) do
    if (reg[i]='1')or(reg[i]='0') then
      result:=result+reg[i];
end;

function BinaryToDecimal(RegStr: string): integer;
var i: integer;
begin
  result:=0;
  for i:=1 to length(RegStr) do
  begin
    result:=result+ord(RegStr[i])-ord('0');
    if i<length(RegStr) then
      result:=result*2;
  end;
end;

function DecimalToBinary(Value: integer; Digits: integer): string;
var i: integer;
begin
  result := '';
  for i := 0 to Digits - 1 do
    if Value and (1 shl i) > 0 then
      result := '1' + result
    else
      result := '0' + result;
end;

procedure TfrmLFSR.bitbtnOpenClick(Sender: TObject);
var i,n: integer;
    F: file of byte;
    B: byte;
begin
  if OpenDialog.Execute then
  begin
    memoPlainText.Text:='';
    PlainText:='';
    AssignFile(F,OpenDialog.FileName);
    Reset(F);
    While Not Eof(F) Do
    begin
      Read(F, B);
      n:=Ord(B);
      PlainText:=PlainText+DecimalToBinary(n,8);
    end;
    CloseFile(F);
    memoPlainText.Lines[0]:=(PlainText);
    SaveToFile1('PlainText.txt',PlainText);
  end;
end;

procedure TfrmLFSR.bitbtnCipherClick(Sender: TObject);
var i,a,b,c: integer;
begin
  for i:= 1 to length(PlainText) do
  begin
    CipherText:=CipherText+'0';
    a:=StrToInt(PlainText[i]);
    b:=StrToInt(Key[i]);
    c:=a xor b;
    CipherText[i]:=chr(c+ord('0'));
  end;
  memoCipherText.Lines[0]:=(CipherText);
  SaveToFile1('CipherText.txt',CipherText);
end;

procedure TfrmLFSR.bitbtnDecipherClick(Sender: TObject);
var i,a,b,c: integer;
begin
  for i:= 1 to length(CipherText) do
  begin
    DecipherText:=DecipherText+'0';
    a:=StrToInt(CipherText[i]);
    b:=StrToInt(Key[i]);
    c:=a xor b;
    DecipherText[i]:=chr(c+ord('0'));
  end;
  memoDecipherText.Lines[0]:=(DecipherText);
  SaveToFile('DecipherText.txt',Bin2Str(DecipherText));
end;

procedure TfrmLFSR.bitbtnKeyClick(Sender: TObject);
var i,j,a,b,c: integer;
    str,temps: string;
begin
  if (Key='') then
  begin
    str:=RegStr;
    for i:= 1 to length(PlainText) do
    begin
      Key:=Key+str[1];      //1 символ сдвигаемой строки
      for j:= 1 to length(RegStr) do
      begin
        if j<>length(RegStr) then
          str[j]:=RegStr[j+1]
        else
        begin
          a:=StrToInt(RegStr[1+Power-Power]);            //23 XOR 5
          b:=StrToInt(RegStr[1+Power-5]);             //
          c:=a xor b;
          str[j]:=chr(c+ord('0'));
        end;
      end;
      RegStr:=str;
    end;
    memoKey.Text:=Key;
  end;
end;

procedure TfrmLFSR.bitbtnRegisterClick(Sender: TObject);
var str: string;
    i,temp: integer;
begin
  RegStr:=editRegisterWrite.Text;
  RegStr:=RegisterCorrect(RegStr);             //корректировка значения регистра
  editRegisterWrite.Text:=RegStr;
  if RegStr='' then                            //проверка регистра
    ShowMessage('ОШИБКА: начальное состояние регистра введено неверно!');
  Power:=StrToInt(editPower.Text);
  if length(RegStr)<Power then                 //проверка регистра
  begin
    ShowMessage('ВНИМАНИЕ: значение регистра меньше степени!');
    for i:= 1 to (Power-length(RegStr)) do
      str:=str+'0';
    RegStr:=str+RegStr;
    editRegisterWrite.Text:=RegStr;
  end;
  if length(RegStr)>Power then                 //проверка регистра
  begin
    ShowMessage('ОШИБКА: значение регистра больше степени!');
    RegStr:='';
    editRegisterWrite.Text:=RegStr;
  end;
  if RegStr<>'' then
    RegInt:=BinaryToDecimal(RegStr);           //перевод из двоичной в десятичн
  Key:='';
end;

procedure TfrmLFSR.bitbtnResetClick(Sender: TObject);
begin
  RegStr:='';
  PlainText:='';
  CipherText:='';
  DecipherText:='';
  Key:='';
  memoPlainText.Text:='';
  memoCipherText.Text:='';
  memoDecipherText.Text:='';
  memoKey.Text:='';
  editRegisterWrite.Text:='';
end;

end.
