:- use_module(displayList,
    [
	displayList/1,
	displayList/2,
	displayListToString/3
    ]).

:- use_module(onto,
			[classification/2,
			subsumedBy/2,
			strictSubsumedBy/2,
			is_instance_of/2,
			triple/3,
			data_concept/2]).

:- use_module(top_situation,
			[top_situation/1,
            situation_non_precisee/1,
            objetDeValeur/1,
            wumpus/1,
            monstre/1,
            danger/1,
            or/1]).
:- classification(top_situation,1).

:- use_module(top_emotion,
            [top_emotion/1,
            peur/1,
            envie/1,
            curiosite/1,
            desir/1,
            envie_et_devoir/1,
            agressivite/1]).
:- classification(top_emotion,1).

:- use_module(top_personnalite,
            [
            top_personnalite/1,
            personnalite_non_precisee/1,
            peureux/1,
            cupide/1
            ]).
:- classification(top_personnalite,1).


:- table 
    (
        situation/1,
        personnalite/1,
        action/1,
        eprouve_emotion/3,
        emotion_action/2,
        personnalite_emotion/2,
        active_personnalite/2,
        provoque/2
    )
    as (incremental,dynamic).

:- discontiguous
    action/1,
    eprouve_emotion/3,
    emotion_action/2,
    situation/1,
    personnalite/1,
    personnalite_emotion/2,
    active_personnalite/2,
    provoque/2.

:- dynamic (situation/1) as (incremental).
:- dynamic (personnalite/1) as (incremental).


% Règles d'inférence de prise de décision
action(A) :- 
    situation_personnalite(S,P),
    eprouve_emotion(P,S,E),
    emotion_action(E,A).

situation_personnalite(S,P):-
    (situation(S) *-> true ; S = situation_non_precisee), 
    (personnalite(P) *-> true ; P = personnalite_non_precisee).

% Règles définissant eprouve_emotion
eprouve_emotion(Perso,Sit,Emo) :-
    active_personnalite(Sit,Perso),
    personnalite_emotion(Perso,Emo).
eprouve_emotion(Perso,Sit,Emo) :- 
    personnalite(Perso),
    provoque(Sit,Emo).

% Règles de spécialisation/généralisation de eprouve_emotion
eprouve_emotion(SousPerso,Sit,Emo):-
    eprouve_emotion(Perso,Sit,Emo),
    strictSubsumedBy(SousPerso,Perso).
eprouve_emotion(Perso,SousSit,Emo):-
    eprouve_emotion(Perso,Sit,Emo),
    strictSubsumedBy(SousSit,Sit).
eprouve_emotion(Perso,Sit,SuperEmo):-
    eprouve_emotion(Perso,Sit,Emo),
    strictSubsumedBy(Emo,SuperEmo).
    
% Faits emotion_action
emotion_action(peur,fuir).
emotion_action(agressivite,combattre).
emotion_action(envie,ramasser).
emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain).
emotion_action(curiosite,continuer_exploration).

% Règles de spécialisation/généralisation de emotion_action
emotion_action(SousEmotion,Action):-
    emotion_action(Emotion,Action),
    strictSubsumedBy(SousEmotion,Emotion).

% Faits personnalite_emotion
personnalite_emotion(peureux,peur).
personnalite_emotion(cupide,desir).

% Règles de spécialisation/généralisation de personnalite_emotion
personnalite_emotion(SousPerso,Emo):-
    personnalite_emotion(Perso,Emo),
    strictSubsumedBy(SousPerso,Perso).
personnalite_emotion(Perso,SurEmo):-
    personnalite_emotion(Perso,Emo),
    strictSubsumedBy(Emo,SurEmo).

% Faits active_personnalite
active_personnalite(monstre,peureux).
active_personnalite(objetDeValeur,cupide).

% Règles de spécialisation/généralisation de active_personnalite
active_personnalite(SousSit,Perso):-
    active_personnalite(Sit,Perso),
    strictSubsumedBy(SousSit,Sit).

% Faits provoque(Situation,Emotion)
provoque(objetDeValeur,envie_et_devoir).
provoque(monstre,agressivite).
provoque(situation_non_precisee,curiosite).

% Règles de spécialisation/généralisation de provoque
provoque(SousSit,Emo):-
    provoque(Sit,Emo),
    strictSubsumedBy(SousSit,Sit).














res2 :- 
    % retractall(situation(_)),
    % retractall(personnalite(_)),
    Situation = [situation_non_precisee,wumpus,or],
    Personnalite = [personnalite_non_precisee,peureux,cupide],
    member(S,Situation),
    member(P,Personnalite),
    assertz(situation(S)),
    assertz(personnalite(P)),
    findall(A,action(A),LA),
    (LA=[]
    ->
        write([S]),write([P]),writeln("Pas d'action")
    ;
        write([S]),write([P]),writeln(LA)
    ),
    retract(situation(S)),
    retract(personnalite(P)),
    abolish_all_tables,
    false.


