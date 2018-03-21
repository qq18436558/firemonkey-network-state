unit UNetworkState;

interface

uses
  System.SysUtils, System.Classes;

type
  TNetworkStateValue = (nsConnectedWifi = 1, nsConnectedMobileData = 2, nsDisconnected = 3);

  TNetworkStateChangeEvent = procedure (Sender: TObject;
    Value: TNetworkStateValue) of object;

  TNetworkState = class (TComponent)
  private
    FCurrentValue: TNetworkStateValue;
    FOnChange: TNetworkStateChangeEvent;
  protected
    procedure DoOnChange;
    function GetCurrentValue: TNetworkStateValue; virtual; abstract;

    constructor Create(AOwner: TComponent;
      AOnChange: TNetworkStateChangeEvent); reintroduce; virtual;
  public
    class function Factory(
      AOwner: TComponent; AOnChange: TNetworkStateChangeEvent
    ): TNetworkState;

    property CurrentValue: TNetworkStateValue read FCurrentValue;
  end;

implementation

uses
  {$IF DEFINED(Android)}
    UNetworkState.Android;
  {$ELSEIF DEFINED(iOS)}
    UNetworkState.iOS;
  {$IFEND}

{ TNetworkState }

constructor TNetworkState.Create(AOwner: TComponent;
  AOnChange: TNetworkStateChangeEvent);
begin
  inherited Create(AOwner);
  self.FOnChange := AOnChange;

  self.FCurrentValue := self.GetCurrentValue;
end;

class function TNetworkState.Factory(AOwner: TComponent;
  AOnChange: TNetworkStateChangeEvent): TNetworkState;
begin
  {$IF DEFINED(Android)}
    Result := TAndroidNetworkState.Create(AOwner, AOnChange);
  {$ELSEIF DEFINED(iOS)}
    Result := TiOSNetworkState.Create(AOwner, AOnChange);
  {$IFEND}
end;

procedure TNetworkState.DoOnChange;
var
  NewValue: TNetworkStateValue;
begin
  NewValue := self.GetCurrentValue;

  if (self.FCurrentValue <> NewValue) then begin
    self.FCurrentValue := NewValue;

    if Assigned(self.FOnChange) then
      self.FOnChange(self, self.FCurrentValue);
  end;
end;

end.
