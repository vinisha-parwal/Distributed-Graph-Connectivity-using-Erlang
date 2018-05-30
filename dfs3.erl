-module (dfs3).
-export ([dfs/6, dfs_root/6,start/0]).

start() ->
	io:format("~w",[self()]),

	receive 

		{initiate, Node, Neighbours, TotalNodes} ->
			Children = sets:new(),
			ParentSet = sets:new(),
			% io:fwrite("In start ~n"),
			dfs_root(Node, Neighbours, Children, TotalNodes, ParentSet, -1)

	end.

dfs_root(Node, Neighbours, Children, TotalNodes, Parent, ParentValue) ->
	
	case Node == 0 of
		true->
			% ParentValue = self(),
			% io:fwrite("In root ~n"),

			ParentSet = sets:add_element(pid_to_list(self()),Parent),				
			lists:foreach(
				fun(N) -> 
					%Pid = spawn(n, ?MODULE, dfs, []),
					Pid = list_to_pid(N),
					io:format("~p~n",[Pid]),
					Pid ! {que, self()}
				end,
			     Neighbours),
			dfs(Node, Neighbours, Children, TotalNodes, ParentSet, self());
			
		false ->
			% io:fwrite("In non root ~n"),
			dfs(Node, Neighbours, Children, TotalNodes, Parent, ParentValue)
	end.


dfs (Node, Neighbours, Children, TotalNodes, Parent, ParentValue) ->
	P = sets:size(Parent),
	receive
		 {que, SrcPid} ->
		 	case P == 0 of 
				true ->
					ParentSet = sets:add_element(pid_to_list(SrcPid),Parent),
					% io:fwrite("Query ~p!n",[self()]),
					% io:fwrite("ParentSet ~p!n",[ParentSet]),
					lists:foreach(
						fun(N) -> 
							% io:fwrite("Neighbour ~p~n",[N]),
							% io:fwrite("ParentSet ~p!n",[ParentSet]),
							case sets:is_element(N,ParentSet) of 
								true ->
									% io:fwrite("Its Parent ~n"),
									ok;
						
								false ->
									% Visited = 1,
									Pid = list_to_pid(N),
									Pid ! {que, self()}

							end
						end,
					 Neighbours),
					NeighbourSet = sets:from_list(Neighbours),
					Right = sets:subtract(NeighbourSet,ParentSet),
					case sets:size(Right)==0 of
						false->
							dfs(Node, Neighbours, Children, TotalNodes, ParentSet, SrcPid);
						true ->
							SrcPid ! {terminate, self(), sets:add_element(pid_to_list(self()),Children) }
					end;

				false ->
					SrcPid ! {reject, self()},
					dfs(Node, Neighbours, Children, TotalNodes, Parent, ParentValue)
			end;		


		 {reject, SrcPid} ->
		 % 	io:fwrite("In receive reject~p ~n",[SrcPid]),
			% % Left = sets:add_element(pid_to_list(SrcPid),Children),
			% io:fwrite("Neighbour in reject !! ~p",[Neighbours]),
			Neighbours1 = lists:delete(pid_to_list(SrcPid),Neighbours),
			NeighbourSet = sets:from_list(Neighbours1),
			% io:fwrite("Neighbour in reject ~p",[Neighbours1]),
			Right = sets:subtract(NeighbourSet,Parent),
			% io:fwrite("PID reject: ~p~n",[self()]),
			% io:fwrite("Left reject~n ~p~n",[Children]),
			case sets:is_subset(Right,Children) of
					true ->
						ParentValue ! {terminate, self(), sets:add_element(pid_to_list(self()), Children)};
					false ->
						dfs(Node, Neighbours1, Children ,TotalNodes, Parent, ParentValue)	
			end;

		 {terminate, SrcPid, ChildSet} ->
		 	% io:fwrite("In receive terminate ~p ~n",[SrcPid]),
		 	Left1 = sets:union(ChildSet,Children),
			Left2 = sets:add_element(pid_to_list(SrcPid),Left1),
		 	NeighbourSet = sets:from_list(Neighbours),
			Right = sets:subtract(NeighbourSet,Parent),
			io:fwrite("PID terminate: ~p~n",[self()]),
			io:fwrite("Left terminate~n ~p~n",[Left2]),
									
			case sets:is_subset(Right,Left2) of
				true ->
					case Node == 0 of 
						true ->								
							case sets:size(Left2) == TotalNodes -1 of
								true ->
									io:fwrite("------------------------------Connected-------------------------");
								false ->
									io:fwrite("-----------------------------Not Connected-------------------------")
							end ;
						false->
							ParentValue ! {terminate, self(), Left2}
					end;

				false ->
					dfs(Node, Neighbours, Left2, TotalNodes, Parent, ParentValue)	
			end
	
		end.

