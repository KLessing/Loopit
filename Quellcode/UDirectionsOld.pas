unit UDirectionsOld;

interface

implementation

end.

{Directions as Record

interface

uses UDirectionTypes, UTypes, SysUtils;

  function getDirectionsFromTileName(TileName: TTileName): TDirections;

implementation


function initDirections(InitValue: Boolean): TDirections;
var
  resultDirections: TDirections;
begin
  with resultDirections do
  begin
    north := InitValue;
    east := InitValue;
    south := InitValue;
    west := InitValue;
  end;
  initDirections:= resultDirections;
end;

procedure setOneDirection(var Directions: TDirections; ChangeDirection: TDirection; value: Boolean);
begin
   case ChangeDirection of
    north: Directions.north:= value;
    east: Directions.east:= value;
    south: Directions.south:= value;
    west: Directions.west:= value;
  end;
end;

function getTwoWayDirections(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
  direction: TDirection;
  trueDirectionsCount: Byte;
begin
  // init directions as false
  resultDirections:= initDirections(false);
  trueDirectionsCount:= 0;
  direction := Low(TDirection);

  // search for two true Directions and set them directly
  repeat
    if StrToInt(TileName[1]) in TWO_WAYS[StrToInt(TileName[3]), direction] then
    begin
      setOneDirection(resultDirections, direction, true);
      inc(trueDirectionsCount);
    end;
    inc(direction);
  until trueDirectionsCount = 2;

  getTwoWayDirections:= resultDirections;
end;

function getThreeWayDirections(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
  direction: TDirection;
  falseDirectionFound: Boolean;
begin
  // init directions as true
  resultDirections:= initDirections(true);
  falseDirectionFound:= false;
  direction := Low(TDirection);

  // search for the false Direction
  repeat
    if StrToInt(TileName[1]) in THREE_WAYS[StrToInt(TileName[3]), direction] then
      falseDirectionFound:= true
    else
      inc(direction);
  until falseDirectionFound;

  // set the false direction to false
  setOneDirection(resultDirections, direction, false);

  getThreeWayDirections:= resultDirections;
end;


function getDirectionsFromTileName(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
begin
  case TileName[2] of
    '2': resultDirections:= getTwoWayDirections(TileName);
    '3': resultDirections:= getThreeWayDirections(TileName);
    '4': resultDirections:= initDirections(true);
  end;
  getDirectionsFromTileName:= resultDirections;
end;


end. }
