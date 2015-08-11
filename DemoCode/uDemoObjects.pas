unit uDemoObjects;

interface

uses
  FMX.Types, System.UITypes, System.Classes, System.Types, System.SysUtils, System.Math,
  System.Generics.Collections,
  uEngine2DSprite, uEngine2DText, uEngine2DAnimation, uEngine2DStandardAnimations, uEngine2DClasses,
  uEngine2DObject, uIntersectorClasses;

type
  TShipFire = class(TSprite)
  private
    FTip: Byte;
  public
    property Tip: Byte read FTip write FTip; // ��� ����
    procedure Repaint; override;
    constructor Create(AParent: pointer); override;
  end;

  TShipLight = class(TSprite)
  public
    procedure Repaint; override;
  end;

  TMovingUnit = class(TSprite)
  protected
    FDx, FDy, FDA: Double; // ������
  public
    property DX: Double read FDx write FDx;
    property DY: Double read FDy write FDy;
    property DA: Double read FDa write FDa;
  end;

  TShip = class(TMovingUnit)
  private
    FParts: TList<TSprite>;// array[0..5] of TSprite;
    FLeftFire: TShipFire;
    FRightFire: TShipFire;
    FLeftFireCenter: TShipFire;
    FRightFireCenter: TShipFire;
    FShipLight: TShipLight;
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  public
{    property LeftFire: TShipFire read FLeftFire write FLeftFire;
    property RightFire: TShipFire read FRightFire write FRightFire;
    property LeftFireCenter: TShipFire read FRightFireCenter write FRightFireCenter;
    property RightFireCenter: TShipFire read FRightFireCenter write FRightFireCenter; }
    property Parts: TList<TSprite> read FParts;
    procedure SetOpacity(const AOpacity: Integer);
    procedure Repaint; override;
    constructor Create(AParent: pointer); override;
    destructor Destroy; override;
  end;

  TAsteroid = class(TMovingUnit)
  private
    FNotChange: Integer; // ���-�� �����, ������� �� ����� ���������� ����������� ��� ���������
  public
    procedure Repaint; override;
    procedure Collide(const AObject: TEngine2DObject);
    constructor Create(AParent: pointer); override;
  end;

  TLittleAsteroid = class(TMovingUnit)
  private
    FTip: Byte;
  public
    property Tip: Byte read FTip write FTip; // ��� ���������
    procedure Repaint; override;
    constructor Create(AParent: pointer); override;
  end;

  TExplosion = class(TSprite)
  end;

  TStar = class(TSprite)
  public
    procedure Repaint; override;
  end;

implementation

uses
  mainUnit,
  uEngine2D, uDemoGameLoader;

{ TShip }

constructor TShip.Create(AParent: pointer);
var
  vEngine: TEngine2D;
begin
  inherited;

  vEngine := AParent;

  FLeftFire := TShipFire.Create(AParent);
  FLeftFire.Parent := AParent;
  FLeftFire.Group := 'ship';
  FLeftFire.Resources := vEngine.Resources;
  FLeftFire.ScaleX := Self.ScaleX;
  FLeftFire.ScaleY := Self.ScaleY;
  FLeftFire.Opacity := 0.5;
  vEngine.AddObject(FLeftFire);

  FRightFire := TShipFire.Create(AParent);
  FRightFire.Parent := AParent;
  FRightFire.Resources := vEngine.Resources;
  FRightFire.Group := 'ship';
  FRightFire.ScaleX := -Self.ScaleX;
  FRightFire.ScaleY := Self.ScaleY;
  FRightFire.Opacity := 0.5;
  vEngine.AddObject(FRightFire);

  FLeftFireCenter := TShipFire.Create(AParent);
  FLeftFireCenter.Parent := AParent;
  FLeftFireCenter.Resources := vEngine.Resources;
  FLeftFireCenter.Group := 'ship';
  FLeftFireCenter.ScaleX := Self.ScaleX;
  FLeftFireCenter.ScaleY := Self.ScaleY;
  FLeftFireCenter.Opacity := 0.5;
  vEngine.AddObject(FLeftFireCenter);

  FRightFireCenter := TShipFire.Create(AParent);
  FRightFireCenter.Parent := AParent;
  FRightFireCenter.Resources := vEngine.Resources;
  FRightFireCenter.ScaleX := -Self.ScaleX;
  FRightFireCenter.Group := 'ship';
  FRightFireCenter.ScaleY := Self.ScaleY;
  FRightFireCenter.Opacity := 0.5;
  vEngine.AddObject(FRightFireCenter);

  FShipLight := TShipLight.Create(AParent);
  FShipLight.Resources := vEngine.Resources;
  FShipLight.Group := 'ship';
  FShipLight.ScaleX := Self.ScaleX;
  FShipLight.ScaleY := Self.ScaleY;
  vEngine.AddObject(FShipLight);

  Self.OnMouseDown := Self.MouseDown;

  FParts := TList<TSprite>.Create;
  FParts.Add(Self);
  FParts.Add(FLeftFire);
  FParts.Add(FRightFire);
  FParts.Add(FLeftFireCenter);
  FParts.Add(FRightFireCenter);
  FParts.Add(FShipLight);
