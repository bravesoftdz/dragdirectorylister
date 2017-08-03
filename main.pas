unit
 main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Winapi.ShellApi, System.IOUtils,
  Vcl.Buttons, Vcl.ExtDlgs, Vcl.Grids;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    lblFolder: TLabel;
    SpeedButton1: TSpeedButton;
    SaveTextFileDialog1: TSaveTextFileDialog;
    Label1: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    folderPath : string;
    procedure WMDROPFILES(var msg : TWMDropFiles) ; message WM_DROPFILES;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure GetListOfFiles(aFolder : string; var fl : TStringList);
    function ChecklineCount(fl : TStringList): Boolean;
    function SuggestFileName(aFolder : string): string;
  public
    { Public declarations }
  end;

const
  MemoCapacity = 22;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.ChecklineCount(fl: TStringList): Boolean;
begin
  if fl.Count >= MemoCapacity then
      result := true;
end;

procedure TForm1.CreateWnd;
begin
  inherited;
  DragAcceptFiles(Handle, True);

end;

procedure TForm1.DestroyWnd;
begin
  DragAcceptFiles(Handle, false);
  inherited;

end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  SaveTextFileDialog1.Filter := 'Text files (*.txt)|*.TXT|Any file (*.*)|*.*';
end;

procedure TForm1.GetListOfFiles(aFolder : string; var fl: TStringList);
 var
   sr : TSearchRec;
 begin
    fl := TStringList.Create;
   try
     if FindFirst( aFolder + '\' + '*.*', faDirectory, sr) < 0 then
       Exit
     else
     repeat
       if ((sr.Attr and faDirectory <> 0) AND (sr.Name <> '.') AND (sr.Name <> '..')) then
        begin
         fl.Add(sr.Name) ;
        end;
     until FindNext(sr) <> 0;
   finally
     FindClose(sr) ;
   end;



end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  fileName : string;
begin
    SaveTextFileDialog1.FileName := SuggestFileName(folderPath);
    if SaveTextFileDialog1.Execute then
    begin
      fileName := SaveTextFileDialog1.FileName;
      // + '.' + SaveTextFileDialog1.FilterIndex;
      //ShowMessage(fileName);
      // Memo1.Lines.SaveToFile(SaveTextFileDialog1.FileName );
      Memo1.Lines.SaveToFile(filename);
    end;
  //Edit1.Text := SaveTextFileDialog1.Encodings[SaveTextFileDialog1.EncodingIndex];

end;

function TForm1.SuggestFileName(aFolder: string): string;
var
  tmp : string;
begin
  tmp := aFolder.Substring(aFolder.IndexOf('\') + 1);

  result := tmp.Replace('\','_');

end;

procedure TForm1.WMDROPFILES(var msg: TWMDropFiles);
var
  i, fileCount: integer;
  fileName: array[0..MAX_PATH] of char;
  folderList : TStringList;
  tmp : string;
begin
  SpeedButton1.Visible := false;
  fileCount:=DragQueryFile(msg.Drop, $FFFFFFFF, fileName, MAX_PATH);

  if fileCount = 1 then
  begin
    for i := 0 to fileCount - 1 do
    begin
      DragQueryFile(msg.Drop, i, fileName, MAX_PATH);
    end;
    DragFinish(msg.Drop);

    if TDirectory.Exists(fileName) then
    begin
    tmp := fileName;
    lblFolder.Caption := tmp;
    folderPath := tmp;

      GetListOfFiles(folderPath, folderList);
            //  ShowMessage(SuggestFileName(fileName));
      if ChecklineCount(folderList) then
          Memo1.ScrollBars := ssVertical;

     Memo1.Lines := folderList;
     Memo1.Visible := true;
     SpeedButton1.Visible := true;
     end;
  end;

end;

end.
