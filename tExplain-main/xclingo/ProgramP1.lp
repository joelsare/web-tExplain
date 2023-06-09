plength(1).
time(0..L) :- plength(L).
step(1..L) :- plength(L).

switch(s1). switch(s2).
component(relay). component(bulb).

fluent(relay).
fluent(light).
fluent(b_prot).
fluent(S) :- switch(S).
abfluent(ab(C)) :- component(C).
fluent(F) :- abfluent(F).

value(relay ,on). value(relay ,off).
value(light ,on). value(light ,off).
value(S,open) :- switch(S).
value(S,closed) :- switch(S).
hasvalue(F) :- value(F,V).
% Fluents are boolean by default
domain(F,true) :- fluent(F), not hasvalue(F).
domain(F,false) :- fluent(F), not hasvalue(F).
% otherwise, they take the specified values
domain(F,V) :- value(F,V).

agent(close(s1)).
exog(break).
exog(surge).
action(Y) :- exog(Y).
action(Y) :- agent(Y).

% Inertia
h(F,V,I) :- h(F,V,I-1), not c(F,I), step(I).

% Axioms
h(F,V,J) :- c(F,V,J).
c(F,J) :- c(F,V,J).

% Direct effects
c(s1,closed,I) :- o(close(s1),I), step(I).


% Executability
:- o(close(S),I), h(S, closed, I-1), step(I).

% Something happening actually occurs
o(A,I) :- obs_o(A,I), step(I).

% Check that observations hold
:- obs_h(F,V,J), not h(F,V,J).

% Completing the initial state
h(F,V,0) :- domain(F,V), not -h(F,V,0).
-h(F,V,0) :- h(F,W,0), domain(F,V), W!=V.


% A history
obs_h(s1,open,0).
obs_h(s2,open,0).
obs_h(b_prot ,true ,0).
obs_h(ab(bulb),false ,0).
obs_h(ab(relay),false ,0).
obs_o(close(s1),1).

% Something went wrong
obs_h(light ,off ,1).

% Diagnostic module: generate exogenous actions
o(Z,I) :- step(I), exog(Z), not no(Z,I).
no(Z,I) :- step(I), exog(Z), not o(Z,I).


%%%%%% Indirect effects
%!trace_rule {"The relay is working at %",J}
c(relay,on,J) :- h(s1,closed,J), h(ab(relay),false,J), time(J).

%!trace_rule {"The relay is not working at %",J}
    c(relay,off,J) :- h(s1,open,J), time(J).

%!trace_rule {"The relay is not working at %",J}
    c(relay,off,J) :- h(ab(relay),true,J), time(J).

 c(s2,closed,J) :- h(relay,on,J), time(J).

%!trace_rule {"The light is on at %",J}
    c(light,on,J) :- h(s2,closed,J), h(ab(bulb),false,J), time(J).

%!trace_rule {"The light is off at %",J}
    c(light,off,J):- h(s2,open,J), time(J).

%!trace_rule {"The light is off at %",J}
    c(light,off,J) :- h(ab(bulb),true ,J), time(J).

%%%%%% Malfunctioning
%!trace_rule {"The bulb has been damaged at %",I}
    c(ab(bulb),true ,I) :- o(break ,I), step(I).
    
%!trace_rule {"The relay has been damaged at %",I}
    c(ab(relay),true,I) :- o(surge,I), step(I).

%!trace_rule {"The bulb has been damaged at %",I}
    c(ab(bulb),true,I) :- o(surge,I), not h(b_prot,true,I-1), step(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!trace {"Hypothesis: there has been a power surge at %",J} o(surge,J).
%!trace {"Hypothesis: something has broken the bulb at %",J} o(break,J).
%!trace {"The agent has closed switch s1 at %",J} o(close(s1),J).

%!trace {"The % was initially damaged",C} h(ab(C), true, 0).
%!trace {"Initially, the % was not damaged",C} h(ab(C), false, 0).

%!trace {"% was initially %", F,V} h(F,V,0) : not abfluent(F).

%!show_trace h(light,V,1).
%!show_trace h(relay,V,1).