classdef Tree < handle
    properties (Hidden)
        
        
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        Root; % empty cell array
        CM;   % current Chessmaster game. Only one should exist in the tree.
        totalNodes; % total number of nodes in the tree.
        visitedNodes = {[]}; %
        noVisited;
        
        tempSolutionString;
        greedyFrontier = {[]};
        frontierSize;
        
    end
    
    events
        %specify events
        
    end
    
    
    methods
        function TREE = Tree(strStart)
            % constructor
            % construct the tree by plotting the moves

            TREE.noVisited = 0;
            TREE.totalNodes = 0;
            TREE.Root = Node('','root',strStart, '', '');
            
            % create an instance of chessmaster
            TREE.CM = ChessMaster;
            TREE.CM.LoadPosition(strStart);
            TREE.tempSolutionString = '';
            TREE.frontierSize = 0;
            
            % these three lines autostart the chess ai engine.
            TREE.CM.SpawnChessEngine(); % open chess engine
            TREE.CM.CElist.autocolor=1; %set player to white (88)
            TREE.CM.CElist.alock=1; %set AI to white
            

        end    
       
        function expandChildren(TREE, node, depth)
          
            %fprintf('processed: %d\n', TREE.totalNodes);
            
            % recursive method (hopefully).
            % depth is the recursive termination point.
            if ((depth <= 0) || (strcmp(node.strAImove, 'CHECKMATE') == 1) || (isempty(strfind(node.strAImove, '#')) == false))  
                % depth checking aswell as checking for checkmate - naturally we dont want to expand a checkmate node of either black or white player.

                
                
                %fprintf('===============================\n REACHED THE BOTTOM OF THE TREE.\n =============================== \n');
                
                
            else
                % set up the board with the starting fen of the CURRENT
                % node.
                
                TREE.CM.LoadPosition(node.strFEN);
             
                
                % create the root node, with the initial state of the board.
                % do this by:
                %   - finding all moves in the initial state of the board
                %   - create a node for each respective move, also containing
                %   the AI retaliation

                % Find all moves using HUGOS CODE (replace this ASAP):
                % ===================================================
                board = TREE.CM.giveBoard(); %Get the CM board.
                all_moves = board.GetAllMoves(TREE.CM.turnColor); % all possible moves autoscaling matrix.
                
                num_pc = size(all_moves); %This returns the size of the matrix. The first value will tell us how many pieces there are. 
                %The second value will be the maximum number of moves that those pieces can make. The third one will always be 6, indicating the moves themselves.

                
                % Store the moves aswell as pieceID in the moves array. 
                % NOTE: Moves(1,y) is the move itself
                %       Moves(2,y) is the PieceID. NOT USING THIS.
                
                Moves = cell(1,1); %Matlab cell array that stores all the moves
                itt=1;

                    for i = 1:num_pc(1) %This is a for loop that will iterate over all the chess pieces.

                        % Ignore pawns whose pieceID is 1:
                        if (all_moves(i,1,6) ~= 1)%all_moves(i,1,6) == iDesiredPiece)
                            
                            for j = 1:num_pc(2)%This is a for loop that will iterate over all the moves. This will iterate for the maximum number of moves that a piece can make.
                                if all_moves(i,j,1)~=0%If the piece does not have a move, a value of '0' will be saved in the array.
                                  if all_moves(i,j,5)==0%If the piece does not have a promotion, generate a standard LAN string that can be used to move the piece.
                                      LAN = Move.GenerateLAN(all_moves(i,j,1),all_moves(i,j,2),all_moves(i,j,3),all_moves(i,j,4));%Generate the LAN string
                                      if (all_moves(i,j,6)~=1)
                                          % fprintf('ADDING TO MOVE ARRAY %s', LAN);
                                          Moves(1,itt) = java.lang.String(LAN);%Saves the LAN move to a cell array
                                          %Moves{2,itt} = all_moves(i,1,6);
                                          itt = itt+1;
                                          % fprintf(',MOVE ARRAY IS NOW %d \n', itt);
                                      end
                                      %fprintf('Move %d : ', j);%Print the LAN string out and the move number
                                      %disp(LAN);
                                  else %If the piece needs to be promoted, generate the relevant LAN string
                                      LAN = Move.GenerateLAN(all_moves(i,j,1),all_moves(i,j,2),all_moves(i,j,3),all_moves(i,j,4),all_moves(i,j,5));%LAN string that includes a promotion
                                      if (all_moves(i,j,6)~=1)
                                          Moves(1,itt) = java.lang.String(LAN);%Saves the LAN move to a cell array
                                          %Moves{2,itt} = all_moves(i,1,6);
                                          itt = itt+1;
                                      end
                                  end
                                
                                %disp(Moves(2,i));
                                %disp(size(Moves,2));
                                end

                            end

                        end
                    end
                
                % ==========================================
                % AT THIS POINT WE HAVE ALL VALID MOVES in the Moves array
                %
               
                
                % Now that we have all the possible moves that we can make,
                % make them.
                % Afterwhich we will then get the AI response, and when we do
                % we can then create child nodes for the root node.
                
                moves = size(Moves);%Get the number of moves
                %fprintf('TOTAL NUMBER OF MOVES IS %d -------------------- \n', moves(2));
                for y = 1:moves(2)%Iterate through all the moves, running each one and printing out the AI response of each move.
                    %disp(Moves(1,y));
                    if (isempty(Moves{1,y}) == false) % make sure that the move is valid.
                        
                        currMove = TREE.CM.MakeMove(char(Moves(1,y))); % this returns the SAN string, which contains the result of the move aswell as the piece type.
                        %----------------------------------------------------------------------------------------------------------------------------------------
                        %WARNING: If you put the AI into checkmate here, it will not be able to make a responce move. Thus the following while loop will get stuck
                        %indefinitely. You need to check for 'checkmate' before the while loop kicks in,and then skip the while loop
                        % - Hugo
                        %----------------------------------------------------------------------------------------------------------------------------------------

                        % check for checkmate:
                        
                        if (isempty(strfind(currMove, '#')) == false) % check if you got the enemy in checkmate.
                        
                            % You got the opponent in checkmate.
                            % Don't bother trying to get the AI
                            % retaliation, simply create a child node with
                            % the AI move property of checkmate.
                            tempNewNode = Node(char(Moves(1,y)), 'CHECKMATE', TREE.CM.GetFENstr(), currMove, node);
                            fprintf('ADDED CHECKMATE NODE\n'); % just to see in console :)
                            
                        else
                            bool=false;%This is to check if the StockFish AI is still busy
                            while (bool==false)
                                pause(0.05);%Check in 50ms intervals
                                AI_move = TREE.CM.GetSANstrs();%Get all the moves made. If there is only 1 move made, the StockFish AI is still thinking
                                breakFlag = size(AI_move);
                                if (breakFlag(2)~=1)%If there are >1 moves, break out of the while.
                                    bool=true;
                                end
                            end
                            
                            % now that we have playermove aswell as AI
                            % retaliation, we can create our temporary node
                            % 
                            tempNewNode = Node(char(Moves(1,y)), char(AI_move(2)), TREE.CM.GetFENstr(), currMove, node);
                        
                        end
                        
                        node.addChild(tempNewNode); % add the new child 
                        TREE.totalNodes = TREE.totalNodes + 1; % inc.

                        % in order to keep checking the same nodes possible
                        % children, we need to constantly reset the state
                        % of the board to that of the current node whose
                        % children we are expanding.
                        TREE.CM.LoadPosition(node.strFEN);%Reset the board, to the current nodes FEN string.
                    end
                end



                % =====
                % At this point, our current working node has been expanded
                % with all its children, now we will iteratively cross
                % through the children and recursively expand the child nodes
                % each time minusing one from the depth parameter to ensure
                % we dont end up in an endless loop.
                
                
                % now iterate through the nodes, and recursively call down.
                for in=1:node.numberOfNodes

                    %fprintf('Expanding: %d', in);
                    %disp(node);

                    % the idea is to now expand the children of the node passed
                    % as parameter.
                    
                    TREE.expandChildren(node.Nodes{in}, depth - 1);

                end
            
                
            end
        end
        
        
        function printFirstLayer(TREE)
            
            TREE.Root.printDebug();
            fprintf('Tree Total Nodes (including Root): %d\n', TREE.totalNodes + 1);
            
        end
        
        function closeCM(TREE)
        
            fprintf('TREE TOTAL NUMBER OF NODES: %d \n', TREE.totalNodes);
            TREE.CM.Close();
            
        end
        
        function depthFirstSearch(TREE)

            TREE.noVisited = 0;
            TREE.visitedNodes = {[]};
            
            TREE.depthFirstSearchRecursive(TREE.Root);
            
        end
        
        
        function depthFirstSearchRecursive(TREE, node)
           % perform a depth first search
           
           if (isempty(node) == false) % only proceed down the tree if the node passed is not a null node.
               
               
               if (node == TREE.Root)
                   fprintf('VISITING ROOT\n');
                   TREE.noVisited = 0;
                   TREE.visitedNodes = {[]};
               else
                   %fprintf('VISITING');
                   %disp(node);
                   %fprintf('\n');
               end
               
               TREE.visitedAdd(node); 
               
               if (strcmp(node.strAImove, 'CHECKMATE') == 1)
                    fprintf('CHECKMATE FOUND! at %d \\\\ \n', TREE.noVisited);
                    % when we find a checkmate, we want to find the
                    % solution string of this new checkmate. So loop up
                    % till the parent is root concatenating the strings.
                    
                    TREE.tempSolutionString = '';
                   
                    currNode = node;
                    while (isempty(currNode.parentNode) == false)
                       % loop up the parents
                       
                       % add on to the solution the player move string of
                       % this to the solution string.
                       TREE.tempSolutionString = strcat(currNode.strPlayerMove, strcat('-',TREE.tempSolutionString));
                       
                       
                       
                       currNode = currNode.parentNode;
                    end
                    
                    % finally print out the resultant solution string:
                    fprintf('Solution for this checkmate at DFS traversal no. %d is %s \\\\ \n', TREE.noVisited, TREE.tempSolutionString);
               else
                   for in=1:node.numberOfNodes
                       TREE.depthFirstSearchRecursive(node.Nodes{in});
                   end
               end
      
            
           end
        end
        
        function depthLimitedSearch(TREE, node, depth)
           % perform a DFS limited search
           
           
           
           if (isempty(node) == false && depth > 0) % only proceed down the tree if the node passed is not a null node.
               
               
               if (node == TREE.Root)
                   fprintf('VISITING ROOT\n');
                   TREE.noVisited = 0;
                   TREE.visitedNodes = {[]};
               else
                   %fprintf('VISITING');
                   %disp(node);
                   %fprintf('\n');

               end
               
               TREE.visitedAdd(node); 
               if (strcmp(node.strAImove, 'CHECKMATE') == 1)
                    fprintf('CHECKMATE FOUND! at %d  \\\\ \n', TREE.noVisited);
               else
                   for in=1:node.numberOfNodes
                       TREE.depthLimitedSearch(node.Nodes{in}, depth - 1);
                   end
               end
      
            
           end
        end
        
        
        function breadthFirstSearch(TREE)
            
             TREE.noVisited = 0;
             TREE.visitedNodes = {[]};
             
             for iLevel = 1:5
                 fprintf('Entering new level.. %d\n', iLevel);
                 fprintf('Number of nodes above new level %d\n', TREE.noVisited);
                 TREE.bfsDepthLimited(TREE.Root, iLevel);
                 fprintf('Number of nodes above new level after is %d\n', TREE.noVisited);
             end
             
            
        end
        
        function bfsDepthLimited(TREE, node, depth)
           % perform a DFS limited search in order to fulfill a BFS.
           % This function is called iteratively to emulate a BFS.
           
           if (isempty(node) == false && depth > 0) % only proceed down the tree if the node passed is not a null node. 
               % only visit the node, if we are at the final depth.
               
               if (depth == 1)
                  % we are at the bottom of this depth criteria, so visit
                  % the node.
                  
                  TREE.visitedAdd(node); 
                  if (strcmp(node.strAImove, 'CHECKMATE') == 1)
                    fprintf('CHECKMATE FOUND! at %d  \\\\ \n', TREE.noVisited);
                    % when we find a checkmate, we want to find the
                    % solution string of this new checkmate. So loop up
                    % till the parent is root concatenating the strings.
                    
                    TREE.tempSolutionString = '';
                   
                    currNode = node;
                    while (isempty(currNode.parentNode) == false)
                       % loop up the parents
                       
                       % add on to the solution the player move string of
                       % this to the solution string.
                       TREE.tempSolutionString = strcat(currNode.strPlayerMove, strcat('-',TREE.tempSolutionString));
                       
                       
                       
                       currNode = currNode.parentNode;
                    end
                    
                    % finally print out the resultant solution string:
                    fprintf('Solution for this checkmate at BFS traversal no. %d is %s \\\\ \n', TREE.noVisited, TREE.tempSolutionString);
                    
                  end
                   
               end

               for in=1:node.numberOfNodes
                   TREE.bfsDepthLimited(node.Nodes{in}, depth - 1);
               end
      
            
           end
        end
        
        function greedySearch(TREE)
           % Greedy Search method:
           
           % define the greedy frontier.
           %import java.util.LinkedList
           %TREE.greedyFrontier = LinkedList();
           TREE.greedyFrontier = {[]};
           TREE.frontierSize = 0;
           % expand the initial frontier:
           TREE.addFrontier(TREE.Root);
           
           for i=1:TREE.frontierSize
           
               % find the best of the frontier, and expand it.
               TREE.addFrontier(TREE.greedyFrontier{TREE.getFrontierMax()});
               
               
           end
           
           
            
        end
        
        function addFrontier(TREE,currNode)
            % this function adds the currNode's children to the frontier of
            % the greedy search.
            
            if (strcmp(currNode.strAImove, 'CHECKMATE') == 1)
                fprintf('GREEDY FOUND THE GOAL\n');
            else
                % temp store the node to expand.
                temp = copy(currNode);

                % pop the currNode from the frontier.
                TREE.popFrontier(currNode);

                % expand the node we just popped, to expand the frontier.

                for i=1:temp.numberOfNodes
                    %TREE.greedyFrontier{TREE.frontierSize + i} = temp.Nodes{i}
                    TREE.insertIntoFrontier(temp.Nodes{i});
                end
            end
            
        end
        
        function insertIntoFrontier(TREE, currNode)
           flag = 0;
            for i=1:TREE.frontierSize
               if (isempty(TREE.greedyFrontier{i}) == true)
                   flag = 1;
                   TREE.greedyFrontier{i} = currNode;
                   TREE.frontierSize = TREE.frontierSize + 1;
                   break;
               end
                  
            end
            
            if (flag == 0)
                TREE.greedyFrontier{TREE.frontierSize + 1} = currNode;
                TREE.frontierSize = TREE.frontierSize + 1;
            end
        end
        
        
        function popFrontier(TREE,currNode)
            if (TREE.frontierSize > 0)
            
                for i=1:TREE.frontierSize
                   if (TREE.greedyFrontier{i}.equals(currNode) == true)
                      % pop it right off, decrease size of array.
                      TREE.greedyFrontier{i} = Node('', 'BLANK','','','');
                      TREE.frontierSize = TREE.frontierSize - 1;
                      break;
                   end
                    
                end
            end
            
        end
        
        function frontMax = getFrontierMax(TREE)
           % returns the index of the max frontier
           
           max = 0;
           maxPos = 1;
           for i=1:TREE.frontierSize
               if (isempty(TREE.greedyFrontier{i}) == false)
                  if ( TREE.greedyFrontier{i}.priority > max )
                      max = TREE.greedyFrontier{i}.priority;
                      maxPos = i;
                  end
               end
           end
           
           frontMax = maxPos;
           
        end
        
        function printFrontier(TREE)
           
            for i = 1:TREE.frontierSize
               disp(TREE.greedyFrontier{i}); 
            end
            
        end
       
        
        function disp(TREE)
            fprintf('Tree: %s\n', TREE.Root.printDebug());
        end
        
        function visitedAdd(TREE, node)
            TREE.visitedNodes{TREE.noVisited + 1} = strcat(node.strPlayerMove, strcat(',',node.strAImove));
            TREE.noVisited = TREE.noVisited + 1;
            
        end
        
        function printVisited(TREE)
           
            for i= 1:TREE.noVisited
                fprintf('%d - %s\n', i, TREE.visitedNodes{i});
            end
            
        end
        
        
    end
    
    
    
    
    methods(Static = true)    

    end
        
        
        
end