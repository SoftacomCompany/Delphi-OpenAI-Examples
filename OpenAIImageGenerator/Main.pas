unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.StdCtrls, FMX.Controls.Presentation, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Rtti,
  FMX.ScrollBox, FMX.Grid, FMX.Memo, FMX.TabControl, FMX.Memo.Types,
{$IFDEF ANDROID}
  FMX.Helpers.Android, Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
{$ENDIF} Json, FMX.Objects, System.Threading,
  System.Net.Mime, System.IOUtils, ChatGPTHelper, IdBaseComponent, IdCoder,
  IdCoder3to4, IdCoderMIME;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ShadowEffect4: TShadowEffect;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Button1: TButton;
    TabItem2: TTabItem;
    Label2: TLabel;
    NetHTTPClient1: TNetHTTPClient;
    PromptMemo: TMemo;
    Image1: TImage;
    ResponseMemo: TMemo;
    Label4: TLabel;
    Response: TLabel;
    IdDecoderMIME1: TIdDecoderMIME;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FTask1,FTask2: ITask;
    FImageURL: string;
    FOpenAIApiKey: string;
    FBase64String: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  GPTHelper: IChatGPTHelper;
  JsonResponse: string;
  ImageStream: TMemoryStream;
begin
  TTask.Run(
    procedure
    begin
      ImageStream := nil;
      try
        GPTHelper := TChatGPT.Create(NetHTTPClient1, FOpenAIApiKey);
        JsonResponse := GPTHelper.GetJSONWithImage(PromptMemo.Text, 1);
        TThread.Synchronize(nil,
          procedure
          begin
            ResponseMemo.Text := JsonResponse;
            FBase64String := GPTHelper.GetImageBASE64FromJSON(JsonResponse);
            ImageStream := TMemoryStream.Create;
            IdDecoderMIME1.DecodeStream(FBase64String, ImageStream);
            Image1.Bitmap.LoadFromStream(ImageStream);
            TabControl1.GotoVisibleTab(1);
            ShowMessage('All is done!!!');
          end);
      finally
        ImageStream.Free;
      end;
    end);
end;


procedure TForm1.Button2Click(Sender: TObject);
var
  GPTHelper: IChatGPTHelper;
  JsonResponse: string;
  ImageStream: TMemoryStream;
begin
  FTask1 := TTask.Run(
    procedure
    begin
      GPTHelper := TChatGPT.Create(NetHTTPClient1, FOpenAIApiKey);
      JsonResponse := GPTHelper.GetJSONWithImage(PromptMemo.Text, 0);
      TThread.Synchronize(nil,
        procedure
        begin
          ResponseMemo.Text := JsonResponse;
          FImageURL := GPTHelper.GetImageURLFromJSON(JsonResponse);
        end);
    end);
  if FTask1.Status = TTaskStatus.Created then
    FTask1.Start;
  FTask2 := TTask.Run(
    procedure
    begin
      TTask.WaitForAny(FTask1);
      ImageStream := GPTHelper.GetImageAsStream(FImageURL);
      try
        TThread.Synchronize(nil,
          procedure
          begin
            Image1.Bitmap.LoadFromStream(ImageStream);
            TabControl1.GotoVisibleTab(1);
            ShowMessage('All is done!!!');
          end);
      finally
        ImageStream.Free;
      end;
    end);
  if FTask2.Status = TTaskStatus.Created then
    FTask2.Start;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FOpenAIApiKey := 'Bearer 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';
end;

end.

