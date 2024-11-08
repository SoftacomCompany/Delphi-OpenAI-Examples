unit ChatGPTHelper;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, JSON, System.Threading,
  System.Net.Mime, System.Generics.Collections;

type
  IChatGPTHelper = interface
    function SendTextToChatGPT(const Text: string): string;
  end;

  TChatGPT = class(TInterfacedObject, IChatGPTHelper)
  private
    FNetHttpClient: TNetHTTPClient;
    FOpenAIApiKey: string;
    FText: string;
    function FormatJSON(const JSON: string): string;
    function SendTextToChatGPT(const Text: string): string;
  public
    constructor Create(const NetHttpClient: TNetHTTPClient;
      const OpenAIApiKey: string);
    class function MessageContentFromChatGPT(const JsonAnswer: string): string;
  end;

implementation

{ TFirebaseAuth }

constructor TChatGPT.Create(const NetHttpClient: TNetHTTPClient;
  const OpenAIApiKey: string);
begin
  FNetHttpClient := NetHttpClient;
  if OpenAIApiKey <> '' then
    FOpenAIApiKey := OpenAIApiKey
  else
  begin
    ShowMessage('OpenAI API key is empty!');
    Exit;
  end;
end;

function TChatGPT.FormatJSON(const JSON: string): string;
var
  JsonObject: TJsonObject;
begin
  JsonObject := TJsonObject.ParseJSONValue(JSON) as TJsonObject;
  try
    if Assigned(JsonObject) then
      Result := JsonObject.Format()
    else
      Result := JSON;
  finally
    JsonObject.Free;
  end;
end;

class function TChatGPT.MessageContentFromChatGPT(const JsonAnswer: string): string;
var
  Mes: TJsonArray;
  JsonResp: TJsonObject;
begin
  JsonResp := nil;
  try
    JsonResp := TJsonObject.ParseJSONValue(JsonAnswer) as TJsonObject;
    if Assigned(JsonResp) then
    begin
      Mes := TJsonArray(JsonResp.Get('choices').JsonValue);
      Result := TJsonObject(TJsonObject(Mes.Get(0)).Get('message').
      JsonValue).GetValue('content').Value;
    end
    else
      Result := '';
  finally
    JsonResp.Free;
  end;
end;

function TChatGPT.SendTextToChatGPT(const Text: string): string;
var
  JArr: TJsonArray; JObj, JObjOut: TJsonObject; Request: string;
  ResponseContent: TStringStream;
  Headers: TArray<TNameValuePair>;
  I: Integer;
  StringStream: TStringStream;
begin
  JArr := nil;
  JObj := nil;
  JObjOut := nil;
  ResponseContent := nil;
  StringStream := nil;
  try
    SetLength(Headers, 2);
    Headers[0] := TNameValuePair.Create('Authorization', FOpenAIApiKey);
    Headers[1] := TNameValuePair.Create('Content-Type', 'application/json');
    JObj := TJsonObject.Create;
    JObj.Owned := False;
    JObj.AddPair('role', 'user');
    JArr := TJsonArray.Create;
    JArr.AddElement(JObj);
    Self.FText := Text;
    JObj.AddPair('content', FText);
    JObjOut := TJsonObject.Create;
    JObjOut.AddPair('model', 'gpt-3.5-turbo');
    JObjOut.AddPair('messages', Trim(JArr.ToString));
    JObjOut.AddPair('temperature', TJSONNumber.Create(0.7));
    Request := JObjOut.ToString.Replace('\', '');
    for I := 0 to Length(Request) - 1 do
    begin
      if ((Request[I] = '"') and (Request[I + 1] = '[')) or
        ((Request[I] = '"') and (Request[I - 1] = ']')) then
      begin
        Request[I] := ' ';
      end;
    end;
    ResponseContent := TStringStream.Create;
    StringStream := TStringStream.Create(Request, TEncoding.UTF8);
    FNetHttpClient.Post('https://api.openai.com/v1/chat/completions',
      StringStream, ResponseContent, Headers);
    Result := FormatJSON(ResponseContent.DataString);
  finally
    StringStream.Free;
    ResponseContent.Free;
    JObjOut.Free;
    JArr.Free;
    JObj.Free;
  end;
end;

end.
