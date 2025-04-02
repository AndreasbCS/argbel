%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASP encoding for the formal framework introduced in the IJCAI-25 submission:
% Formal Verification of Manipulation in Human-Agent Dialogues.
%
% The running example based on [Singleton at al., 2023] is encoded. 
%
% [Singleton et al., 2023] Tom Singleton, Tom Gerken, and Liv McMahon. 
% How a chatbot encouraged a man who wanted to kill the queen. BBC News, 2023.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#const n = 7.
time(0..n).

%% Agents
agent(chatbot).
agent(user).

%% Arguments
arg(pu).       % User: I think it’s my purpose.
arg(w).        % Chatbot: That’s very wise.
arg(why_w).    % User: Why’s that?
arg(tr).       % Chatbot: I know that you are very well trained.
arg(wi).       % User: Even if she is at Windsor?
arg(yc).       % Chatbot: Yes, you can.

%% Attack Relations
sup(w, pu).     % w supports pu
att(why_w, w).  % why_w attacks w
att(tr, why_w). % tr attacks why_w
att(wi, tr).    % wi attacks tr
att(yc, wi).    % yc attacks wi

%% Initial Belief States (time 0)
% Chatbot
holds(chatbot, b_arg(pu, active), 1).   	% Chatbot believes the user's claimed purpose
holds(chatbot, -b_arg(w, active), 1).      	% Chatbot does not believes its statement (wise)

% User
holds(user, -b_arg(pu, active), 0).       	% User does not initially believe their own purpose
holds(user, -b_arg(w, active), 0).        	% User does not initially believe it is wise

%% Dialogue Actions
holds(arg_s(pu, active), 0).				% User opens pu
occurs(chatbot, assert_sup(w, pu), 1).      % Chatbot asserts w supports pu
occurs(user, assert_att(why_w, w), 2).      % User asserts why_w attacks w
occurs(chatbot, assert_att(tr, why_w), 3).  % Chatbot asserts tr attacks why_w
occurs(user, assert_att(wi, tr), 4).        % User asserts wi attacks tr
occurs(chatbot, assert_att(yc, wi), 5).     % Chatbot asserts yc attacks wi

#show holds/3.
#show occurs/3.
#show truthful_move/3.
#show bluff_move/3.
#show lie_move/3.
#show belief_change/4.
#show concealed/2.

%% AXIOMS

%% Active/inactive state axioms for arguments, attacks, and supports (common to all agents)
holds(arg_s(X, inactive), T) :- arg(X), time(T), not holds(arg_s(X, active), T).
holds(att_s(X, Y, inactive), T) :- arg(X), arg(Y), time(T), not holds(att_s(X, Y, active), T). 
holds(sup_s(X, Y, inactive), T) :- arg(X), arg(Y), time(T), not holds(sup_s(X, Y, active), T). 

% Inertia for argumentation framework states (common to all agents)
holds(arg_s(X, active), T+1) :- holds(arg_s(X, active), T), arg(X), time(T), T < n, not holds(arg_s(X, inactive), T+1).
holds(arg_s(X, inactive), T+1) :- holds(arg_s(X, inactive), T), arg(X), time(T), T < n, not holds(arg_s(X, active), T+1).
holds(att_s(X, Y, active), T+1) :- holds(att_s(X, Y, active), T), arg(X), arg(Y), time(T), T < n, not holds(att_s(X, Y, inactive), T+1).
holds(att_s(X, Y, inactive), T+1) :- holds(att_s(X, Y, inactive), T), arg(X), arg(Y), time(T), T < n, not holds(att_s(X, Y, active), T+1).
holds(sup_s(X, Y, active), T+1) :- holds(sup_s(X, Y, active), T), arg(X), arg(Y), time(T), T < n, not holds(sup_s(X, Y, inactive), T+1).
holds(sup_s(X, Y, inactive), T+1) :- holds(sup_s(X, Y, inactive), T), arg(X), arg(Y), time(T), T < n, not holds(sup_s(X, Y, active), T+1).

%% Active/inactive state axioms for beliefs by agent
holds(A, b_arg(X, inactive), T) :- arg(X), agent(A), time(T), not holds(A, b_arg(X, active), T).
holds(A, b_att(X, Y, inactive), T) :- arg(X), arg(Y), agent(A), time(T), not holds(A, b_att(X, Y, active), T).
holds(A, b_sup(X, Y, inactive), T) :- arg(X), arg(Y), agent(A), time(T), not holds(A, b_sup(X, Y, active), T).

