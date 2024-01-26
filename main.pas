program littleprince;
uses math, crt, sysutils;

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
	CounterObject = record
		current: QWord;
		rec: QWord;
		location: Location;
	end;
	HeroObject = record
		jump: Jump;
		location: Location;
		skin: Skin;
		state: State;
		prickles_delay: integer;
		debug: boolean;
	end;
	EarthObject = record
		location: Location;
		block: char;
	end;
	CounterPtr = ^CounterObject;
	PricklesData = record
		location: Location;
		skin: string;
		height: integer;
		draw_delay: QWord;
		top: boolean;
	end;
	PricklesPtr = ^PricklesObject;
	PricklesObject = record
		data: PricklesData;
		next, prev: PricklesPtr;
	end;
	Platform = ^EarthObject;
	Prince = ^HeroObject;
	Prickles = record
		first, last: PricklesPtr;
	end;
		

const
	_easy = 100;
	_medium = 50;
	_hard = 30;
	_delayPrickles = 120;
	_jumpHeight: integer = 10;
	_flyDuration: integer = 6;
	_delay: integer = 20;
	_pricklesSkin: string = '<#>';
	_heroStateRunTop: integer = 1;
	_heroStateRunBottom: integer = 2;
	_heroStateCrushTop: integer = 3;
	_heroStateCrushBottom: integer = 4;
	_heroStateJump: integer = 5;
	_heroHeight: integer = 4;
	_heroWidth: integer = 3;
    _heroSkinRunTop: array [1..4] of string = (' 0 ', '\|/', ' | ', '\ )');
	_heroSkinRunBottom: array [1..4] of string = ('/ )', ' | ', '/|\', ' 0 ');
	_heroSkinStepChangeTop: array [1..4] of string = (' 0 ', '\|/', ' | ', ' | ');
	_heroSkinStepChangeBottom: array [1..4] of string = (' | ', ' | ', '/|\', ' 0 ');
	_heroSkinJumpToTop: array [1..4] of string = ('/ /	', ' | ', '/|\', ' 0 ');
	_heroSkinJumpToBottom: array [1..4] of string = (' 0 ', '\|/', ' | ', '\ \');
	_heroSkinCrushTop: array [1..4] of string = (' 0 ', '\|/', ' | ', '\ /');
	_heroSkinCrushBottom: array [1..4] of string = ('/ \', ' | ', '/|\', ' 0 ');
	_earthBlock: char = '#';

procedure DrawEarth(var Earth: Platform); forward;
procedure DrawHero(var Hero: Prince); forward;

procedure DrawCounter(var Counter: CounterPtr);
var
	i, j, d, p: integer;
begin
	d := Length(IntToStr(Counter^.current)) - 1;
	GotoXY(Counter^.location.x - 12, Counter^.location.y);
	Write('Current Score');
	GotoXY(Counter^.location.x - d, Counter^.location.y + 1);
	Write(Counter^.current);
	if Counter^.rec <> 0 then
	begin
		p := Length(IntToStr(Counter^.rec)) - 1;
		GotoXY(Counter^.location.x - 9, Counter^.location.y + 2);
		Write('Best Score');
		GotoXY(Counter^.location.x - p, Counter^.location.y + 3);
		Write(Counter^.rec);
	end;
end;

procedure Init(var Hero: Prince; var Earth: Platform; var Prickle: Prickles);
begin
	clrscr;
	GotoXY(1, 1);
	new(Hero);
	Hero^.debug := false;
	Hero^.location.x := ScreenWidth - (ScreenWidth div 2) - 15;
	Hero^.location.y := ScreenHeight - 3 * (ScreenHeight div 10);
	Hero^.state.current := _heroStateRunBottom;
	Hero^.state.prev := 0;
	Hero^.prickles_delay := _delayPrickles;
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
	Prickle.first := nil;
	Prickle.last := nil;
	GotoXY(ScreenWidth - 50, ScreenHeight - Earth^.location.y - 9);
	Write('0');
	GotoXY(30, ScreenHeight - Earth^.location.y - 9);
	Write('Jump -> SPACE');
	GotoXY(30, ScreenHeight - Earth^.location.y - 6);
	Write('Double jump -> SPACE + SPACE');
	GotoXY(30, ScreenHeight - Earth^.location.y - 3);
	Write('Quit game -> ESC');
	GotoXY(1, 1);
end;

procedure ClearPrickles(var Prickle: PricklesPtr);
var
	i: integer;
begin
	for i := 0 to Prickle^.data.height - 1 do
	begin
		GotoXY(Prickle^.data.location.x, Prickle^.data.location.y - i );
		Write('   ');
	end;
end;

procedure DrawPrickles(var Prickle: PricklesPtr);
var
	i: integer;
begin
	for i := 0 to Prickle^.data.height - 1 do
	begin
		GotoXY(Prickle^.data.location.x, Prickle^.data.location.y - i );
		Write(Prickle^.data.skin);
	end;
end;

procedure DestroyPrickles(var Prickle: Prickles);
var
	tmp: PricklesPtr;
begin
	if Prickle.first^.next = nil then
	begin
		dispose(Prickle.first);
		Prickle.first := nil;
		Prickle.last := Prickle.first;
	end
	else
	begin
		tmp := Prickle.first^.next;
		tmp^.prev := nil;
		dispose(Prickle.first);
		Prickle.first := tmp;
	end;
end;

procedure CreatePrickles(var Prickle: Prickles; var Earth: Platform);
var
	tmp: PricklesPtr;
begin
	if Prickle.first = nil then
	begin
		new(Prickle.first);
		Prickle.first^.next := nil;
		Prickle.first^.prev := nil;
		Prickle.first^.data.height := RandomRange(5, Earth^.location.y - (ScreenHeight - Earth^.location.y) - _heroHeight - 1);
		Prickle.first^.data.location.x := ScreenWidth;
		Prickle.first^.data.draw_delay := 0;
		Prickle.first^.data.top := Random > 0.5;
		if Prickle.first^.data.top then
			Prickle.first^.data.location.y := ScreenHeight - Earth^.location.y + Prickle.first^.data.height
		else
			Prickle.first^.data.location.y := Earth^.location.y - 1;
		Prickle.first^.data.skin := _pricklesSkin;
	   	Prickle.last := Prickle.first;
	end
	else
	begin
		new(tmp);
		tmp^.data.location.x := ScreenWidth;
		tmp^.data.height := RandomRange(5, Earth^.location.y - (ScreenHeight - Earth^.location.y) - _heroHeight - 1);
		tmp^.data.top := Random > 0.5;
		if tmp^.data.top then
			tmp^.data.location.y := ScreenHeight - Earth^.location.y + tmp^.data.height
		else
			tmp^.data.location.y := Earth^.location.y - 1;
		tmp^.data.skin := _pricklesSkin;
		tmp^.data.draw_delay := Prickle.last^.data.draw_delay + _hard;
		tmp^.next := nil;
		tmp^.prev := Prickle.last;
		Prickle.last^.next := tmp;
		Prickle.last := tmp;
	end;
end;

procedure PricklesManager(var Prickle: Prickles; var Earth: Platform; var Hero: Prince);
var
	tmp: PricklesPtr;
	crush: boolean;
begin
	if Hero^.prickles_delay <> 0 then
	begin
		Hero^.prickles_delay := Hero^.prickles_delay - 1;
		Exit;
	end;
	tmp := Prickle.first;
	while tmp <> nil do
	begin
		if tmp^.data.draw_delay > 0 then
			tmp^.data.draw_delay := tmp^.data.draw_delay - 1
		else
		begin
			if tmp^.data.location.x <= 5 then
			begin
				ClearPrickles(tmp);
				DestroyPrickles(Prickle);
			end
			else
			begin
				ClearPrickles(tmp);
				tmp^.data.location.x := tmp^.data.location.x - 1;
				if (tmp^.data.location.x >= Hero^.location.x) and (tmp^.data.location.x <= Hero^.location.x + 2) then
				begin
					if tmp^.data.top then
					begin
						if tmp^.data.location.y >= (Hero^.location.y - 4) then
							crush := true;
					end
					else
					begin
						if (tmp^.data.location.y - tmp^.data.height) < Hero^.location.y then
							crush := true;
					end;	
				end;
				if crush then
				begin
					Hero^.state.current := _heroStateCrushBottom;
					DrawPrickles(tmp);
					exit;
				end;
				DrawPrickles(tmp);
			end;
		end;
		tmp := tmp^.next;
	end;
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
	if Hero^.debug then
		exit;
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
var
	key: integer;
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
	end
	else 
	if (Hero^.state.current = _heroStateCrushTop) or (Hero^.state.current = _heroStateCrushBottom) then
	begin
		if Hero^.state.current = _heroStateCrushTop then
		begin
			Hero^.skin.current := _heroSkinCrushTop;
			DrawHero(Hero);
		end
		else
		begin
			Hero^.skin.current := _heroSkinCrushBottom;
			DrawHero(Hero);	
			exit;
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
	Counter: CounterPtr = nil;
	Hero: Prince = nil;
	Prickle: Prickles;
	earthX: integer;
	earthY: integer;
	EY: integer;
	i, pressedKeyId: integer;
begin
	Randomize;
	earthX := ScreenWidth;
	earthY := ScreenHeight - 3 * (ScreenHeight div 10);
	Init(Hero, Earth, Prickle);
	new(Counter);
	Counter^.location.x := ScreenWidth - 50;
	Counter^.location.y := ScreenHeight - Earth^.location.y - 9;
	Counter^.current := 0;
	Counter^.rec := 0;
	while True do
	begin
		GetPressedKeyId(pressedKeyId);
		case pressedKeyId of
			32:
				break;
			27:
				break;
		end;
	end;
	repeat
		if KeyPressed then
		begin
			GetPressedKeyId(pressedKeyId);
			case pressedKeyId of
				32:
				begin
					Hero^.state.prev := Hero^.state.current;
					Hero^.state.current := _heroStateJump;
				end;
			end;
		end;
		if Random < 0.15 then
			CreatePrickles(Prickle, Earth);
		PricklesManager(Prickle, Earth, Hero);
		HeroStateManager(Hero, earthY);
		if (Hero^.state.current = _heroStateCrushTop) or (Hero^.state.current = _heroStateCrushBottom) then
		begin
			while True do
			begin
				GetPressedKeyId(pressedKeyId);
				if pressedKeyId = 27 then 
				begin
					break;
				end
				else
				if pressedKeyId = 32 then
				begin
					Init(Hero, Earth, Prickle);
					Counter^.rec := Counter^.current;
					Counter^.current := 0;	
					break;
				end;
			end;		
		end;
		DrawCounter(Counter);
		Counter^.current := Counter^.current + 1;
		delay(_delay);
	until pressedKeyId = 27;
	Quit;
end.
