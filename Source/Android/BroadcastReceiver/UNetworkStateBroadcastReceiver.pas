unit UNetworkStateBroadcastReceiver;

interface

uses
  System.SysUtils, System.Classes, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.helpers, UBroadcastReceiver, Androidapi.JNI.Net, Androidapi.JNI.OS,
  Androidapi.JNI.JavaTypes;

type
  TNetworkStateBroadcastReceiver = class (TBroadcastReceiver)
  private
    FOnConnectivityAction: TNotifyEvent;
  protected
    procedure DoReceiveBroadcast(AContext: JContext; AIntent: JIntent; AResultCode: integer); override;
  public
    constructor Create(
      AOwner: TComponent; AOnConnectivityAction: TNotifyEvent
    ); reintroduce;
  end;

implementation

const
  CONNECTIVITY_ACTION = 'android.net.conn.CONNECTIVITY_CHANGE';

{ UNetworkStateBroadcastManager }

constructor TNetworkStateBroadcastReceiver.Create(
  AOwner: TComponent; AOnConnectivityAction: TNotifyEvent
);
begin
  inherited Create(AOwner, self.DoReceiveBroadcast);
  self.FOnConnectivityAction := AOnConnectivityAction;

  self.AddActions([
    StringToJString(CONNECTIVITY_ACTION)
  ]);
end;

procedure TNetworkStateBroadcastReceiver.DoReceiveBroadcast(AContext: JContext;
  AIntent: JIntent; AResultCode: integer);
var
  Action: string;
begin
  inherited;

  Action := JStringToString(AIntent.getAction);

  if Action = CONNECTIVITY_ACTION then begin
    if(AIntent.getExtras() <> nil) then begin
      if Assigned(self.FOnConnectivityAction) then begin
        TThread.Synchronize(
          nil,
          procedure
          begin
            self.FOnConnectivityAction(self);
          end
        );
      end;
    end;
  end;
end;

end.
