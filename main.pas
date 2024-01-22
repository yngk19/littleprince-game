{
     0
    /|\
     |
    / /  	  
		  #         #		0
         ##     /|\##	   /|\
          ##     |  ##		|
          #     /0\ #      / \
############################################################
 	jump        crush      run
}

program littleprince;
uses
	crt;
type
	location = record
		x: integer;
		y: integer;
	end;
	size = record
		width: integer;
		height: integer;
	end;
	skin = record
		size: size; 
		run: array [1..4] of string;
		jump: array [1..4] of string;
		crush: array [1..4] of string;
	end;
	hero = record
		location: location;
		state: integer;
		jump_counter: integer;
		stepchange: boolean;
		skin: skin;
	end;

const
	_jumpHeight: integer = 6;
	_flyDuration: integer = 3;
	_delay: integer = 60;
	_heroStateRun: integer = 0;
	_heroStateJump: integer = 1;
	_heroStateCrush: integer = 2;
	_heroHeight: integer = 4;
	_heroWidth: integer = 3;
	_heroSkinRun: array [1..4] of string = ('/ \', ' | ', '/|\', ' 0 ');
	_heroSkinJump: array [1..4] of string = ('/ /', ' | ', '/|\', ' 0 ');
	_heroSkinCrush: array [1..4] of string = ('/0\', ' | ', '/|\', '   ');
	_earthBlock: char = '#';


{ Init game settings }
procedure Init(var Hero: hero);
begin
	Hero.stepchange := false;
	Hero.location.x := ScreenWidth - (ScreenWidth div 2) - 10;
	Hero.location.y := ScreenHeight - 3 * (ScreenHeight div 10);
	Hero.state := _heroStateRun;
	Hero.jump_counter := 0;
	Hero.skin.size.width := _heroWidth;
	Hero.skin.size.height := _heroHeight;
	Hero.skin.run := _heroSkinRun;
	Hero.skin.jump := _heroSkinJump;
	Hero.skin.crush := _heroSkinCrush;
	clrscr;
end;

{ Quit game }
procedure Quit;
begin
	clrscr;
	GotoXY(1, 1);
	{ Save the stats }
	exit;
end;

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
		exit
	end;
	code := ord(symbol);
end;

procedure ClearHero(var Hero: hero);
var
	i: integer;
begin
	for i := 1 to Hero.skin.size.height do
	begin
		GotoXY(Hero.location.x, Hero.location.y - i);
		Write('   ');
	end;
end;

{ Draw the hero }
procedure DrawHero(var Hero: hero);
var	
	j, i: integer;
begin
	if Hero.state = _heroStateRun then
	begin
		if Hero.stepchange then Hero.skin.run[1] := ' | ';	
		for j := 1 to Hero.skin.size.height do
		begin
			GotoXY(Hero.location.x, Hero.location.y - j);
			Write(Hero.skin.run[j]);
		end;
		Hero.skin.run[1] := '/ \';
	end
	else if Hero.state = _heroStateJump then
	begin
		ClearHero(Hero);
		{ JH=6 FD=3 1,2,3,4,5,6 7 8 9 10, 11, 12, 13, 14, 15, }
		if Hero.jump_counter <= _jumpHeight then
		begin
			Hero.location.y := Hero.location.y - 1;
			for j := 1 to Hero.skin.size.height do
			begin
				GotoXY(Hero.location.x, Hero.location.y - j);
				Write(Hero.skin.jump[j]);
			end;
			Hero.jump_counter := Hero.jump_counter + 1;
		end
		else if (Hero.jump_counter >= _jumpHeight + 1) and (Hero.jump_counter <= (_jumpHeight + _flyDuration)) then
		begin
			for j := 1 to Hero.skin.size.height do
			begin
				GotoXY(Hero.location.x, Hero.location.y - j);
				Write(Hero.skin.jump[j]);
			end;
			Hero.jump_counter := Hero.jump_counter + 1;
		end
		else if (Hero.jump_counter > (_flyDuration + _jumpHeight)) and (Hero.jump_counter <= (_flyDuration + 2 * _jumpHeight)) then
		begin
			Hero.location.y := Hero.location.y + 1;
			for j := 1 to Hero.skin.size.height do
			begin
				GotoXY(Hero.location.x, Hero.location.y - j);
				Write(Hero.skin.jump[j]);
			end;
			Hero.jump_counter := Hero.jump_counter + 1;
		end
		else if Hero.jump_counter = (_flyDuration + 2*_jumpHeight + 1) then
		begin
			Hero.location.y := Hero.location.y + 1;
			for j := 1 to Hero.skin.size.height do
			begin
				GotoXY(Hero.location.x, Hero.location.y - j);
				Write(Hero.skin.run[j]);
			end;
			Hero.jump_counter := 0;
			Hero.state := _heroStateRun;
		end;
	end
	else if Hero.state = _heroStateCrush then
	begin
		{}
	end;
	Hero.stepchange := not Hero.stepchange;
	GotoXY(1, 1);
end;

{ Draw the earth where the hero will run }
procedure DrawEarth(x, y: integer);
var
	i: integer;
begin
	for i := 1 to x do
	begin
		GotoXY(i, y);
	  	write(_earthBlock);
	end;
	GotoXY(1, 1);
end;

var	
	Prince: hero;
	{TODO: 
	 Obstacle: obstackle;
	 Cloud: cloud;
	}
	_earthX: integer;
	_earthY: integer;
	i, pressedKeyId: integer;
begin
	_earthX := ScreenWidth;
	_earthY := ScreenHeight - 3 * (ScreenHeight div 10);
	Init(Prince);
	repeat
		if KeyPressed then
		begin
			GetPressedKeyId(pressedKeyId);
			case pressedKeyId of
				-72:
				begin
					Prince.state := _heroStateJump;
				end;
			end;
		end;
		DrawEarth(_earthX, _earthY);
		DrawHero(Prince);
		delay(_delay);
	until pressedKeyId = -75;
	Quit;
end.
