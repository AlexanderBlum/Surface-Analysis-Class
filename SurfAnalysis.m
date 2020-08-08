classdef SurfAnalysis
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Zscale {mustBeMember(Zscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        Xscale {mustBeMember(Xscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        dx
        FilteredState
        Trace
        PhaseMap
%         Nx
%         Ny
        Name
    end
    properties (Dependent)
        X
    end
    
    methods
        function S = SurfAnalysis(surface_data, dx, Zscale)
            % Construct an instance of this class
            if nargin == 3
                if (size(surface_data, 1) == 1) || (size(surface_data, 2) == 1)
                    S.Trace = surface_data;
                else
                    S.PhaseMap = surface_data;
                end
%                 [S.Ny, S.Nx] = size(surface_data);
                S.FilteredState = 'unfiltered';
                S.dx = dx;
                S.Zscale = Zscale;
            end
        end
        
        function Plot(S)
            if ~isempty(S.PhaseMap)
                [Ny, Nx] = size(S.PhaseMap);
                x = linspace(0, Nx*S.dx, Nx);
                y = linspace(0, Ny*S.dx, Ny);
                [X,Y] = meshgrid(x, y);

                surf(X, Y, S.PhaseMap,'LineStyle','none'); 
                view(0,90)
                axis([0, x(end), 0, y(end)]);
                ylabel('Height (unit)');
                xlabel('X (unit)');
            elseif ~isempty(S.Trace)
                Nx = length(S.Trace);
                x = linspace(0, Nx*S.dx, Nx);
                plot(x, S.Trace);
                ylabel('Height (unit)');
                xlabel('X (unit)');                
            end
        end
        
        function x = get.X(obj)
%             dx = obj.dx;
%             if ~isempty(S.PhaseMap)
%                 y = linspace(0, size(obj.PhaseMap, 1)*obj.dx, length(obj.PhaseMap, 1))';                
%                 x = linspace(0, size(obj.PhaseMap, 2)*obj.dx, length(obj.PhaseMap, 2))';
%             elseif ~isempty(S.Trace)
                x = linspace(0, length(obj.Trace)*obj.dx, length(obj.Trace))';
%             end
        end
%         function surfRotate(S)
            
        function Filter(S)
            S.FilteredState = 'filtered';
        end
        
        function str(S)
        end
        
        function Ra = Ra(obj)
        end
        
        function Rq = Rq(obj)
        end
        
        function Rz = Rz(obj)
        end
    end
end