end;

destructor TShip.Destroy;
var
  i: Integer;
begin
  // ������� ������ ��� ��� �������
  for i := 1 to FParts.Count - 1 do
    FParts[i].Free;

  FParts.Free;

  inherited;
end;

procedure TShip.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  vEngine: TEngine2D;
  vPos: TPosition;
  vFi, vEX, vEY, vDist: Double; // ����������
  vAni: TAnimation;
begin
  vEngine := Parent;

  vEX := Self.x - X;
  vEY := Self.y - y;

  vDist := Sqrt(Sqr(vEX) + Sqr(vEY));
  vFi := ArcTan2(-vEY, -vEX);
  if vDist > 25 then
    vPos.Rotate := (Self.Rotate + ((vFi / Pi) * 180+270)) / 2
  else
    vPos.rotate := Self.Rotate;
  vPos.x := self.x + vEX * vDist * 0.05;// Self.x + Abs(vEX) * vDist * 0.1 * Self.ScaleX * Sin(vPos.rotate / 180 * pi);
  vPos.y := self.y + vEY * vDist * 0.05;//Self.y + Abs(vEY) * vDist * 0.1 * Self.ScaleY * Cos(vPos.rotate / 180 * pi);

  vPos.ScaleX := Self.ScaleX;
  vPos.ScaleY := Self.ScaleY;
  Self.Opacity := 1;

 // self.Rotate := 270;


  mainForm.caption := FloatToStr(vEX) + '~~' + FloatToStr(vEY) + '~~' + FloatToStr(vPos.Rotate);

  vAni := TLoader.ShipFlyAnimation(Self, vPos);
  vAni.Parent := vEngine;
  vEngine.AnimationList.Add(vAni);

end;

procedure TShip.Repaint;
begin
  curRes := 0;

  inherited;

  Self.Rotate := Self.Rotate + (random - 0.5) * 0.5;
  Self.X := Self.x + (random - 0.5) * 0.5;
  Self.Y := Self.y + (random - 0.5) * 0.5;

  FLeftFire.Rotate := Self.Rotate;
  FLeftFire.ScalePoint := Self.ScalePoint * 2;
  FLeftFire.x := Self.x + (scW*0.15 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.6 - 0) * sin((Self.Rotate / 180) * pi);
  FLeftFire.y :=  Self.y + (scW*0.15 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.6 - 0) * cos((Self.Rotate / 180) * pi);

  FRightFire.Rotate := Self.Rotate;
  FRightFire.ScalePoint := Self.ScalePoint * PointF(-2, 2);
  FRightFire.x := Self.x + (-scW*0.15 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.6 - 0) * sin((Self.Rotate / 180) * pi);
  FRightFire.y :=  Self.y + (-scW*0.15 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.6 - 0) * cos((Self.Rotate / 180) * pi);

  FLeftFireCenter.Rotate := Self.Rotate;
  FLeftFireCenter.ScalePoint := Self.ScalePoint * 2;
  FLeftFireCenter.x := Self.x + (scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.75 - 0) * sin((Self.Rotate / 180) * pi);
  FLeftFireCenter.y :=  Self.y + (scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.75 - 0) * cos((Self.Rotate / 180) * pi);

  FRightFireCenter.Rotate := Self.Rotate;
  FRightFireCenter.ScalePoint := Self.ScalePoint * PointF(-2, 2);
  FRightFireCenter.x := Self.x + (-scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH*0.75 - 0) * sin((Self.Rotate / 180) * pi);
  FRightFireCenter.y :=  Self.y + (-scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH*0.75 - 0) * cos((Self.Rotate / 180) * pi);

  FShipLight.ScalePoint := Self.ScalePoint;
  FShipLight.Rotate := Self.Rotate;
  FShipLight.x := Self.x + (-scW*0.0 - 0) * cos((Self.Rotate / 180) * pi) - (scH * 0.4) * sin((Self.Rotate / 180) * pi);
  FShipLight.y :=  Self.y + (-scW*0.0 - 0) * sin((Self.Rotate / 180) * pi) + (scH * 0.4) * cos((Self.Rotate / 180) * pi);
  FShipLight.SendToFront;
 end;

