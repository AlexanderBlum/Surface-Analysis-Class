classdef SurfAnalysis < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Zscale {mustBeMember(Zscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        Xscale {mustBeMember(Xscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        dx
%         FilteredState
        Trace
        PhaseMap
        Name
    end
    properties (Dependent)
        X
        XY
        Nrows
        Ncols
    end
    
    methods
        function surfObj = SurfAnalysis(surfaceData, dx, Zscale, Xscale)
            % Construct an instance of this class
            if nargin == 4
                if (size(surfaceData, 1) == 1) || (size(surfaceData, 2) == 1)
                    surfObj.Trace = surfaceData;
                else
                    surfObj.PhaseMap = surfaceData;
                end
%                 [S.Ny, S.Nx] = size(surface_data);
%                 surfObj.FilteredState = 'unfiltered';
                surfObj.dx = dx;
                surfObj.Zscale = Zscale;
                surfObj.Xscale = Xscale;
            end
        end
        
        function Plot(surfObj)
            if ~isempty(surfObj.PhaseMap)
                [Ny, Nx] = size(surfObj.PhaseMap);
                x = linspace(0, Nx*surfObj.dx, Nx);
                y = linspace(0, Ny*surfObj.dx, Ny);
                [X,Y] = meshgrid(x, y);

                surf(X, Y, surfObj.PhaseMap,'LineStyle','none'); 
                view(0,90)
                axis([0, x(end), 0, y(end)]);
                ylabel(['Y (', surfObj.Xscale, ')']);
                xlabel(['X (', surfObj.Xscale, ')']);
                c = colorbar;
                c.Label.String = ['Z (', surfObj.Zscale, ')'];
                c.Label.FontSize = 12;
            elseif ~isempty(surfObj.Trace)                
                Nx = length(surfObj.Trace);
                x = linspace(0, Nx*surfObj.dx, Nx);
                plot(x, surfObj.Trace);
                ylabel(['Z (', surfObj.Zscale, ')']);
                xlabel(['X (', surfObj.Xscale, ')']);                
            end
        end       
        
        function avgSlice = GetAvgSlice(surfObj, dim)
        assert(~isempty(surfObj.PhaseMap),...
               'There is no PhaseMap in the object!');  
        if dim == "row"
            avgSlice = nanmean(surfObj.PhaseMap, 1);
        elseif dim == "col"
            avgSlice = nanmean(surfObj.PhaseMap, 2);
        end
        end
        
        function mapSlice = GetSlice(surfObj, ind, dim)
            mustBeNonempty(surfObj.PhaseMap);
            assert(isa(surfObj,'SurfAnalysis'),...
               'GetSlice Error:  Input obj is of class %s, not a SurfAnalysis object.',...
                class(surfObj));   
            if dim == "row"
                mapSlice = surfObj.PhaseMap(ind, :);
            elseif dim == "col"
                mapSlice = surfObj.PhaseMap(:, ind);
            end
        end                   
        
        function surfObj = RotateSurf(surfObj, rotAngle)
            surfObj.PhaseMap = imrotate(surfObj.PhaseMap, rotAngle, 'bilinear', 'crop');             
        end
            
        function InterpMap(surfObj, dxNew)
            mustBeNonempty(surfObj.PhaseMap);
            N = size(phasemap, 1);
            xx = linspace(0, N*surfObj.dx, N);
            [XX, ~] = meshgrid(xx, xx);
            Ninterp = floor(xx(end)/dxNew); 
            xQ = linspace(0, Ninterp*dxNew, Ninterp);
            Xq = meshgrid(xQ, xQ);
            surfObj.PhaseMap = interp2(XX, XX', surfObj.PhaseMap, Xq, Xq', 'bilinear');
            surfObj.dx = dxNew;
        end % InterpMap
        
        function InterpTrace(obj, dxNew)
            mustBeNonempty(obj.Trace);
            N = length(obj.Trace);
            xx = linspace(0, N*obj.dx, N);
            Ninterp = floor(xx(end)/dxNew);
            xQ = linspace(0, Ninterp*dxNew, Ninterp);
            obj.Trace = interp1(xx, obj.Trace, xQ, 'linear');  
        end % InterpTrace
        
        function STR(S)
        end
        
%% getter functions
        function Nrows = get.Nrows(surfObj)
            Nrows = size(surfObj.PhaseMap, 1);
        end
        
        function Ncols = get.Ncols(surfObj)
            Ncols = size(surfObj.PhaseMap, 2);
        end
        
        function X = get.X(surfObj)
            mustBeNonempty(surfObj.Trace);
            X = linspace(0, length(surfObj.Trace)*surfObj.dx, length(surfObj.Trace))';
        end
        
        function XY = get.XY(surfObj)
            mustBeNonempty(surfObj.PhaseMap);
            XY{1} = linspace(0, size(surfObj.PhaseMap, 1)*surfObj.dx, size(surfObj.PhaseMap, 1))';                
            XY{2} = linspace(0, size(surfObj.PhaseMap, 2)*surfObj.dx, size(surfObj.PhaseMap, 2))';
        end
%         function Ra = Ra(obj)
%         end
%         
%         function Rq = Rq(obj)
%         end
%         
%         function Rz = Rz(obj)
%         end
        function fitPlane = FitPlane(surfObj)
            % replace surfObj.PhaseMap with Z
            [x, y] = meshgrid(1:1:size(surfObj.PhaseMap, 2),...
                              1:1:size(surfObj.PhaseMap, 1));
            XX = x(~isnan(surfObj.PhaseMap));
            YY = y(~isnan(surfObj.PhaseMap));
            ZZ = surfObj.PhaseMap(~isnan(surfObj.PhaseMap));
            A = [ones(size(XX)) XX YY]\ZZ; % model
            fitPlane = ones(size(surfObj.PhaseMap)).*A(1) + x.*A(2) + y.*A(3);
        end
        
    end
end
