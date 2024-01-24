{


     0
    /|\
     |
    / /  	  
		  #         #		0
         ##     /|\##	   /|\		 #
          ##     |  ##		|	    ###
          #     /0\ #      / \     #####
############################################################
 	jump        crush      run
}

program littleprince;
uses
	crt;
type
	Location = record
		x: integer;
		y: integer;
	end;
	Size = record
		w: integer;
		h: integer;
	end;
	Skin = record
		size: Size; 
		run_bottom: array [1..4] of string;
		run_top: array [1..4] of string;
		jump_to_top: array [1..4] of string;
		jump_to_bottom: array [1..4] of string;
		crush_top: array [1..4] of string;
		crush_bottom: array [1..4] of string;
		stepchange_top: array [1..4] of string;
		stepchange_bottom: array [1..4] of string;
		stepchange: boolean;
		current: array [1..4] of string;
	end;
	State = record
		current: integer;
		prev: integer;
	end;
	Jump = record
		duration: integer;
		height: integer;
		counter: integer;
		flat: integer;
		flat_counter: integer;
		flat_d: integer;
		flat_top: boolean;
	end;
	HeroObject = record
		jump: Jump;
		location: Location;
		skin: Skin;
		state: State;
	end;
	EarthObject = record
		location: Location;
		block: char;
	end;
	Platform = ^EarthObject;
	Prince = ^HeroObject;

