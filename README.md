Chess Artificial Intelligence
=========
============
Uninformed Search Algorithms and Greedy Search:


In this practical a task is given to develop a simple artificial intelligence to play an end-game scenario against the StockFish AI using elementary search techniques. In order to realise the decision tree, it will be recursively constructed to required depth for this practical - depth 4. ie. 4 moves for each player after the start of end game.

The Forsyth-Edwards Notation (FEN) string used for end game tests is:

<code> "6k1=5ppp=pb2p3=1p2P3=1P1BbPnP=P6r=6QP=R4R1Kb 􀀀 􀀀32"</code>

This FEN string corresponds to a board layout which can be won in 4 moves from the player. This AI can complete this task, constructing an obscenely (and unnecessarily) large decision tree and also winning the end-game scenario.

This code implements (in an attempt to explore the effectiveness of) various uninformed and "primitive" AI techniques. This includes decision trees using the concepts of:
* Depth-first traversal ✓
* Breadth-first traversal ✓
* Greedy Search ✓
