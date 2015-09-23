classdef Node < matlab.mixin.Copyable
    properties (SetAccess = private, GetAccess = public)
        strAImove; % ai move SAN
        strPlayerMove; % player move LAN
        Nodes = { [] }; % empty cell array
        numberOfNodes; % number of children
        strFEN; % fen string of THIS node.
        priority; % priority of the node, determined on node creation for heuristics.
        pieceID; % the pieceId of this node
        parentNode; % the parent of this node used to generate solution string
    end
    
    methods
        function NODE = Node(playermove, aimove, sFEN, sSAN, parent)
            NODE.strAImove = aimove;
            NODE.strPlayerMove = playermove;
            NODE.numberOfNodes = 0;
            NODE.strFEN = sFEN;
            if (isempty(parent) == false)
                NODE.parentNode = parent;
            else
               NODE.parentNode = ''; 
            end
            
            % the following code determines what type of piece the player
            % has moved in this node.
            
            if (isempty(playermove) == false) % the root doesnt represent a move, so skip it for this.
                
                % firstly, determine what PieceID this represents. 
                % since we do not consider pawns, we need not check for
                % them yet.
                
                if (isempty(strfind(sSAN, 'N')) == false) % if the playermove string contains a N - its a kNight
                    NODE.pieceID = 2;
                elseif (isempty(strfind(sSAN, 'B')) == false)
                    NODE.pieceID = 3;
                elseif (isempty(strfind(sSAN, 'R')) == false)
                    NODE.pieceID = 4;
                elseif (isempty(strfind(sSAN, 'Q')) == false)
                    NODE.pieceID = 5;
                elseif (isempty(strfind(sSAN, 'K')) == false) % king
                    NODE.pieceID = 6;
                else
                    NODE.pieceID = 7;
                end    
                
                
                % Heuristic Determination:
                
                % if the playermove contains the 'x' character, we took a piece.% and if the ai player took one of our pieces
                if (isempty(strfind(sSAN, 'x')) == false) && (isempty(strfind(aimove, 'x')) == false)  
                        NODE.priority = 3; % second highest priority. if we took a piece and the ai took a piece.
                elseif (isempty(strfind(sSAN, 'x')) == false) && (isempty(strfind(aimove, 'x')) == true) % if we took a piece and the AI DIDNT then priority 4.
                        NODE.priority = 4; % highest priority for successfully taking a piece without the AI taking one of yours.
                elseif (isempty(strfind(sSAN, 'x')) == true) && (isempty(strfind(aimove, 'x')) == false) % if we didnt take a piece but the AI did then priority 2
                    NODE.priority = 1; % lowest
                else
                    NODE.priority = 2; % else if nobody took a piece then second highest priority.
                end

                
                
                
            else
                
                if (strcmp(aimove, 'BLANK') == 0)
                    fprintf('CREATED ROOT NODE\n');
                    NODE.priority = 5;
                    NODE.pieceID = 0;
                else
                    fprintf('CREATED BLANK NODE\n');
                    NODE.priority = 0;
                    NODE.pieceID = 0; 
                end
                
            end
            
            
        end
        
        function printDebug(NODE)
            
            if (isempty(NODE.strPlayerMove))
                fprintf('ROOT has %d children: ', NODE.numberOfNodes);
            else
                fprintf('%s, %s, has %d children: ', NODE.strPlayerMove, NODE.strAImove, NODE.numberOfNodes);
            end
            
            
            
            for n = 1:NODE.numberOfNodes
                disp(NODE.Nodes{n});
                %fprintf('[%s ,%s, %d]', NODE.Nodes{n}.strPlayerMove, NODE.Nodes{n}.strAImove, NODE.Nodes{n}.pieceID);
            end
            
            fprintf('\n');
            
        end
        function addChild(NODE, newnode)
            
            NODE.Nodes{NODE.numberOfNodes + 1} = newnode;
            NODE.numberOfNodes = NODE.numberOfNodes + 1;
            
            % Simple insertion sort:
            
            itt = NODE.numberOfNodes;
            if (itt > 1)
                while (NODE.Nodes{itt}.pieceID < NODE.Nodes{itt-1}.pieceID)
                   temp = copy(NODE.Nodes{itt});
                   NODE.Nodes{itt} = copy(NODE.Nodes{itt-1});
                   NODE.Nodes{itt-1} = temp;

                   itt = itt - 1;
                   if (itt == 1)
                       break;
                   end
                end
            end
        end
        
        function disp(NODE)
            fprintf('[%s, %s, PieceID: %d, Priority: %d]', NODE.strPlayerMove,NODE.strAImove, NODE.pieceID, NODE.priority);
        end
        
        function strReturn=getString(node)
           
            strReturn = strcat(node.strPlayerMove, strcat(',',node.strAImove));
            
        end
        
        function boolean=equals(NODE1, NODE2)
           % used in greedy search
            % if these characteristic properties are all equal then the two
            % nodes are equal. else they arent
            if (strcmp(NODE1.strPlayerMove, NODE2.strPlayerMove) == 1 && strcmp(NODE1.strAImove, NODE2.strAImove) == 1 && strcmp(NODE1.strFEN, NODE2.strFEN) == 1)
                boolean = true;
            else
                boolean = false;
            end
            
        end
        
        
    end
    
    
    
end
