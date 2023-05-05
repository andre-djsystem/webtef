unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls;

type
  { TfrMain }

  TfrMain = class(TForm)
    btnCreateRefund: TButton;
    btnGetPayments: TButton;
    btnGetPaymentsIntents: TButton;
    btnGetPaymentIntents: TButton;
    btnCreatePayment: TButton;
    btnCancelPayment: TButton;
    btnGenerateAccessToken: TButton;
    btnGetPaymentIntentsLastStatus: TButton;
    btnGetPayment: TButton;
    btnRefreshToken: TButton;
    btnGetDevices: TButton;
    btnChangeOperatingMode: TButton;
    edAccessToken: TEdit;
    edClientId: TEdit;
    edCode: TEdit;
    edRedirectURI: TEdit;
    edDeviceId: TEdit;
    edClientSecret: TEdit;
    edPaymentIntentId: TEdit;
    edPayment: TEdit;
    edRefreshToken: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    mAnswer: TMemo;
    pnCommands: TPanel;
    pgMain: TPageControl;
    tsMethods: TTabSheet;
    tsConfig: TTabSheet;
    procedure btnCancelPaymentClick(Sender: TObject);
    procedure btnCreatePaymentClick(Sender: TObject);
    procedure btnCreateRefundClick(Sender: TObject);
    procedure btnGenerateAccessTokenClick(Sender: TObject);
    procedure btnGetDevicesClick(Sender: TObject);
    procedure btnChangeOperatingModeClick(Sender: TObject);
    procedure btnGetPaymentClick(Sender: TObject);
    procedure btnGetPaymentIntentsClick(Sender: TObject);
    procedure btnGetPaymentIntentsLastStatusClick(Sender: TObject);
    procedure btnGetPaymentsClick(Sender: TObject);
    procedure btnGetPaymentsIntentsClick(Sender: TObject);
    procedure btnRefreshTokenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    function CreateAccessToken(const AClientSecret, AClientId, ACode, ARedirectUri: String): String;
    function CreateRefreshToken(const AClientSecret, AClientId, ARefreshToken: String): String;
    function GetDevices(const AToken: String): String;
    function ChangeOperatingMode(const AToken, ADevice, ANewMode: String): String;
    function CreatePayment(const AToken, ADevice, ADescription: String;
      const AAmount: Double; const AInstallments: Integer;
      const AType: String; const AInstallmentsCost: String;
      const AExternalReference: String; const APrintOnTerminal: Boolean): String;
    function CancelPayment(const AToken, ADevice, APaymentIntentId: String): String;
    function GetPaymentIntents(const AToken, APaymentIntentId: String): String;
    function GetPaymentIntentsLastStatus(const AToken, APaymentIntentId: String): String;
    function GetPayment(const AToken, AIdPayment: String): String;
    function CreateRefund(const AToken, AIdPayment: String; const AAmount: Double = 0): String;
    function GetPaymentIntentsEvents(const AToken: String; const AStartDate, AEndDate: TDate): String;
    function GetPaymentsList(const AToken: String; const ADays: Integer): String;
  public

  end;

var
  frMain: TfrMain;

implementation

uses RESTRequest4D, fpjson, DateUtils, IniFiles;

{$R *.lfm}

{ TfrMain }

procedure TfrMain.btnGetDevicesClick(Sender: TObject);
var
  LJSonAnswer: TJSONData;
begin
  mAnswer.Clear;
  LJSonAnswer := GetJSON(GetDevices(edAccessToken.Text));

  try
    mAnswer.Lines.Add(LJSonAnswer.AsJSON);
    edDeviceId.Text := LJSonAnswer.GetPath('devices').Items[0].GetPath('id').AsString; //Pega o primeiro dispositivo da lista
  finally
    LJSonAnswer.Free;
  end;
end;

procedure TfrMain.btnCreatePaymentClick(Sender: TObject);
var
  LJSonAnswer: TJSONData;
begin
  mAnswer.Clear;

  LJSonAnswer := GetJSON(CreatePayment(edAccessToken.Text,
                                  edDeviceId.Text,
                                  'Teste de Pagamento 0001',
                                  1,
                                  1,
                                  'credit_card',
                                  'seller',
                                  'Pedido 0001',
                                  false));

  try
    mAnswer.Lines.Add(LJSonAnswer.AsJSON);
    edPaymentIntentId.Text := LJSonAnswer.GetPath('id').AsString;
  finally
    LJSonAnswer.Free;
  end;
end;

procedure TfrMain.btnCreateRefundClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(CreateRefund(edAccessToken.Text, edPayment.Text, 1));
end;

procedure TfrMain.btnGenerateAccessTokenClick(Sender: TObject);
var
  LJSonAnswer: TJSONData;
