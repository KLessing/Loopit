unit UPlayerTypes;

interface

uses UTypes;

type

  // Typ der Spieler (Entweder von Mensch oder KI gesteuert)
  TPlayerType = (ptHuman, ptAI);

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

implementation

end.
