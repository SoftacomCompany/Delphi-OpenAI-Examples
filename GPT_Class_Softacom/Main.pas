unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.StdCtrls, FMX.Controls.Presentation, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Rtti,
  FMX.ScrollBox, FMX.Grid, FMX.Memo, FMX.TabControl, FMX.Memo.Types,
  Json, FMX.Objects, ChatGPTHelper;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ShadowEffect4: TShadowEffect;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Button1: TButton;
    TabItem2: TTabItem;
    ResponseMemo: TMemo;
    Label2: TLabel;
    Label4: TLabel;
    RequestMemo: TMemo;
    MessageMemo: TMemo;
    NetHTTPClient1: TNetHTTPClient;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FOpenAIApiKey: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.Threading, System.Net.Mime, System.IOUtils;

procedure TForm1.Button1Click(Sender: TObject);
var
  GPTHelper: IChatGPTHelper;
  JsonAnswer: string;
begin
  GPTHelper := TChatGPT.Create(NetHTTPClient1, FOpenAIApiKey);
  ResponseMemo.Lines.Clear;
  MessageMemo.Lines.Clear;
  TTask.Run(
    procedure
    begin
      JsonAnswer := GPTHelper.SendTextToChatGPT(RequestMemo.Text);
      TThread.Synchronize(nil,
        procedure
        begin
          ResponseMemo.Text := JsonAnswer;
          MessageMemo.Text := TChatGPT.MessageContentFromChatGPT(JsonAnswer);
          TabControl1.GotoVisibleTab(1);
        end);
    end);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FOpenAIApiKey := 'Bearer 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';
end;

end.