begin
  mAnswer.Clear;

  LJSonAnswer := GetJSON(CreateAccessToken(edClientSecret.Text, edClientId.Text, edCode.Text, edRedirectURI.Text));

  try
    mAnswer.Lines.Add(LJSonAnswer.AsJSON);
    if Assigned(LJSonAnswer.FindPath('access_token')) then
      edAccessToken.Text := LJSonAnswer.GetPath('access_token').AsString;
    if Assigned(LJSonAnswer.FindPath('refresh_token')) then
      edRefreshToken.Text := LJSonAnswer.GetPath('refresh_token').AsString;
  finally
    LJSonAnswer.Free;
  end;
end;

procedure TfrMain.btnCancelPaymentClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(CancelPayment(edAccessToken.Text, edDeviceId.Text, edPaymentIntentId.Text));
end;

procedure TfrMain.btnChangeOperatingModeClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(ChangeOperatingMode(edAccessToken.Text, edDeviceId.Text,'PDV'));
end;

procedure TfrMain.btnGetPaymentClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(GetPayment(edAccessToken.Text, edPayment.Text));
end;

procedure TfrMain.btnGetPaymentIntentsClick(Sender: TObject);
var
  LJSonAnswer: TJSONData;
begin
  mAnswer.Clear;

  LJSonAnswer := GetJSON(GetPaymentIntents(edAccessToken.Text,  edPaymentIntentId.Text));

  try
    mAnswer.Lines.Add(LJSonAnswer.AsJSON);
    if Assigned(LJSonAnswer.FindPath('payment.id')) then
      edPayment.Text := LJSonAnswer.GetPath('payment.id').AsString;
  finally
    LJSonAnswer.Free;
  end;
end;

procedure TfrMain.btnGetPaymentIntentsLastStatusClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(GetPaymentIntentsLastStatus(edAccessToken.Text,  edPaymentIntentId.Text));
end;

procedure TfrMain.btnGetPaymentsClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(GetPaymentsList(edAccessToken.Text, 30));
end;

procedure TfrMain.btnGetPaymentsIntentsClick(Sender: TObject);
begin
  mAnswer.Clear;
  mAnswer.Lines.Add(GetPaymentIntentsEvents(edAccessToken.Text, IncDay(Now, -30), Now));
end;

procedure TfrMain.btnRefreshTokenClick(Sender: TObject);
var
  LJSonAnswer: TJSONData;
begin
  mAnswer.Clear;

  LJSonAnswer := GetJSON(CreateRefreshToken(edClientSecret.Text, edClientId.Text, edRefreshToken.Text));

  try
    mAnswer.Lines.Add(LJSonAnswer.AsJSON);
    if Assigned(LJSonAnswer.FindPath('access_token')) then
      edAccessToken.Text := LJSonAnswer.GetPath('access_token').AsString;
    if Assigned(LJSonAnswer.FindPath('refresh_token')) then
      edRefreshToken.Text := LJSonAnswer.GetPath('refresh_token').AsString;
  finally
    LJSonAnswer.Free;
  end;
end;

procedure TfrMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  LIni: TIniFile;
begin
  LIni := TIniFile.Create(ChangeFileExt(ExtractFileName(Application.ExeName),'.ini'));
  try
    LIni.WriteString('WebTef', 'AccessToken', edAccessToken.Text);
    LIni.WriteString('WebTef', 'ClientSecret', edClientSecret.Text);
    LIni.WriteString('WebTef', 'ClientId', edClientId.Text);
    LIni.WriteString('WebTef', 'Code', edCode.Text);
    LIni.WriteString('WebTef', 'RedirectURI', edRedirectURI.Text);
    LIni.WriteString('WebTef', 'RefreshToken', edRefreshToken.Text);
  finally
    LIni.Free;
  end;
end;

procedure TfrMain.FormCreate(Sender: TObject);
var
  LFileName: String;
  LIni: TIniFile;
begin
  pgMain.ActivePage := tsMethods;
  LFileName := ChangeFileExt(ExtractFileName(Application.ExeName),'.ini');
  if FileExists(LFileName) then
  begin
    LIni := TIniFile.Create(LFileName);
    try
      edAccessToken.Text := LIni.ReadString('WebTef', 'AccessToken', '');
      edClientSecret.Text := LIni.ReadString('WebTef', 'ClientSecret', '');
      edClientId.Text := LIni.ReadString('WebTef', 'ClientId', '');
      edCode.Text := LIni.ReadString('WebTef', 'Code', '');
      edRedirectURI.Text := LIni.ReadString('WebTef', 'RedirectURI', '');
      edRefreshToken.Text := LIni.ReadString('WebTef', 'RefreshToken', '');
    finally
      LIni.Free;
    end;
  end;
end;


