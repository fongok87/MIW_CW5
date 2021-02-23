/* dynamic - podczas działania predykanty mogą się zmienić */
:- dynamic at/2, i_am_at/1, alive/1, player/3,  enemy/4.

i_am_at('Polska').
    
/* OPIS PRZEJŚĆ - termy złożone */
/* KOALICJA WSCHODNIA */
route('Polska', e, 'East').
route('East', w, 'Polska').
route('East', e, 'Bialorus').
route('Bialorus', w, 'East').
route('East', n, 'Litwa').
route('Litwa', s, 'East').
route('East', s, 'Ukraina').
route('Ukraina', n, 'East').

/* KOALICJA ZACHODNIA */
route('Polska', w, 'West').
route('West', e, 'Polska').
route('West', w, 'Anglia').
route('Anglia', e, 'West').
route('West', n, 'Niemcy').
route('Niemcy', s, 'West').
route('West', s, 'Francja').
route('Francja', n, 'West').

/* KOALICJA POŁUDNIOWA */
route('Polska', s, 'South').
route('South', n, 'Polska').
route('South', w, 'Czechy').
route('Czechy', e, 'South').
route('South', e, 'Slowacja').
route('Slowacja', w, 'South').
route('South', s, 'Wegry').
route('Wegry', n, 'South').

/* MORZE */
route('Poland', n, 'Sea').
route('Sea', s, 'Poland').

/* INICJALIZACJA PRZECIWNIKÓW */
alive(player).
alive('Litwa').
alive('Bialorus').
alive('Ukraina').
alive('Wegry').
alive('Czechy').
alive('Slowacja').
alive('Niemcy').
alive('Anglia').
alive('Francja').

/* Tworzenie listy aktywnych graczy */
gamers['Litwa','Bialorus','Ukraina','Wegry','Czechy','Slowacja','Niemcy','Anglia','Francja'].


/* Odcięcie */
/* PORUSZANIE SIĘ */
n :- go(n), !.
s :- go(s), !.
e :- go(e), !.
w :- go(w), !.

track(A, B, C) :- write(A), write(' --> '), write(B), write(' --> '), write(C).

/* Rekurencja oraz unifikacja. do klauzuli track zostają przypisane wartości */
go(Direction) :-
        i_am_at(Here),
        route(Here, Direction, There),
    	track(A, B, C) = track(Here, Direction, There), 
    	track(A, B, C),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        look.


go(_) :-
        write('Nie mozesz isc dalej.'),
    	nl.


look :-
        i_am_at(Place),
		nl,
        describe(Place),
        nl, !.

/* INICJALIZACJA GRACZY - termy proste */
/* PRZECIWNICY */
player(1000, 2000, 1000).
enemy('Niemcy',2000, 3000, 4000).
enemy('Francja',3000, 3000, 5000).
enemy('Anglia',5000, 6000, 6000).
enemy('Litwa', 500, 200, 1500).
enemy('Ukraina',500, 600, 1500).
enemy('Bialorus', 600, 700, 1500).
enemy('Czechy',1000, 1000, 1800).
enemy('Slowacja',1000, 1500, 1500).
enemy('Wegry',1500, 1500, 1800).


/* WALKA, PLĄDROWANIE, SZKOLENIE ARMII, ZWIĘKSZENIE SIŁY ATAKU */
isAlive(X):- X > 0.
isDead(X) :- X =< 0.
isPlund(X) :- X =< 0.

playerStats:-
        player(X, Y, Z),
        write('Twoje wojsko: '), write(X), nl, write('Sila ataku: '), write(Y), nl, write('Twoje zasoby: '), write(Z), nl.

enemyStats:-
    	i_am_at(Enemy),
        enemy(Enemy, X, Y, Z), 
    	write(Enemy), nl, write(' Wojsko: '), write(X), nl, write('Sila ataku: '), write(Y), nl, write('Zasoby: '), write(Z), nl, !.

enemyStats:-
        write('Nie ma tu zadnego wroga'), !.

attack(X, Y, Z) :- Z is  X - Y.
plund(X, Y, Z) :- Z is X + Y.

increaseArmy(J, K, L) :- L is J + K.
increaseAP(J, K, L) :- L is J + K.
diff(J, K, L) :- L is J - K.


/* KLAUZULE - proceduralnie */
battle:-
		i_am_at(Enemy),
        enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
		isDead(EnemyArmy),
		retract(alive(Enemy)),
		write('Gracz '), write(Enemy), write(' zostal już pokonany'), nl, !.

