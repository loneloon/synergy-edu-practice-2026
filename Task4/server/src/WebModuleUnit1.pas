unit WebModuleUnit1;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Classes,
  System.JSON,
  Web.HTTPApp,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.DApt,
  FireDAC.Phys,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  ServerConst1,
  Data.DB;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1GetUserAction(
      Sender: TObject;
      Request: TWebRequest;
      Response: TWebResponse;
      var Handled: Boolean
    );
    procedure WebModule1CreateUserAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1SignInUserAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1SignOutUserAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1StartActivityAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1ActivityHistoryAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1FinishActivityAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    function CreateConnection: TFDConnection;
    procedure SendJSON(
      Response: TWebResponse;
      const StatusCode: Integer;
      JSONValue: TJSONValue
    );
    procedure SendError(
      Response: TWebResponse;
      const StatusCode: Integer;
      const MessageText: string
    );
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure ApplyCorsHeaders(
  Request: TWebRequest;
  Response: TWebResponse
);
const
  AllowedOrigin = 'http://localhost:8081';
var
  Origin: string;
begin
  Origin := Request.GetFieldByName('Origin');

  if SameText(Origin, AllowedOrigin) then
  begin
    Response.SetCustomHeader(
      'Access-Control-Allow-Origin',
      AllowedOrigin
    );

    Response.SetCustomHeader(
      'Access-Control-Allow-Credentials',
      'true'
    );

    Response.SetCustomHeader(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, PATCH, DELETE, OPTIONS'
    );

    Response.SetCustomHeader(
      'Access-Control-Allow-Headers',
      'Content-Type, Authorization'
    );

    Response.SetCustomHeader(
      'Access-Control-Max-Age',
      '86400'
    );

    Response.SetCustomHeader(
      'Vary',
      'Origin'
    );
  end;
end;

