unit UPlayerTypes;

interface

uses UTypes;

type

  // Typ der Spieler (Entweder von Mensch oder KI gesteuert)
  TPlayerType = (ptHuman, ptAI);

  // Zusammgerechnete Punkt der Spieler f�r das aktuelle Spiel
  TPoints = word;

  // Datensatz eines Spielers f�r Typ, Name und Punkte des Spielers
  TPlayer = record
    playerType: TPlayerType;
    name: TPlayerName;
    points: TPoints;
  end;

  // Dynamisches Array f�r die Spieler
  TPlayers = array of TPlayer;

implementation

end.