const
	_jumpHeight: integer = 10;
	_flyDuration: integer = 3;
	_delay: integer = 35;
	_heroStateRunTop: integer = 1;
	_heroStateRunBottom: integer = 2;
	_heroStateCrushTop: integer = 3;
	_heroStateCrushBottom: integer = 4;
	_heroStateJump: integer = 5;
	_heroHeight: integer = 4;
	_heroWidth: integer = 3;
    _heroSkinRunTop: array [1..4] of string = (' 0 ', '\|/', ' | ', '\ /');
	_heroSkinRunBottom: array [1..4] of string = ('/ \', ' | ', '/|\', ' 0 ');
	_heroSkinStepChangeTop: array [1..4] of string = (' 0 ', '\|/', ' | ', ' | ');
	_heroSkinStepChangeBottom: array [1..4] of string = (' | ', ' | ', '/|\', ' 0 ');
	_heroSkinJumpToTop: array [1..4] of string = ('/ /', ' | ', '/|\', ' 0 ');
	_heroSkinJumpToBottom: array [1..4] of string = (' 0 ', '\|/', ' | ', '\ \');
	_heroSkinCrushTop: array [1..4] of string = ('   ', '\|/', ' | ', '\ /');
	_heroSkinCrushBottom: array [1..4] of string = ('/ \', ' | ', '/|\', '   ');
	_earthBlock: char = '#';

procedure DrawEarth(var Earth: Platform); forward;
procedure DrawHero(var Hero: Prince); forward;


procedure Init(var Hero: Prince; var Earth: Platform);
begin
	clrscr;
	GotoXY(1, 1);
	new(Hero);
	Hero^.location.x := ScreenWidth - (ScreenWidth div 2) - 15;
	Hero^.location.y := ScreenHeight - 3 * (ScreenHeight div 10);
	Hero^.state.current := _heroStateRunBottom;
	Hero^.state.prev := 0;
	Hero^.jump.duration := _flyDuration;
	Hero^.jump.height := _jumpHeight;
	Hero^.jump.counter := 0;
	Hero^.jump.flat := 0;
	Hero^.jump.flat_top := false;
	Hero^.jump.flat_d := 0;
	Hero^.jump.flat_counter := 0;
	Hero^.skin.stepchange := false;
	Hero^.skin.size.w := _heroWidth;
	Hero^.skin.size.h := _heroHeight;
	Hero^.skin.current := _heroSkinRunBottom;
	Hero^.skin.run_top := _heroSkinRunTop;
	Hero^.skin.run_bottom := _heroSkinRunBottom;
	Hero^.skin.jump_to_top := _heroSkinJumpToTop;
	Hero^.skin.jump_to_bottom := _heroSkinJumpToBottom;
	Hero^.skin.crush_top := _heroSkinCrushTop;
	Hero^.skin.crush_bottom := _heroSkinCrushBottom;
	Hero^.skin.stepchange_top := _heroSkinStepChangeTop;
	Hero^.skin.stepchange_bottom := _heroSkinStepChangeBottom;
	new(Earth);
	Earth^.location.x := ScreenWidth;
	Earth^.location.y := ScreenHeight - 3 * (ScreenHeight div 10);
	Earth^.block := _earthBlock;
	DrawEarth(Earth);
	DrawHero(Hero);
end;

procedure Quit;
begin
	clrscr;
	GotoXY(1, 1);
end;


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

procedure ClearHero(var Hero: Prince);
var
	i: integer;
begin
	for i := 1 to Hero^.skin.size.h do
	begin
		GotoXY(Hero^.location.x, Hero^.location.y - i);
		Write('   ');
	end;
end;

procedure DrawHero(var Hero: prince);
var
	i: integer;
begin
	if Hero^.skin.stepchange and (Hero^.state.current <> _heroStateJump) then
	begin
		if Hero^.state.current = _heroStateRunTop then
			Hero^.skin.current := Hero^.skin.stepchange_top
		else
			Hero^.skin.current:= Hero^.skin.stepchange_bottom;
	end;
	for i := 1 to Hero^.skin.size.h do
	begin
		GotoXY(Hero^.location.x, Hero^.location.y - i);
		Write(Hero^.skin.current[i]);
	end;
end;

procedure DrawHeroJump(var Hero: Prince; d: integer);
begin
	if Hero^.jump.counter <= Hero^.jump.height then
	begin
		Hero^.location.y := Hero^.location.y - d;
		DrawHero(Hero);
		Hero^.jump.counter := Hero^.jump.counter + 1;
	end
	else
	if (Hero^.jump.counter >= Hero^.jump.Height + 1) and (Hero^.jump.counter <= (Hero^.jump.height + Hero^.jump.duration)) then
	begin
		DrawHero(Hero);
		Hero^.jump.counter := Hero^.jump.counter + 1;
	end
	else
	if (Hero^.jump.counter > (Hero^.jump.duration + Hero^.jump.height)) and (Hero^.jump.counter <= (Hero^.jump.duration + 2 * Hero^.jump.height)) then
	begin
		Hero^.location.y := Hero^.location.y + d;
		DrawHero(Hero);
		Hero^.jump.counter := Hero^.jump.counter + 1;
	end
	else
	if Hero^.jump.counter = (Hero^.jump.duration + 2 * Hero^.jump.height + 1) then
	begin
		Hero^.location.y := Hero^.location.y + d;
		DrawHero(Hero);
		Hero^.jump.counter := 0;
		Hero^.state.prev := Hero^.state.current;
		if d < 0 then
			Hero^.state.current := _heroStateRunTop
		else
			Hero^.state.current := _heroStateRunBottom;
	end;
end;


procedure DrawChangeFlat(var Hero: Prince; earthY: integer);
var
	top: boolean;
	i: integer;
begin
	if Hero^.jump.flat_counter = 0 then
	begin
		top := true;
		for i := 1 to 4 do
		begin 
			if Hero^.skin.current[i] <> Hero^.skin.jump_to_top[i] then
				top := false;
		end;
		if top then
		begin
			Hero^.jump.flat_d := -1;
			Hero^.jump.flat := Hero^.location.y - (ScreenHeight - earthY) - 1 - Hero^.skin.size.h;
		end
		else
		begin
			Hero^.jump.flat_d := 1;
			Hero^.jump.flat := earthY - Hero^.location.y;
		end;
		Hero^.jump.flat_counter := 1;
		Hero^.jump.flat_top := top;
	end
	else
	if Hero^.jump.flat_counter < Hero^.jump.flat then
	begin
		Hero^.location.y := Hero^.location.y + Hero^.jump.flat_d;
		DrawHero(Hero);
		Hero^.jump.flat_counter := Hero^.jump.flat_counter + 1;
	end
	else
	if Hero^.jump.flat_counter = Hero^.jump.flat then
	begin
		if Hero^.jump.flat_top then
		begin
			Hero^.skin.current := Hero^.skin.run_top;
			Hero^.state.prev := Hero^.state.current;
			Hero^.state.current := _heroStateRunTop;
		end
		else
		begin
			Hero^.skin.current := Hero^.skin.run_bottom;
			Hero^.state.prev := Hero^.state.current;
			Hero^.state.current := _heroStateRunBottom;
		end;
		Hero^.location.y := Hero^.location.y + Hero^.jump.flat_d;
		DrawHero(Hero);
		Hero^.jump.flat_counter := 0;
	end;
end;

procedure HeroStateManager(var Hero: prince; earthY: integer);
begin
	ClearHero(Hero);
	if (Hero^.state.current = _heroStateRunTop) or (Hero^.state.current = _heroStateRunBottom)  then
	begin
		if Hero^.state.current = _heroStateRunTop then
			Hero^.skin.current := Hero^.skin.run_top
		else
			Hero^.skin.current := Hero^.skin.run_bottom;
		DrawHero(Hero);
	end
	else if Hero^.state.current = _heroStateJump then
	begin
		if Hero^.state.prev = _heroStateRunBottom then
		begin
			Hero^.skin.current := Hero^.skin.jump_to_top;
			DrawHeroJump(Hero, 1);
		end
		else
		if Hero^.state.prev = _heroStateRunTop then
		begin
			Hero^.skin.current := Hero^.skin.jump_to_bottom;
			DrawHeroJump(Hero, -1);
		end
		else
		if Hero^.state.prev = _heroStateJump then
		begin
			Hero^.jump.counter := 0;
			DrawChangeFlat(Hero, earthY);
		end;
	end;
	Hero^.skin.stepchange := not Hero^.skin.stepchange;
	GotoXY(1, 1);
end;


procedure DrawEarth(var Earth: Platform);
var
	i: integer;
begin
	for i := 1 to Earth^.location.x do
	begin
		GotoXY(i, Earth^.location.y);
	  	write(Earth^.block);
		GotoXY(i, ScreenHeight - Earth^.location.y);
		write(Earth^.block);
	end;
	GotoXY(1, 1);
end;

var	
	Earth: Platform = nil;
	Hero: Prince = nil;
	earthX: integer;
	earthY: integer;
	EY: integer;
	i, pressedKeyId: integer;
begin
	earthX := ScreenWidth;
	earthY := ScreenHeight - 3 * (ScreenHeight div 10);
	Init(Hero, Earth);
	repeat
		if KeyPressed then
		begin
			GetPressedKeyId(pressedKeyId);
			case pressedKeyId of
				-72 or ord(' '):
				begin
					Hero^.state.prev := Hero^.state.current;
					Hero^.state.current := _heroStateJump;
				end;
			end;
		end;
		HeroStateManager(Hero, earthY);
		delay(_delay);
	until pressedKeyId = ord('q');
	Quit;
end.