/* ELEMENTY DYNAMICZNE - dodawanie i usuwanie termów */
battle:-
    	i_am_at(Enemy),
		enemy(Enemy, EnemyArmy, EnemyAttackPower, EnemyResources),
    	isAlive(EnemyArmy),
    	player(PlayerArmy, PlayerAttackPower, PlayerResources),
    
		attack(PlayerArmy, EnemyAttackPower, NewPlayerArmy),
		attack(EnemyArmy, PlayerAttackPower, NewEnemyArmy),
    
    	retract(player(PlayerArmy, PlayerAttackPower, PlayerResources)),
        assert(player(NewPlayerArmy, PlayerAttackPower, PlayerResources)),

		retract(enemy(Enemy, EnemyArmy, EnemyAttackPower, EnemyResources)),
    
    	(isDead(NewPlayerArmy) -> write('Przegrales'), nl,
        assert(enemy(Enemy, NewEnemyArmy, EnemyAttackPower, EnemyResources)) ,die; 
        isAlive(NewPlayerArmy) , write('Wygrales'),
        assert(enemy(Enemy, 0, 0, EnemyResources)),nl),!.


battle:-
        write('Nie masz z kim walczyć tutaj.'),
        nl, !.


plunder:-
		i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
		write(Enemy), write(' zostal już spladrowany'), nl, !.

plunder:-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, EnemyAttackPower, EnemyResources),
    	isDead(EnemyArmy),
   
    	player(PlayerArmy, PlayerAttackPower, PlayerResources),
    
    	plund(PlayerResources, EnemyResources, NewPlayerResources),
    	
    	retract(player(PlayerArmy, PlayerAttackPower, PlayerResources)),
        assert(player(PlayerArmy, PlayerAttackPower, NewPlayerResources)),
 
		retract(enemy(Enemy, EnemyArmy, EnemyAttackPower, EnemyResources)), 
		assert(enemy(Enemy, EnemyArmy, EnemyAttackPower, 0)),
    
    	write('Gracz '), write(Enemy), write(' zostal spladrowany'), nl, !.

plunder:-
    	i_am_at(Enemy),
		enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy),
        write('Gracz nie zostal jeszcze pokonany.'),
        nl, !.


train(X):-
    	player(PlayerArmy, PlayerAttackPower, PlayerResources),
    	(X > (PlayerResources) ->  write('Nie masz tyle zasobow'), nl; X =< (PlayerResources),
        write('Szkolisz nowych zolnierzy.'), nl,
        retract(player(PlayerArmy, PlayerAttackPower, PlayerResources)),
        increaseArmy(PlayerArmy, X, NewPlayerArmy),
        diff(PlayerResources, X, NewPlayerResources),
        assert(player(NewPlayerArmy, PlayerAttackPower, NewPlayerResources))).

increaseAttack(X):-
    	player(PlayerArmy, PlayerAttackPower, PlayerResources),
    	(X > (PlayerResources) ->  write('Nie masz tyle zasobow'), nl; X =< (PlayerResources),
    	write('Zwiekszasz sile ataku.'), nl,
    	retract(player(PlayerArmy, PlayerAttackPower, PlayerResources)),
    	increaseAP(PlayerAttackPower, X, NewPlayerAttackPower),
        diff(PlayerResources, X, NewPlayerResources),
    	assert(player(PlayerArmy, NewPlayerAttackPower, NewPlayerResources))).


/* OPIS I INSTRUKCJE */
start :-
    	situation,
    	look,
    	instructions.

situation :-
    nl,
    	write('Jest rok 2055. Swiat ogarnela wojna. Kraje walcza o ostatnie zasoby. Znajdujesz sie w centrum Europy by poprowadzic Polske ku zwycięstwu.'),
 	nl.

instructions :-
    nl,
        write('Aby grac uzywaj komend.'), nl,
    	write('Rozpocznij gre.............start.'), nl, 
    	write('Idz w danym kierunku.......e. w. n. s.'), nl,
    	write('Zaatakuj przeciwnika.......battle.'), nl,
    	write('Pladruj gracza.............plunder.'), nl,
    	write('Szkol zolnierzy............train(X).'), nl,
    	write('Zwieksz sile ataku.........increaseAttack(X)'), nl,
    	write('Sprawdz sasiedztwo.........look.'), nl,
    	write('Twoje statystyki...........playerStats.'), nl,
    	write('Statystyki przeciwnika.....enemyStats.'), nl,
    	write('Pokaz instrukcje...........instructions.'), nl,
    	write('Zakoncz gre................halt.'), nl,
    nl.

die :-
        finish.

finish :-
        nl,
        write('Koniec gry. Aby zakonczyc wpisz halt..'),
        nl.


/* OPIS SĄSIADÓW ORAZ AKCJI ZWIĄZANYCH */
describe(actions) :-
    	write('Atakuj(battle)'), nl, 
        write('Pladruj(plunder)').

describe('Polska') :-
        write('Jestes w Polsce, od wschodu(e) masz granice z Panstwami koalicji wschodniej'), nl,
    	write('Jestes w Polsce, od zachodu(w) masz granice z Panstwami koalicji zachodniej'), nl,
    	write('Jestes w Polsce, od poludnia(s) masz granice z Panstwami koalicji poludniowej'),
		nl.