/*
2 ?- res2.
[situation_non_precisee][personnalite_non_precisee][continuer_exploration]
[situation_non_precisee][peureux][continuer_exploration]
[situation_non_precisee][cupide][continuer_exploration]
[wumpus][personnalite_non_precisee][combattre]
[wumpus][peureux][combattre,fuir]
[wumpus][cupide][combattre]
[or][personnalite_non_precisee][ramasser,ramasser_apres_nettoyage_souterrain]
[or][peureux][ramasser,ramasser_apres_nettoyage_souterrain]
[or][cupide][ramasser,ramasser_apres_nettoyage_souterrain]
false.

==> même résultat que précédemment

*/



% En plus de res2, affiche la liste et le nombre de tous les faits vrais
% dans le modèle en cour pour chaque cas.
res3 :- 
    Situation = [situation_non_precisee,wumpus,or],
    Personnalite = [personnalite_non_precisee,peureux,cupide],
    member(S,Situation),
    member(P,Personnalite),
    assertz(situation(S)),      %writeln(assertz(situation(S))),
    assertz(personnalite(P)),   %writeln(assertz(personnalite(P))),
    findall(A,action(A),LA),    %writeln(findall(A,action(A),LA)),
    (LA=[]
    ->
        write([S]),write([P]),writeln("Pas d'action")
    ;
        write([S]),write([P]),writeln(LA)
    ),

    groundAtoms(ListGroundAtoms),
    writeln("Liste des faits vrais dans le modele :"),
    displayList(ListGroundAtoms,"    "),
    length(ListGroundAtoms,NbTrueFacts),
    write("Nombre de faits vrais : "), writeln(NbTrueFacts),nl,

    retract(situation(S)),
    retract(personnalite(P)),
    abolish_all_tables,
    false.


% Renvoie la liste des faits vrais pour tous les prédicats 
% de l'exemple
groundAtoms(ListGroundAtoms) :-
    Preds = [situation/1, personnalite/1, situation_personnalite/2, action/1, eprouve_emotion/3, emotion_action/2, subsumedBy/2, personnalite_emotion/2, active_personnalite/2, provoque/2, 
    top_situation/1, situation_non_precisee/1, objetDeValeur/1, wumpus/1, monstre/1, danger/1, or/1,
    top_emotion/1, peur/1, envie/1, curiosite/1, desir/1, envie_et_devoir/1, agressivite/1,
    top_personnalite/1, personnalite_non_precisee/1, peureux/1, cupide/1],
    findall(Res,
        (member(Pred/Arity,Preds),
        length(Args, Arity),
        Atom =.. [Pred|Args],
        findall(Atom, Atom, Res)),
    ListListGroundAtoms),
    flatten(ListListGroundAtoms, ListGroundAtoms).





