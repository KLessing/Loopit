{------------------------------------------------------------------------------
Zuständig für die Selektion der Steine auf der Bank. Ist bereits ein Stein
selektiert, werden weitere Selektionen bis zum ablegen oder deselektieren des
Steins gesperrt.

Autor: Kevin Lessing , 06.11.2017
------------------------------------------------------------------------------}
unit UTileSelection;

interface

uses UTypes;

  function getSelectionStatus: Boolean;
  function getSelectedTileIndex: TMoveTileIndex;
  procedure deactivateSelectionLock;
  procedure deselect(MoveTileIndex: TMoveTileIndex);
  function makeSelection(MoveTileIndex: TMoveTileIndex): Boolean;

implementation

var
  // Sperrung der Selektion, wenn bereits eine Selektion aktiv
  SelectionLocked: Boolean;
  // Index des zur Zeit selektierten Steins auf der Bank
  SelectedTileIndex: TMoveTileIndex;

{Gibt den Selektions Status zurück, also ob derzeit eine Selektion aktiv ist
RETURN: True, wenn Selektion aktiv}
function getSelectionStatus: Boolean;
begin
  getSelectionStatus:= SelectionLocked;
end;

{Gibt den Index des zur Zeit selektierten Steins auf der Bank zurück
RETURN: Index des Steins auf der Bank}
function getSelectedTileIndex: TMoveTileIndex;
begin
  getSelectedTileIndex:= SelectedTileIndex;
end;

{Deaktiviert die Selektionssperre}
procedure deactivateSelectionLock;
begin
  SelectionLocked:= false;
end;

{Selektiert ein Stein auf der Bank und sperrt weitere Selektionen
IN: MoveTileIndex - Bank Index des zu selektierenden Steins}
procedure select(MoveTileIndex: TMoveTileIndex);
begin
  SelectionLocked:= true;
  SelectedTileIndex:= MoveTileIndex;
end;

{Deselektiert einen Stein, falls dieser selektiert ist
IN: MoveTileIndex - Bank Index des zu deselektierenden Steins}
procedure deselect(MoveTileIndex: TMoveTileIndex);
begin
  if MoveTileIndex = SelectedTileIndex then
    SelectionLocked:= false;
end;

{Selektiert oder deselektiert den Stein auf der Bank.
Gibt zurück, ob selektiert oder deselektiert wurde.
IN: MoveTileIndex - Index des zu (de)selektierenden Steins auf der Bank
RETURN: True, wenn selektiert wurde
        False, wenn deselektiert wurde}
function makeSelection(MoveTileIndex: TMoveTileIndex): Boolean;
var
  selection: Boolean;
begin
  // Ist bereits ein Steil selektiert?
  if getSelectionStatus then
  begin
    // Selektierung aufheben
    deselect(MoveTileIndex);
    selection:= false;
  end
  else
  begin
    // Selektierung
    select(MoveTileIndex);
    Selection:= true;
  end;
  makeSelection:= selection;
end;

end.