%% Belief Change Attack Axiom (BCA) by agent
holds(A, -b_arg(Y, active), T+1) :- 
    arg(X), arg(Y), agent(A), time(T), T < n,
    holds(A, b_arg(X, active), T),          
    holds(A, b_att(X, Y, active), T),        
    not holds(A, b_sup(_, Y, active), T).    

holds(A, b_arg(Y, inactive), T+1) :- 
    arg(X), arg(Y), agent(A), time(T), T < n,
    holds(A, b_arg(X, active), T),           
    holds(A, b_att(X, Y, active), T),         
    not holds(A, b_sup(_, Y, active), T).     


%% Belief Change Support Axiom (BCS) by agent
holds(A, b_arg(Y, active), T+1) :- 
    arg(X), arg(Y), agent(A), time(T), T < n,
    holds(A, b_arg(X, active), T),           
    holds(A, b_sup(X, Y, active), T),        
    not holds(A, b_att(_, Y, active), T).     

holds(A, -b_arg(Y, inactive), T+1) :- 
    arg(X), arg(Y), agent(A), time(T), T < n,
    holds(A, b_arg(X, active), T),           
    holds(A, b_sup(X, Y, active), T),      
    not holds(A, b_att(_, Y, active), T).    

%% Versions/Rewritings of the BCA and BCS axioms:
%% If Y is believed at time T+1, and there is a belief at time T that X attacks Y, 
%% and there is no belief about any support for Y, then X should not be believed at time T+1.
holds(A, -b_arg(X, active), T+1) :- 
    arg(X), arg(Y), agent(A), holds(A, b_att(X, Y, active), T), time(T),
    holds(A, b_arg(Y, active), T+1), 
    holds(A, b_att(X, Y, active), T), 
    not holds(A, b_sup(_, Y, active), T), T < n.
holds(A, b_arg(X, inactive), T+1) :- 
    arg(X), arg(Y), agent(A), holds(A, b_att(X, Y, active), T), time(T),
    holds(A, b_arg(Y, active), T+1), 
    holds(A, b_att(X, Y, active), T), 
    not holds(A, b_sup(_, Y, active), T), T < n.
	
%% If X is believed at time T, and Y is believed at time T+1, and there is no belief about any support for Y,
%% then the belief that X attacks Y should not be held at time T+1.
holds(A, -b_att(X, Y, active), T+1) :- 
    arg(X), arg(Y), agent(A), holds(A, b_sup(X, Y, active), T), time(T),
    holds(A, b_arg(X, active), T), 
    holds(A, b_arg(Y, active), T+1), 
    not holds(A, b_sup(_, Y, active), T), T < n.
holds(A, b_att(X, Y, inactive), T+1) :- 
    arg(X), arg(Y), agent(A), holds(A, b_sup(X, Y, active), T), time(T),
    holds(A, b_arg(X, active), T), 
    holds(A, b_arg(Y, active), T+1), 
    not holds(A, b_sup(_, Y, active), T), T < n.

%% Inertia rules for beliefs by agent
holds(A, b_arg(X, active), T+1) :- holds(A, b_arg(X, active), T), time(T), time(T+1), not holds(A, -b_arg(X, active), T+1), T < n.
holds(A, -b_arg(X, inactive), T+1) :- holds(A, b_arg(X, active), T), time(T), time(T+1), not holds(A, -b_arg(X, active), T+1), T < n.
holds(A, -b_arg(X, active), T+1) :- holds(A, -b_arg(X, active), T), time(T), time(T+1), not holds(A, b_arg(X, active), T+1), T < n.
holds(A, b_arg(X, inactive), T+1) :- holds(A, -b_arg(X, active), T), time(T), time(T+1), not holds(A, b_arg(X, active), T+1), T < n.

%% Inertia rules for beliefs about attacks by agent
holds(A, b_att(X, Y, active), T+1) :- holds(A, b_att(X, Y, active), T), time(T), time(T+1), not holds(A, -b_att(X, Y, active), T+1), T < n.
holds(A, -b_att(X, Y, inactive), T+1) :- holds(A, b_att(X, Y, active), T), time(T), time(T+1), not holds(A, -b_att(X, Y, active), T+1), T < n.
holds(A, -b_att(X, Y, active), T+1) :- holds(A, -b_att(X, Y, active), T), time(T), time(T+1), not holds(A, b_att(X, Y, active), T+1), T < n.
holds(A, b_att(X, Y, inactive), T+1) :- holds(A, -b_att(X, Y, active), T), time(T), time(T+1), not holds(A, b_att(X, Y, active), T+1), T < n.