procedure TWebModule1.WebModuleAfterDispatch(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
begin
  ApplyCorsHeaders(Request, Response);
end;

procedure TWebModule1.WebModuleBeforeDispatch(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
begin
  ApplyCorsHeaders(Request, Response);

  if SameText(Request.Method, 'OPTIONS') then
  begin
    Response.StatusCode := 204;
    Response.Content := '';
    Handled := True;
  end;
end;

function GetCookieValue(
  Request: TWebRequest;
  const CookieName: string
): string;
var
  CookieHeader: string;
  Part: string;
  SeparatorPosition: Integer;
  Name: string;
  Value: string;
begin
  Result := '';

  CookieHeader := Request.GetFieldByName('Cookie');

  for Part in CookieHeader.Split([';']) do
  begin
    SeparatorPosition := Part.IndexOf('=');

    if SeparatorPosition < 0 then
      Continue;

    Name := Part.Substring(0, SeparatorPosition).Trim;
    Value := Part.Substring(SeparatorPosition + 1).Trim;

    if SameText(Name, CookieName) then
      Exit(Value);
  end;
end;

function TWebModule1.CreateConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);

  Result.LoginPrompt := False;

  Result.Params.Clear;
  Result.Params.Values['DriverID'] := 'MySQL';
  Result.Params.Values['Server'] := cDbHost;
  Result.Params.Values['Port'] := cDbPort;
  Result.Params.Values['Database'] := cDbName;
  Result.Params.Values['User_Name'] := cDbUser;
  Result.Params.Values['Password'] := cDbPass;
  Result.Params.Values['CharacterSet'] := 'utf8mb4';

  Result.Connected := True;
end;

procedure TWebModule1.SendJSON(
  Response: TWebResponse;
  const StatusCode: Integer;
  JSONValue: TJSONValue
);
begin
  try
    Response.StatusCode := StatusCode;
    Response.ContentType := 'application/json; charset=utf-8';
    Response.Content := JSONValue.ToJSON;
  finally
    JSONValue.Free;
  end;
end;

procedure TWebModule1.WebModule1ActivityHistoryAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  ActivitiesJSON: TJSONArray;
  ActivityJSON: TJSONObject;
  SessionID: string;
  UserID: Int64;
begin
  Handled := True;

  ActivitiesJSON := TJSONArray.Create;
  Connection := nil;
  Query := nil;

  try
    SessionID := GetCookieValue(Request, 'session_id');

    if SessionID.IsEmpty then
    begin
      Response.StatusCode := 401;
      Response.ContentType := 'application/json';
      Response.Content := '{"error":"Authentication required"}';
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    ActivitiesJSON := TJSONArray.Create;

    Query.Connection := Connection;

    // Getting user_id using session_id
    Query.SQL.Text :=
      'SELECT user_id ' +
      'FROM `user_session` ' +
      'WHERE  id = UUID_TO_BIN(:id, 1)';

    Query.ParamByName('id').AsString := SessionID;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Invalid session token');
      Exit;
    end;

    UserID := Query.FieldByName('user_id').AsLargeInt;
    Query.Close;

    Query.SQL.Text :=
      'SELECT ' +
      '  a.id, ' +
      '  a.name, ' +
      '  a.start_ts, ' +
      '  a.end_ts, ' +
      '  ag.name AS group_name ' +
      'FROM activity a ' +
      'JOIN activity_group ag ON ag.id = a.group_id ' +
      'WHERE a.user_id = :user_id AND ' +
      'a.start_ts >= CURDATE() AND ' +
      'a.start_ts < CURDATE() + INTERVAL 1 DAY ' +
      'ORDER BY a.start_ts DESC';

    Query.ParamByName('user_id').AsLargeInt := UserID;
    Query.Open;

    while not Query.Eof do
    begin
      ActivityJSON := TJSONObject.Create;

      ActivityJSON.AddPair(
        'id',
        TJSONNumber.Create(
          Query.FieldByName('id').AsLargeInt
        )
      );

      ActivityJSON.AddPair(
        'name',
        Query.FieldByName('name').AsString
      );

      ActivityJSON.AddPair(
        'startTs',
        Query.FieldByName('start_ts').AsString
      );

      if Query.FieldByName('end_ts').IsNull then
        ActivityJSON.AddPair('endTs', TJSONNull.Create)
      else
        ActivityJSON.AddPair(
          'endTs',
          Query.FieldByName('end_ts').AsString
        );

      ActivityJSON.AddPair(
        'group',
        Query.FieldByName('group_name').AsString
      );

      ActivitiesJSON.AddElement(ActivityJSON);

      Query.Next;
    end;

    Response.StatusCode := 200;
    Response.ContentType := 'application/json; charset=utf-8';
    Response.Content := ActivitiesJSON.ToJSON;

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
  ActivitiesJSON.Free;
end;

procedure TWebModule1.WebModule1CreateUserAction(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  RequestJSON: TJSONValue;
  Body: TJSONObject;
  ResultJSON: TJSONObject;
  Username: string;
  Email: string;
  Secret: string;
  UserID: Int64;
begin
  Handled := True;

  RequestJSON := nil;
  Connection := nil;
  Query := nil;

  try
    RequestJSON := TJSONObject.ParseJSONValue(Request.Content);

    if not (RequestJSON is TJSONObject) then
    begin
      SendError(Response, 400, 'Request body must be a JSON object');
      Exit;
    end;

    Body := TJSONObject(RequestJSON);

    Username := Body.GetValue<string>('username', '');
    Email := Body.GetValue<string>('email', '');
    Secret := Body.GetValue<string>('secret', '');

    if Username.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"username" is required');
      Exit;
    end;

    if Email.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"email" is required');
      Exit;
    end;

    if Secret.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"secret" is required');
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    Query.SQL.Text :=
      'INSERT INTO app_user (username, email, secret) ' +
      'VALUES (:username, :email, :secret)';

    Query.ParamByName('username').AsString := Username;
    Query.ParamByName('email').AsString := Email;
    Query.ParamByName('secret').AsString := Secret;

    Query.ExecSQL;
    Query.Close;

    // Getting user by their credentials
    Query.SQL.Text :=
      'SELECT id ' +
      'FROM `app_user` ' +
      'WHERE username = :username AND secret = :secret';

    Query.ParamByName('username').AsString := Username;
    Query.ParamByName('secret').AsString := Secret;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Wrong credentials');
      Exit;
    end;

    UserID := Query.FieldByName('id').AsLargeInt;
    Query.Close;

    ResultJSON := TJSONObject.Create;
    ResultJSON.AddPair('status', 'created');
    ResultJSON.AddPair('id', UserID);

    SendJSON(Response, 201, ResultJSON);

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
  RequestJSON.Free;
end;

procedure TWebModule1.WebModule1FinishActivityAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  RequestJSON: TJSONValue;
  Body: TJSONObject;
  SessionID: string;
  ActivityName: string;
  GroupName: string;
  UserID: Int64;
begin
  Handled := True;

  RequestJSON := nil;
  Connection := nil;
  Query := nil;

  try
    RequestJSON := TJSONObject.ParseJSONValue(Request.Content);

    if not (RequestJSON is TJSONObject) then
    begin
      SendError(Response, 400, 'Request body must be a JSON object');
      Exit;
    end;

    Body := TJSONObject(RequestJSON);

    ActivityName := Body.GetValue<string>('activity_name', '');
    GroupName := Body.GetValue<string>('group_name', '');

    if ActivityName.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"activity_name" is required');
      Exit;
    end;

    if GroupName.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"group_name" is required');
      Exit;
    end;

    SessionID := GetCookieValue(Request, 'session_id');

    if SessionID.IsEmpty then
    begin
      Response.StatusCode := 401;
      Response.ContentType := 'application/json';
      Response.Content := '{"error":"Authentication required"}';
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    // Getting user_id using session_id
    Query.SQL.Text :=
      'SELECT user_id ' +
      'FROM `user_session` ' +
      'WHERE id = UUID_TO_BIN(:id, 1)';

    Query.ParamByName('id').AsString := SessionID;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Invalid session token');
      Exit;
    end;

    UserID := Query.FieldByName('user_id').AsLargeInt;
    Query.Close;

    // Updating end_ts on activity
    Query.SQL.Text :=
      'UPDATE activity ' +
      'SET end_ts = CURRENT_TIMESTAMP ' +
      'WHERE name = :act_name AND ' +
      'group_id = (select id from activity_group ' +
      'WHERE name = :group_name) AND ' +
      'user_id = :user_id AND ' +
      'end_ts IS NULL ' +
      'ORDER BY id DESC ' +
      'LIMIT 1';

    Query.ParamByName('act_name').AsString := ActivityName;
    Query.ParamByName('group_name').AsString := GroupName;
    Query.ParamByName('user_id').AsLargeInt := UserID;
    Query.ExecSQL;
    Query.Close;

    Response.StatusCode := 200;
    Response.ContentType := 'application/json';
    Response.Content := '{"status":"ok"}';

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
  RequestJSON.Free;
end;

procedure TWebModule1.WebModule1GetUserAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  JSON: TJSONObject;
  SessionID: string;
  UserID: Int64;
begin
  Handled := True;

  Connection := nil;
  Query := nil;

  try
    SessionID := GetCookieValue(Request, 'session_id');

    if SessionID.IsEmpty then
    begin
      Response.StatusCode := 401;
      Response.ContentType := 'application/json';
      Response.Content := '{"error":"Authentication required"}';
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    // Getting user_id using session_id
    Query.SQL.Text :=
      'SELECT user_id ' +
      'FROM `user_session` ' +
      'WHERE  id = UUID_TO_BIN(:id, 1)';

    Query.ParamByName('id').AsString := SessionID;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Invalid session token');
      Exit;
    end;

    UserID := Query.FieldByName('user_id').AsLargeInt;
    Query.Close;

    Query.SQL.Text :=
      'SELECT id, username, email ' +
      'FROM `app_user` ' +
      'WHERE id = :id';

    Query.ParamByName('id').AsLargeInt := UserID;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'User not found');
      Exit;
    end;

    JSON := TJSONObject.Create;
    JSON.AddPair('id', TJSONNumber.Create(Query.FieldByName('id').AsLargeInt));
    JSON.AddPair('username', Query.FieldByName('username').AsString);
    JSON.AddPair('email', Query.FieldByName('email').AsString);

    SendJSON(Response, 200, JSON);

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
end;

procedure TWebModule1.WebModule1SignInUserAction(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  RequestJSON: TJSONValue;
  Body: TJSONObject;
  ResultJSON: TJSONObject;
  Username: string;
  Secret: string;
  UserID: Int64;
  SessionID: string;
begin
  Handled := True;

  RequestJSON := nil;
  Connection := nil;
  Query := nil;

  try
    RequestJSON := TJSONObject.ParseJSONValue(Request.Content);

    if not (RequestJSON is TJSONObject) then
    begin
      SendError(Response, 400, 'Request body must be a JSON object');
      Exit;
    end;

    Body := TJSONObject(RequestJSON);

    Username := Body.GetValue<string>('username', '');
    Secret := Body.GetValue<string>('secret', '');

    if Username.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"username" is required');
      Exit;
    end;

    if Secret.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"secret" is required');
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    // Getting user by their credentials
    Query.SQL.Text :=
      'SELECT id ' +
      'FROM `app_user` ' +
      'WHERE username = :username AND secret = :secret';

    Query.ParamByName('username').AsString := Username;
    Query.ParamByName('secret').AsString := Secret;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Wrong credentials');
      Exit;
    end;

    UserId := Query.FieldByName('id').AsLargeInt;
    Query.Close;

    // Creating new user session
    Query.SQL.Text :=
      'INSERT IGNORE INTO user_session (user_id) ' +
      'VALUES (:user_id)';

    Query.ParamByName('user_id').AsLargeInt := UserID;
    Query.ExecSQL;
    Query.Close;

    // Getting user session id
    Query.SQL.Text :=
      'SELECT BIN_TO_UUID(id, 1) as uuid_str ' +
      'FROM `user_session` ' +
      'WHERE user_id = :user_id';

    Query.ParamByName('user_id').AsLargeInt := UserID;
    Query.Open;

    SessionID := Query.FieldByName('uuid_str').AsString;
    Query.Close;

    Response.SetCustomHeader(
      'Set-Cookie',
      'session_id=' + SessionID +
      '; Path=/' +
      '; HttpOnly' +
      '; SameSite=Lax' +
      '; Max-Age=3600'
    );

    ResultJSON := TJSONObject.Create;
    ResultJSON.AddPair('status', 'ok');
    ResultJSON.AddPair('session_id', SessionID);

    SendJSON(Response, 200, ResultJSON);

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
  RequestJSON.Free;
end;

procedure TWebModule1.WebModule1SignOutUserAction(
  Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
label
  Finalize;
var
  Connection: TFDConnection;
  Query: TFDQuery;
  SessionID: string;
begin
  Handled := True;
  Connection := nil;
  Query := nil;

  try
    SessionID := GetCookieValue(Request, 'session_id');

    if SessionID.IsEmpty then
    begin
      goto Finalize;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    Query.SQL.Text :=
        'DELETE FROM user_session ' +
        'WHERE id = UUID_TO_BIN(:id, 1)';

    Query.ParamByName('id').AsString := SessionID;
    Query.ExecSQL;
    Query.Close;

    Response.SetCustomHeader(
      'Set-Cookie',
      'session_id=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0'
    );

    Finalize:
      Response.StatusCode := 200;
      Response.ContentType := 'application/json';
      Response.Content := '{"status":"ok"}';
  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
end;

procedure TWebModule1.SendError(
  Response: TWebResponse;
  const StatusCode: Integer;
  const MessageText: string
);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  JSON.AddPair('error', MessageText);

  SendJSON(Response, StatusCode, JSON);
end;

procedure TWebModule1.WebModule1StartActivityAction(Sender: TObject;
  Request: TWebRequest;
  Response: TWebResponse;
  var Handled: Boolean
);
var
  Connection: TFDConnection;
  Query: TFDQuery;
  RequestJSON: TJSONValue;
  Body: TJSONObject;
  SessionID: string;
  ActivityName: string;
  GroupName: string;
  UserID: Int64;
begin
  Handled := True;

  RequestJSON := nil;
  Connection := nil;
  Query := nil;

  try
    RequestJSON := TJSONObject.ParseJSONValue(Request.Content);

    if not (RequestJSON is TJSONObject) then
    begin
      SendError(Response, 400, 'Request body must be a JSON object');
      Exit;
    end;

    Body := TJSONObject(RequestJSON);

    ActivityName := Body.GetValue<string>('activity_name', '');
    GroupName := Body.GetValue<string>('group_name', '');

    if ActivityName.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"activity_name" is required');
      Exit;
    end;

    if GroupName.Trim.IsEmpty then
    begin
      SendError(Response, 400, '"group_name" is required');
      Exit;
    end;

    SessionID := GetCookieValue(Request, 'session_id');

    if SessionID.IsEmpty then
    begin
      Response.StatusCode := 401;
      Response.ContentType := 'application/json';
      Response.Content := '{"error":"Authentication required"}';
      Exit;
    end;

    Connection := CreateConnection;

    Query := TFDQuery.Create(nil);
    Query.Connection := Connection;

    // Getting user_id using session_id
    Query.SQL.Text :=
      'SELECT user_id ' +
      'FROM `user_session` ' +
      'WHERE  id = UUID_TO_BIN(:id, 1)';

    Query.ParamByName('id').AsString := SessionID;
    Query.Open;

    if Query.IsEmpty then
    begin
      SendError(Response, 404, 'Invalid session token');
      Exit;
    end;

    UserID := Query.FieldByName('user_id').AsLargeInt;
    Query.Close;

    // Saving a new activity
    Query.SQL.Text :=
      'INSERT INTO activity (name, group_id, user_id) VALUES ' +
      '(:act_name, (select id from activity_group ' +
      'WHERE name = :group_name), :user_id)';

    Query.ParamByName('act_name').AsString := ActivityName;
    Query.ParamByName('group_name').AsString := GroupName;
    Query.ParamByName('user_id').AsLargeInt := UserID;
    Query.ExecSQL;
    Query.Close;

    Response.StatusCode := 200;
    Response.ContentType := 'application/json';
    Response.Content := '{"status":"ok"}';

  except
    on E: Exception do
      SendError(Response, 500, 'Database error: ' + E.Message);
  end;

  Query.Free;
  Connection.Free;
  RequestJSON.Free;
end;

end.
