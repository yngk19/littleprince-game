program littleprince;
uses
	crt;
type
	location = record
		x: integer;
		y: integer;
	end;
	hero = array [1..4] of string;

const
	HeroMovementDelay = 100;
	HeroHeight = 4;
	HeroWidth = 3;

{ Get the user pressed key id  }
procedure GetPressedKeyId(var code: integer);
var
	symbol: char;
begin 
	symbol := ReadKey;
   	if symbol = #0 then
   	begin
		symbol := ReadKey;
	   	code := -ord(symbol);
	end
	else
	begin
		code := ord(symbol);
	end
end;

{ Draw the hero }
procedure DrawHero(var heroLocX, heroLocY: integer; run: boolean);
var	
	j, i: integer;
	Hero: array [1..4] of string = ('/ \', ' | ', '/|\', ' 0 ');
begin
	if run then
		Hero[1] := ' | ';
		run := false;
	for j := 1 to HeroHeight do
	begin
		GotoXY(heroLocX, heroLocY - j);
		write(Hero[j]);
	end;
	GotoXY(1, 1);
end;
{
 0
/|\
 |
/ /   #      0
     ##     /|\
      ##     |
      #     / \
####################

}

{ Draw the earth where the hero will run }
procedure DrawEarth;
var
	x, y, j: integer;
begin
	x := ScreenWidth;
	y := ScreenHeight - 3 * (ScreenHeight div 10); 
	for j := 1 to x do
	begin
		GotoXY(j, y);
	  	write('#')
	end;
	GotoXY(1, 1);
end;

var	
	run: boolean = true;
	heroLocation: location;
	i, heroLocX, heroLocY, pressedKeyId: integer;
begin
	heroLocation.x := ScreenWidth - (ScreenWidth div 2) - 10;
	heroLocation.y := ScreenHeight - 3 * (ScreenHeight div 10); 
	clrscr;
	{ Main cycle }
	repeat
		run := not run;
		if KeyPressed then
			GetPressedKeyId(pressedKeyId);
			{
			case pressedKeyId of
				ord(' ') or -72:
					GetPressedKeyId(pressedKeyId);
			}
		DrawEarth;
		DrawHero(heroLocation.x, heroLocation.y, run);
		delay(60);
	until pressedKeyId = ord('q');
	clrscr;
end.