describe('East') :-
    	write('Jestes na wschodnich obrzezach, przed Toba teren Panstw koalicji wschodniej'), nl,
    	write('Od wschodu(e) znajduje sie Bialorus, od poludnia(s) Ukraina, od polnocy(n) Litwa'),
    	nl.

describe('Bialorus') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Bialorusi, Panstwa koalicji wschodniej'), nl,
    	describe(actions),
    	nl.

describe('Bialorus') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Bialorusi, Panstwa koalicji wschodniej'),
    	nl.

describe('Bialorus') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jestes na terenie podbitej Bialorusi, Panstwa koalicji wschodniej, mozesz spladrować tego gracza'),
    	nl.


describe('Litwa') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Litwy, Panstwa koalicji wschodniej'), nl,
    	describe(actions),
    	nl.

describe('Litwa') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Litwy, Panstwa koalicji wschodniej'),
    	nl.

describe('Litwa') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jestes na terenie podbitej Litwy, Panstwa koalicji wschodniej, mozesz spladrować tego gracza'),
    	nl.

describe('Ukraina') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Ukrainy, Panstwa koalicji wschodniej'), nl,
    	describe(actions),
    	nl.

describe('Ukraina') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Ukrainy, Panstwa koalicji wschodniej'),
    	nl.

describe('Ukraina') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jesteś na terenie podbitej Ukrainy, Panstwa koalicji wschodniej, mozesz spladrować tego gracza'),
    	nl.
                                                                  
describe('West') :-
    	write('Jestes na zachodnich obrzezach, przed Toba teren Panstw koalicji zachodniej'), nl,
    	write('Od zachodu(w) znajduje sie Anglia, od połnocy Niemcy(n), od poludnia(s) Francja'),
    	nl.
                                                                                      
describe('Anglia') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Anglii, Panstwa koalicji zachodniej'), nl,
    	describe(actions),
    	nl.

describe('Anglia') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Anglii, Panstwa koalicji zachodniej'),
    	nl.

describe('Anglia') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jesteś na terenie podbitej Anglii, Panstwa koalicji zachodniej, mozesz spladrować tego gracza'),
    	nl.
	
describe('Niemcy') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Niemiec, Panstwa koalicji zachodniej'), nl,
    	describe(actions),
    	nl.

describe('Niemcy') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitych i spladrowanych Niemiec, Panstwa koalicji zachodniej'),
    	nl.

describe('Niemcy') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jesteś na terenie podbitych Niemiec, Panstwa koalicji zachodniej, mozesz spladrować tego gracza'),
    	nl.
                
describe('Francja') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Francji, Panstwa koalicji zachodniej'), nl,
    	describe(actions),
    	nl.

describe('Francja') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Francji, Panstwa koalicji zachodniej'),
    	nl.

describe('Francja') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jestes na terenie podbitej Francji, Panstwa koalicji zachodniej, mozesz spladrować tego gracza'),
    	nl.

describe('South') :-
    	write('Jestes na poludniowych obrzezach, przed Toba teren Panstw koalicji poludniowej'), nl,
    	write('Od zachodu(w) znajduja sie Czechy, od wschodu(e) Slowacja, od poludnia(s) Wegry'),
    	nl.
                                                                                      
describe('Czechy') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Czech, Panstwa koalicji poludniowej'), nl,
    	describe(actions),
    	nl.

describe('Czechy') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitych i spladrowanych Czech, Panstwa koalicji poludniowej'),
    	nl.

describe('Czechy') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jestes na terenie podbitych Czech, Panstwa koalicji poludniowej, mozesz spladrować tego gracza'),
    	nl.
	
describe('Slowacja') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Slowacji, Panstwa koalicji poludniowej'), nl,
    	describe(actions),
    	nl.

describe('Slowacja') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitej i spladrowanej Slowacji, Panstwa koalicji poludniowej'),
    	nl.

describe('Slowacja') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jesteś na terenie podbitej Slowacji, Panstwa koalicji poludniowej, mozesz spladrować tego gracza'),
    	nl.
                
describe('Wegry') :-
    	i_am_at(Enemy),
    	enemy(Enemy, EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	isAlive(EnemyArmy), 
    	write('Jestes na terenie Wegier, Panstwa koalicji poludniowej'), nl,
    	describe(actions),
    	nl.

describe('Wegry') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, EnemyResources),
		isPlund(EnemyResources),
    	write('Jestes na terenie podbitych i spladrowanych Wegier, Panstwa koalicji poludniowej'),
    	nl.

describe('Wegry') :-
    	i_am_at(Enemy),
        enemy(Enemy, _EnemyArmy, _EnemyAttackPower, _EnemyResources),
    	write('Jesteś na terenie podbitych Wegier, Panstwa koalicji poludniowej, mozesz spladrować tego gracza'),
    	nl.

describe('Sea') :-
    	write('Tu jest luzik, tylko morze, od południa(s) jest Polska'),
    	nl.
