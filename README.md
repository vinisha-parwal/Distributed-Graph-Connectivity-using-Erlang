# Distributed-Graph-Connectivity-using-Erlang
Goal : Expecting to build a system to determine whether the given graph is connected

Algorithm :
(local variables)
int parent ←⊥
Int totalNodes = n
set of int Children ←
set of int Neighbors ← set of neighbors

(message types)
QUERY, REJECT,TERMINATE

(1)When the predesignated root node wants to initiate the algorithm:
(1a)    if (i = root and parent =⊥) then
(1b)            send QUERY to all neighbors;
(1c)            parent ← i.

(2) When QUERY arrives from j at i:
(2a)         if parent =⊥ then
(2b)           parent ← j;
(2d)           send QUERY to all neighbors except j;
(2e)                    if Neighbors/parent ==   then
(2f)                  send TERMINATE with Children_i.
(2g)         else send REJECT to j.

(3) When REJECT arrives from j at i:
(3a)     Neighbors = Neighbors/j
(3b)     if Neighbors isSubset Children then
(3c)              send TERMINATE with Children_i to i's parent .

(4) When TERMINATE with Children set of j  arrives from j at i :
(4a)    {Children_i} = {Children_j} U {Children_i}
(4b)    {Children_i} = {Childreni} U {j}
(4c)     if  Neighbors/parent isSubset {Children_i}
(4d)           if i==root then
(4e)                       if size({Children_i}) == totalNodes then
(4f)                                       CONNECTED GRAPH
(4g)                                       terminate.
(4h)                      else
(4i)                                     NOT CONNECTED GRAPH
(4j)                                     terminate.


Terminate Condition : 
When all the neighbour neighbour nodes have been visited we terminate the node. 
When a node receives REJECT / TERMINATE response from its neighbour nodes, the node deletes the neighbour node’s entry from the neighbour set. So when the neighbour set becomes empty, node terminates.

Complexity :
Number of Messages => 
Let number of edges  be L
So, per edge Query message is sent and in reply either a terminate or reject message is sent.
Total =  2L number of messages
Message Space complexity =>
Per Query and Reject Message = only sender’s pid sent    
Per Terminate Message = sender’s pid and children set sent
Local Time Complexity =>
Each node send query to all its neighbours and wait for all Reject or Terminate messages to arrive before terminating.
So local computation is O(number of neighbour nodes).
Local Memory =>
Array to store set of neighbours and children nodes.
Global memory =>
Sum of local memory of all  nodes.


Running procedure : 
#on one machine with different processes acting as different nodes.
1)Initialise different nodes with this code. : spawn(dfs3,start()) , you will get different process ids as node ids.
2)Then on root node(previously known) mention the relation. : erlang : list_to_pid(<source_pid_in_string>)! {initialise,<root_or_not>,<list_of_neighbour_pids_in_string>}

Do second step for all the nodes.
#Result : <connected>/<disconnected>