procedure TShip.SetOpacity(const AOpacity: Integer);
var
  i: Integer;
begin
  Self.Opacity := AOpacity;
  for i := 0 to FParts.Count - 1 do
    FParts[i].Opacity := AOpacity;
end;

{ TAsteroid }

procedure TAsteroid.Collide(const AObject: TEngine2DObject);
var
  vArcTan, vArcTan2: Extended;
  vDX: Single;
  vLoader: TLoader;
  vAng: Double;
  vAni: TAnimation;
  vExp: TExplosion;
begin
  if FNotChange > 0 then
  begin
    FNotChange := 1;
    Exit;
  end;

  vArcTan := ArcTan2(AObject.y - Self.y, AObject.x - Self.x);
  vArcTan2 := ArcTan2(-FDy, FDx) + vArcTan;

  vDX := FDx;
  FDX := Cos(vArcTan2) * (FDX) - Sin(vArcTan2) * (FDY);
  FDY := Sin(vArcTan2) * (vDX) + Cos(vArcTan2) * (FDY);
  FDx := - FDx;
  FDy := - FDy;
  AObject.x := AObject.x - FDx * Game.Speed * 2;
  AObject.y := AObject.y - FDy * Game.Speed * 2;

  vLoader := TLoader.Create(FParent);
  vAng := vArcTan / pi180;

  vExp := vLoader.Explosion(
    Self.x + (Self.Shape.MaxRadius * 1) * Cos(vArcTan),
    Self.y + (Self.Shape.MaxRadius * 1) * Sin(vArcTan),
    vAng);

  vAni := vLoader.ExplosionAnimation(vExp);

  AObject.Rotate := AObject.Rotate + (vArcTan / pi180) * 0.02;
  FNotChange := 10;

  vAni.Parent := fParent;
  tEngine2d(fParent).AnimationList.Add(vAni);
end;

constructor TAsteroid.Create(AParent: pointer);
begin
  inherited;
  FDx := 5 * Random;
  FDy := 5 * Random;
  FDA := 20 * Random - 10;
  FNotChange := 0;
end;

procedure TAsteroid.Repaint;
begin
  curRes := 1;

  inherited;

  Self.x := Self.x + FDx * Game.Speed;
  Self.y := Self.y + FDy * Game.Speed;
  Self.Rotate := Self.Rotate + FDa * Game.Speed;

  if Self.Rotate >= 360 then
    Self.Rotate := 0;

  if Self.x >= tEngine2d(Parent).Width + Self.scW then
    Self.x := -Self.scW
  else
    if Self.x < 0 - Self.scW then
      Self.x := tEngine2d(Parent).Width;

  if Self.y >= tEngine2d(Parent).Height + Self.scH then
    Self.y := -Self.scH
  else
    if Self.y < 0 - Self.scH then
     Self.y := tEngine2d(Parent).Height;

  if FNotChange > 0 then
    Dec(FNotChange);
end;

{ TLittleAsteroid }

constructor TLittleAsteroid.Create(AParent: pointer);
begin
  inherited;
  FTip := Random(6);
  if FTip > 3 then
    FTip := 3; // ����� ����� �������� ����

  FDX := Random * 6;
  FDY := Random * 6 ;
  FDA := 30 * Random - 15;
end;

procedure TLittleAsteroid.Repaint;
begin
  curRes := FTip + 5;
  inherited;

  Self.Rotate := Self.Rotate + FDa * Game.Speed;

  if Self.Rotate >= 360 then
    Self.Rotate := 0;

  Self.x := Self.x + FDx * Game.Speed;
  Self.y := Self.y + FDy * Game.Speed;

  if Self.x > tEngine2d(Parent).Width then
    Self.x := -1;

  if Self.y > tEngine2d(Parent).Height then
    Self.y := -1;
end;

{ TStar }

procedure TStar.Repaint;
begin
  inherited;

end;

{ TShipFire }

constructor TShipFire.Create(AParent: pointer);
begin
  inherited;
  FTip := Random(3);
end;

procedure TShipFire.Repaint;
begin
  inherited;
  FTip := Random(3);
  curRes := FTip + 2;
end;

{ TShipLight }

procedure TShipLight.Repaint;
begin
  if Opacity > 0.1 then
    Opacity := 0.8 + Random * 0.2;
  CurRes := 13 + Random(2);
  inherited;
end;

end.