function TfrMain.CreateAccessToken(const AClientSecret, AClientId,
  ACode, ARedirectUri: String): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    LJson.Add('client_secret', AClientSecret);
    LJson.Add('client_id', AClientId);
    LJson.Add('grant_type', 'authorization_code');
    LJson.Add('redirect_uri', ACode);
    LJson.Add('redirect_uri', ARedirectUri);

    LResponse := TRequest
                         .New.BaseURL('https://api.mercadopago.com/oauth/token')
                         .ContentType(' LJson: TJSONObject;  ')
                         .ContentType('application/json')
                         .AddBody(LJson.AsJSON)
                         .Post;

  finally
    LJson.Free;
  end;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.CreateRefreshToken(const AClientSecret, AClientId,
  ARefreshToken: String): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    LJson.Add('client_secret', AClientSecret);
    LJson.Add('client_id', AClientId);
    LJson.Add('grant_type', 'refresh_token');
    LJson.Add('refresh_token', ARefreshToken);

    LResponse := TRequest
                         .New.BaseURL('https://api.mercadopago.com/oauth/token')
                         .ContentType(' LJson: TJSONObject;  ')
                         .ContentType('application/json')
                         .AddBody(LJson.AsJSON)
                         .Post;

  finally
    LJson.Free;
  end;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.GetDevices(const AToken: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL('https://api.mercadopago.com/point/integration-api/devices')
                       .TokenBearer(AToken)
                       .Get;
  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.ChangeOperatingMode(const AToken, ADevice, ANewMode: String
  ): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    LJson.Add('operating_mode', ANewMode);
    LResponse := TRequest
                         .New.BaseURL('https://api.mercadopago.com/point/integration-api/devices/'+ADevice)
                         .TokenBearer(AToken)
                         .ContentType('application/json')
                         .AddBody(LJson.AsJSON)
                         .Patch;
  finally
    LJson.Free;
  end;
  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.CreatePayment(const AToken, ADevice, ADescription: String;
  const AAmount: Double; const AInstallments: Integer; const AType: String;
  const AInstallmentsCost: String; const AExternalReference: String;
  const APrintOnTerminal: Boolean): String;
var
  LResponse: IResponse;
  LJson, LPayment, LAdditionalInfo: TJSONObject;
begin
  if (AInstallments > 1) and
     ((AAmount/AInstallments) < 5) then
     raise Exception.Create('Valor da parcela não pode ser menor que R% 5,00');

  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    LJson.Add('amount', Trunc(AAmount*100));
    LJson.Add('description', ADescription);
    LPayment := TJSONObject.Create;
    LPayment.Add('installments', AInstallments);
    LPayment.Add('type', AType);
    LPayment.Add('installments_cost', AInstallmentsCost);
    LJson.Add('payment', LPayment);
    LAdditionalInfo := TJSONObject.Create;
    LAdditionalInfo.Add('external_reference', AExternalReference);
    LAdditionalInfo.Add('print_on_terminal', APrintOnTerminal);
    LJson.Add('additional_info', LAdditionalInfo);
    LResponse := TRequest
                         .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/devices/%s/payment-intents',[ADevice]))
                         .TokenBearer(AToken)
                         .ContentType('application/json')
                         .AddBody(LJson.AsJSON)
                         .Post;
  finally
    LJson.Free;
  end;
  Result := LResponse.Content;
  if (LResponse.StatusCode <> 201) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.CancelPayment(const AToken, ADevice, APaymentIntentId: String
  ): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/devices/%s/payment-intents/%s',[ADevice, APaymentIntentId]))
                       .TokenBearer(AToken)
                       .Delete;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.GetPaymentIntents(const AToken, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/%s',[APaymentIntentId]))
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.GetPaymentIntentsLastStatus(const AToken,
  APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/%s/events',[APaymentIntentId]))
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;


function TfrMain.GetPayment(const AToken, AIdPayment: String): String;
var
  LResponse: IResponse;
begin
  if (AIdPayment = EmptyStr) then
    raise Exception.Create('Id do Pagamento não informado');

  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/%s',[AIdPayment]))
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
    raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.CreateRefund(const AToken, AIdPayment: String;
  const AAmount: Double): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    //LJson.Add('amount', Trunc(AAmount*100));
    LResponse := TRequest
                         .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/%s/refunds',[AIdPayment]))
                         .TokenBearer(AToken)
                         //.ContentType('application/json')
                         //.AddBody(LJson.AsJSON)
                         .Post;
  finally
    LJson.Free;
  end;
  Result := LResponse.Content;
  if (LResponse.StatusCode <> 201) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.GetPaymentIntentsEvents(const AToken: String;
  const AStartDate, AEndDate: TDate): String;
var
  LResponse: IResponse;
begin
  if (AStartDate > AEndDate) then
    raise Exception.Create('Data Inicial não pode ser maior que a data final');

  if (DaysBetween(AStartDate, AEndDate) > 30) then
    raise Exception.Create('O intervalo não pode ser maior que 30 dias');

  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/events?startDate=%s&endDate=%s',
                                           [FormatDateTime('yyyy-mm-dd',AStartDate), FormatDateTime('yyyy-mm-dd',AEndDate)]))
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function TfrMain.GetPaymentsList(const AToken: String; const ADays: Integer
  ): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/search?sort=date_created&criteria=desc&range=date_created&begin_date=NOW-%dDAYS&end_date=NOW',
                                           [ADays]))
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

end.

