{------------------------------------------------------------------------------
Enthält alle Typen, die meist von mehr als einer Unit verwendet werden.

Autor: Kevin Lessing , 23.09.2017
------------------------------------------------------------------------------}
unit UTypes;

interface

const
  // Anzahl der unterschiedlichen Steine
  TILE_COUNT = 81;
  // Anzahl der Steine des aktuellen Zuges (Steine auf der Bank)
  MOVE_TILE_COUNT = 5;
  // Anzahl der maximalen Ablagen pro Zug
  MAX_MOVE_COUNT = 3;

  // Anzahl der Reihen des Spielfeldes
  ROW_COUNT = 11;
  // Anzahl der Spalten des Spielfeldes
  COL_COUNT = 11;

  // Maximal zulässige Spieleranzahl
  MAX_PLAYER_COUNT = 4;
  // Maximal zulässige Menge an Zeichen eines Spielernamens
  MAX_PLAYERNAME_LENGTH = 12;
  // Maximale KI Verzögerung der INI Datei
  MAX_AI_DELAY = 9999;

  // Breite vom Rand der Bilder
  IMG_BORDER_WIDTH = 3;

type
  { --- GameField --- }

  // Zeilen des Spielfeldes
  TRow = 0..ROW_COUNT-1;
  // Spalten des Spielfeldes
  TCol = 0 .. COL_COUNT-1;


  { --- Player --- }

  // Index der Spieler
  TPlayerIndex = 0..MAX_PLAYER_COUNT-1;
  // Bereich für die Anzahl der Spieler
  TPlayerCountRange = 0..MAX_PLAYER_COUNT;

  // Typ der Spieler (Entweder von Mensch oder KI gesteuert)
  TPlayerType = (ptHuman, ptAI);
  // Name eines Spielers
  TPlayerName = string[MAX_PLAYERNAME_LENGTH];
  // Zusammgerechnete Punkt der Spieler für das aktuelle Spiel
  TPoints = word;

  // Datensatz eines Spielers für Typ, Name und Punkte des Spielers
  TPlayer = record
    playerType: TPlayerType;
    name: TPlayerName;
    points: TPoints;
  end;

  // Dynamisches Array für die Spieler
  TPlayers = array of TPlayer;

  // Array das lediglich die Namen der Spieler für die Default Werte enthält
  TPlayerNames = array [TPlayerIndex] of TPlayerName;


  { --- Direction --- }

  // Aufzählungstyp für die vier Himmelsrichtungen
  TDirection = (dirNorth, dirEeast, dirSouth, dirWest);

  // Menge für Himmelsrichtungen
  // (stellt entweder offene oder geschlossene Wege der Steine da)
  TDirections = set of TDirection;


  { --- Tile --- }

  // Ein Stein Name besteht aus 3 Nummern
  TTileName = String[3];

  // Ein einzelner Stein kann 1-8 Punkte Wert sein (0 entspricht leeren Stein)
  TTilePoints = 0..8;

  // Index für 81 enzigartige Steine (0 entspricht leeren Stein)
  TTileIndex = 0..TILE_COUNT;

  // Sack mit allen verfügbaren Steinen des aktuellen Spiels
  TTileIndexSack = set of 1..TILE_COUNT;

  // Datensatz eines Steins für Index, Name, Offene Wege und Punkte des Steins
  TTile = record
    index: TTileIndex;
    name: TTileName;
    directions: TDirections;
    points: TTilePoints;
  end;


  { --- Move --- }

  // Anzahl der Ablagen des aktuellen Zuges
  TMoveCount= 0..MAX_MOVE_COUNT;

  // Index der Steine auf der Bank
  TMoveTileIndex = 0..MOVE_TILE_COUNT-1;

  // Aktuelle Steine auf der Bank
  TMoveTiles = array[TMoveTileIndex] of TTile;

  // Datensatz für die Details einer Stein Ablage, wie BankIndex des Steins,
  // Punkte und Position der Ablage
  TMoveDetail = record
    moveTileIndex: TMoveTileIndex;
    points: Word;
    row: TRow;
    col: TCol;
  end;

  // Dynamisches Array für die Details zu den Ablagen eines Zuges
  TMoveDetails = array of TMoveDetail;

  // Index der Details für einen Zug
  TMoveDetailIndex = 0..MAX_MOVE_COUNT-1;


implementation

end.