/*
3 ?- res3.
[situation_non_precisee][personnalite_non_precisee][continuer_exploration]
Liste des faits vrais dans le modele :
    situation(situation_non_precisee)
    personnalite(personnalite_non_precisee)
    situation_personnalite(situation_non_precisee,personnalite_non_precisee)
    action(continuer_exploration)
    eprouve_emotion(personnalite_non_precisee,wumpus,agressivite)
    eprouve_emotion(personnalite_non_precisee,wumpus,top_emotion)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,top_emotion)
    eprouve_emotion(personnalite_non_precisee,monstre,agressivite)
    eprouve_emotion(personnalite_non_precisee,monstre,top_emotion)
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,curiosite)
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,top_emotion)
    eprouve_emotion(personnalite_non_precisee,or,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,or,envie)
    eprouve_emotion(personnalite_non_precisee,or,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 86

[situation_non_precisee][peureux][continuer_exploration]
Liste des faits vrais dans le modele :
    situation(situation_non_precisee)
    personnalite(peureux)
    situation_personnalite(situation_non_precisee,peureux)
    action(continuer_exploration)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,agressivite)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,objetDeValeur,envie_et_devoir)
    eprouve_emotion(peureux,objetDeValeur,envie)
    eprouve_emotion(peureux,objetDeValeur,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,agressivite)
    eprouve_emotion(peureux,monstre,top_emotion)
    eprouve_emotion(peureux,situation_non_precisee,curiosite)
    eprouve_emotion(peureux,situation_non_precisee,top_emotion)
    eprouve_emotion(peureux,or,envie_et_devoir)
    eprouve_emotion(peureux,or,envie)
    eprouve_emotion(peureux,or,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 84

[situation_non_precisee][cupide][continuer_exploration]
Liste des faits vrais dans le modele :
    situation(situation_non_precisee)
    personnalite(cupide)
    situation_personnalite(situation_non_precisee,cupide)
    action(continuer_exploration)
    eprouve_emotion(cupide,wumpus,agressivite)
    eprouve_emotion(cupide,wumpus,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,envie_et_devoir)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,monstre,agressivite)
    eprouve_emotion(cupide,monstre,top_emotion)
    eprouve_emotion(cupide,situation_non_precisee,curiosite)
    eprouve_emotion(cupide,situation_non_precisee,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,envie_et_devoir)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 82

[wumpus][personnalite_non_precisee][combattre]
Liste des faits vrais dans le modele :
    situation(wumpus)
    personnalite(personnalite_non_precisee)
    situation_personnalite(wumpus,personnalite_non_precisee)
    action(combattre)
    eprouve_emotion(personnalite_non_precisee,wumpus,agressivite)
    eprouve_emotion(personnalite_non_precisee,wumpus,top_emotion)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,top_emotion)
    eprouve_emotion(personnalite_non_precisee,monstre,agressivite)
    eprouve_emotion(personnalite_non_precisee,monstre,top_emotion)
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,curiosite)       
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,top_emotion)     
    eprouve_emotion(personnalite_non_precisee,or,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,or,envie)
    eprouve_emotion(personnalite_non_precisee,or,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 86

[wumpus][peureux][combattre,fuir]
Liste des faits vrais dans le modele :
    situation(wumpus)
    personnalite(peureux)
    situation_personnalite(wumpus,peureux)
    action(combattre)
    action(fuir)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,agressivite)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,objetDeValeur,envie_et_devoir)
    eprouve_emotion(peureux,objetDeValeur,envie)
    eprouve_emotion(peureux,objetDeValeur,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,agressivite)
    eprouve_emotion(peureux,monstre,top_emotion)
    eprouve_emotion(peureux,situation_non_precisee,curiosite)
    eprouve_emotion(peureux,situation_non_precisee,top_emotion)
    eprouve_emotion(peureux,or,envie_et_devoir)
    eprouve_emotion(peureux,or,envie)
    eprouve_emotion(peureux,or,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 85

[wumpus][cupide][combattre]
Liste des faits vrais dans le modele :
    situation(wumpus)
    personnalite(cupide)
    situation_personnalite(wumpus,cupide)
    action(combattre)
    eprouve_emotion(cupide,wumpus,agressivite)
    eprouve_emotion(cupide,wumpus,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,envie_et_devoir)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,monstre,agressivite)
    eprouve_emotion(cupide,monstre,top_emotion)
    eprouve_emotion(cupide,situation_non_precisee,curiosite)
    eprouve_emotion(cupide,situation_non_precisee,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,envie_et_devoir)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 82

[or][personnalite_non_precisee][ramasser,ramasser_apres_nettoyage_souterrain]
Liste des faits vrais dans le modele :
    situation(or)
    personnalite(personnalite_non_precisee)
    situation_personnalite(or,personnalite_non_precisee)
    action(ramasser)
    action(ramasser_apres_nettoyage_souterrain)
    eprouve_emotion(personnalite_non_precisee,wumpus,agressivite)
    eprouve_emotion(personnalite_non_precisee,wumpus,top_emotion)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,envie)
    eprouve_emotion(personnalite_non_precisee,objetDeValeur,top_emotion)
    eprouve_emotion(personnalite_non_precisee,monstre,agressivite)
    eprouve_emotion(personnalite_non_precisee,monstre,top_emotion)
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,curiosite)       
    eprouve_emotion(personnalite_non_precisee,situation_non_precisee,top_emotion)     
    eprouve_emotion(personnalite_non_precisee,or,envie_et_devoir)
    eprouve_emotion(personnalite_non_precisee,or,envie)
    eprouve_emotion(personnalite_non_precisee,or,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 87

[or][peureux][ramasser,ramasser_apres_nettoyage_souterrain]
Liste des faits vrais dans le modele :
    situation(or)
    personnalite(peureux)
    situation_personnalite(or,peureux)
    action(ramasser)
    action(ramasser_apres_nettoyage_souterrain)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,agressivite)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,objetDeValeur,envie_et_devoir)
    eprouve_emotion(peureux,objetDeValeur,envie)
    eprouve_emotion(peureux,objetDeValeur,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,agressivite)
    eprouve_emotion(peureux,monstre,top_emotion)
    eprouve_emotion(peureux,situation_non_precisee,curiosite)
    eprouve_emotion(peureux,situation_non_precisee,top_emotion)
    eprouve_emotion(peureux,or,envie_et_devoir)
    eprouve_emotion(peureux,or,envie)
    eprouve_emotion(peureux,or,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 85

[or][cupide][ramasser,ramasser_apres_nettoyage_souterrain]
Liste des faits vrais dans le modele :
    situation(or)
    personnalite(cupide)
    situation_personnalite(or,cupide)
    action(ramasser)
    action(ramasser_apres_nettoyage_souterrain)
    eprouve_emotion(cupide,wumpus,agressivite)
    eprouve_emotion(cupide,wumpus,top_emotion)
    eprouve_emotion(cupide,objetDeValeur,desir)
    eprouve_emotion(cupide,objetDeValeur,envie)
    eprouve_emotion(cupide,objetDeValeur,envie_et_devoir)
    eprouve_emotion(cupide,objetDeValeur,top_emotion)
    eprouve_emotion(cupide,monstre,agressivite)
    eprouve_emotion(cupide,monstre,top_emotion)
    eprouve_emotion(cupide,situation_non_precisee,curiosite)
    eprouve_emotion(cupide,situation_non_precisee,top_emotion)
    eprouve_emotion(cupide,or,desir)
    eprouve_emotion(cupide,or,envie)
    eprouve_emotion(cupide,or,envie_et_devoir)
    eprouve_emotion(cupide,or,top_emotion)
    eprouve_emotion(peureux,wumpus,peur)
    eprouve_emotion(peureux,wumpus,top_emotion)
    eprouve_emotion(peureux,monstre,peur)
    eprouve_emotion(peureux,monstre,top_emotion)
    emotion_action(envie_et_devoir,ramasser)
    emotion_action(envie_et_devoir,ramasser_apres_nettoyage_souterrain)
    emotion_action(agressivite,combattre)
    emotion_action(curiosite,continuer_exploration)
    emotion_action(desir,ramasser)
    emotion_action(peur,fuir)
    emotion_action(envie,ramasser)
    subsumedBy(danger,top_situation)
    subsumedBy(wumpus,danger)
    subsumedBy(wumpus,wumpus)
    subsumedBy(monstre,danger)
    subsumedBy(wumpus,monstre)
    subsumedBy(monstre,monstre)
    subsumedBy(danger,danger)
    subsumedBy(situation_non_precisee,top_situation)
    subsumedBy(situation_non_precisee,situation_non_precisee)
    subsumedBy(objetDeValeur,top_situation)
    subsumedBy(or,objetDeValeur)
    subsumedBy(or,or)
    subsumedBy(objetDeValeur,objetDeValeur)
    subsumedBy(wumpus,top_situation)
    subsumedBy(monstre,top_situation)
    subsumedBy(or,top_situation)
    subsumedBy(top_situation,top_situation)
    subsumedBy(desir,top_emotion)
    subsumedBy(desir,desir)
    subsumedBy(envie_et_devoir,top_emotion)
    subsumedBy(envie_et_devoir,envie_et_devoir)
    subsumedBy(agressivite,top_emotion)
    subsumedBy(agressivite,agressivite)
    subsumedBy(peur,top_emotion)
    subsumedBy(peur,peur)
    subsumedBy(envie,top_emotion)
    subsumedBy(desir,envie)
    subsumedBy(envie_et_devoir,envie)
    subsumedBy(envie,envie)
    subsumedBy(curiosite,top_emotion)
    subsumedBy(curiosite,curiosite)
    subsumedBy(top_emotion,top_emotion)
    subsumedBy(cupide,top_personnalite)
    subsumedBy(cupide,cupide)
    subsumedBy(personnalite_non_precisee,top_personnalite)
    subsumedBy(personnalite_non_precisee,personnalite_non_precisee)
    subsumedBy(peureux,top_personnalite)
    subsumedBy(peureux,peureux)
    subsumedBy(top_personnalite,top_personnalite)
    personnalite_emotion(cupide,top_emotion)
    personnalite_emotion(cupide,envie)
    personnalite_emotion(cupide,desir)
    personnalite_emotion(peureux,peur)
    personnalite_emotion(peureux,top_emotion)
    active_personnalite(wumpus,peureux)
    active_personnalite(objetDeValeur,cupide)
    active_personnalite(or,cupide)
    active_personnalite(monstre,peureux)
    provoque(wumpus,agressivite)
    provoque(objetDeValeur,envie_et_devoir)
    provoque(monstre,agressivite)
    provoque(situation_non_precisee,curiosite)
    provoque(or,envie_et_devoir)
Nombre de faits vrais : 83

false.
*/