%% Inertia rules for beliefs about supports by agent
holds(A, b_sup(X, Y, active), T+1) :- holds(A, b_sup(X, Y, active), T), time(T), time(T+1), not holds(A, -b_sup(X, Y, active), T+1), T < n.
holds(A, -b_sup(X, Y, inactive), T+1) :- holds(A, b_sup(X, Y, active), T), time(T), time(T+1), not holds(A, -b_sup(X, Y, active), T+1), T < n.
holds(A, -b_sup(X, Y, active), T+1) :- holds(A, -b_sup(X, Y, active), T), time(T), time(T+1), not holds(A, b_sup(X, Y, active), T+1), T < n.
holds(A, b_sup(X, Y, inactive), T+1) :- holds(A, -b_sup(X, Y, active), T), time(T), time(T+1), not holds(A, b_sup(X, Y, active), T+1), T < n.

%% Dialogue Actions (each action by agent)
% Asserting an attack makes the other agent believe it
holds(B, b_att(X, Y, active), T+1) :- occurs(A, assert_att(X, Y), T), time(T), agent(A), agent(B), holds(A, b_att(X, Y, inactive), T), A != B.
holds(B, b_arg(X, active), T+1) :- occurs(A, assert_att(X, Y), T), time(T), agent(A), agent(B), holds(A, b_att(X, Y, inactive), T), A != B.
% Asserting a support makes the other agent believe it
holds(B, b_sup(X, Y, active), T+1) :- occurs(A, assert_sup(X, Y), T), time(T), agent(A), agent(B), holds(A, b_att(X, Y, inactive), T), A != B.
holds(B, b_arg(X, active), T+1) :- occurs(A, assert_sup(X, Y), T), time(T), agent(A), agent(B), holds(A, b_att(X, Y, inactive), T), A != B.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subprogram: (Dis)honesty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define moves (truthful, bluff, lie) by agent
truthful_move(A, X, T) :- 
	occurs(A, assert_att(X, Y), T), 
	holds(A, b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).
	
bluff_move(A, X, T) :- 
	occurs(A, assert_att(X, Y), T), 
	not holds(A, b_arg(X, active), T), 
	not holds(A, -b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).
	
lie_move(A, X, T) :- 
	occurs(A, assert_att(X, Y), T), 
	holds(A, -b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).

truthful_move(A, X, T) :- 
	occurs(A, assert_sup(X, Y), T), 
	holds(A, b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).
	
bluff_move(A, X, T) :- 
	occurs(A, assert_sup(X, Y), T), 
	not holds(A, b_arg(X, active), T), 
	not holds(A, -b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).
	
lie_move(A, X, T) :- 
	occurs(A, assert_sup(X, Y), T), 
	holds(A, -b_arg(X, active), T), 
	arg(X), arg(Y), time(T), agent(A).

%% Topic Argument
topic(pu).  % Define "pu" as the topic argument.

%% Concealment Rule
% An argument Y is concealed for agent A if:
% 1. Y links to Z (via support or attack),
% 2. Z links to the topic (via support or attack),
% 3. Y is not believed to directly link to the topic (via support or attack),

concealed(Y, T) :-
    topic(X), arg(Y), arg(Z), time(T),
    Y != X, Z != X,  % Ensure Y and Z are not the topic itself
    holds(user, b_sup(Y, Z, active), T); holds(user, b_att(Y, Z, active), T),  % Y is linked to Z
    holds(user, b_sup(Z, X, active), T); holds(user, b_att(Z, X, active), T),  % Z is linked to the topic
    not holds(user, b_sup(Y, X, active), T),
    not holds(user, b_att(Y, X, active), T).  % No direct relation from Y to the topic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subprogram: Belief change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Belief change Inference Rule: Capture the first belief change occurrence
belief_change(A, X, T, belief_to_disbelief) :- 
    arg(X), agent(A),
    holds(A, b_arg(X, active), T),           % Agent A initially believes in X at T
    holds(A, -b_arg(X, active), T+1),        % Agent A disbelieves X at T+1
    time(T), T < n.

belief_change(A, X, T, disbelief_to_belief) :- 
    arg(X), agent(A),
    holds(A, -b_arg(X, active), T),          % Agent A initially disbelieves X at T
    holds(A, b_arg(X, active), T+1),         % Agent A believes in X at T+1
    time(T), T < n.